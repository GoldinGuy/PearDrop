use deku::prelude::*;
use std::collections::HashSet;

/**
 * Sender packet.
 * See the core protocol.
 */
#[derive(Debug, Clone, DekuRead, DekuWrite)]
#[deku(endian = "big")]
pub struct SenderPacket {
    #[deku(bits = "12", map = "check_filename_length")]
    filename_len: u16,
    #[deku(bits = "12", map = "check_mimetype_length")]
    mimetype_len: u16,
    #[deku(
        count = "filename_len",
        /* vec <-> string */
        map = "|x: Vec<u8>| -> Result<_, DekuError> { String::from_utf8(x).map_err(|e| DekuError::Parse(e.to_string())) }",
        writer = "write_string(&self.filename, output_is_le, field_bits)"
    )]
    filename: String,
    #[deku(
        count = "mimetype_len",
        /* vec <-> string */
        map = "|x: Vec<u8>| -> Result<_, DekuError> { String::from_utf8(x).map_err(|e| DekuError::Parse(e.to_string())) }",
        writer = "write_string(&self.mimetype, output_is_le, field_bits)"
    )]
    mimetype: String,
    extensions_len: u8,
    #[deku(
        count = "extensions_len",
        /* vec <-> hashset */
        map = "|x: Vec<SenderExtension>| -> Result<_, DekuError> { Ok(x.into_iter().collect::<HashSet<_>>()) }",
        writer = "write_hashset(&self.extensions, output_is_le, field_bits)"
    )]
    extensions: HashSet<SenderExtension>,
    data_len: u64,
}

/* util */
fn check_filename_length(x: u16) -> Result<u16, DekuError> {
    if x <= MAX_FILENAME_LEN {
        Ok(x)
    } else {
        Err(DekuError::Parse(format!(
            "Exceeded maximum filename length of {} (got {})",
            MAX_FILENAME_LEN, x
        )))
    }
}

fn check_mimetype_length(x: u16) -> Result<u16, DekuError> {
    if x <= MAX_MIMETYPE_LEN {
        Ok(x)
    } else {
        Err(DekuError::Parse(format!(
            "Exceeded maximum MIME type length of {} (got {})",
            MAX_MIMETYPE_LEN, x
        )))
    }
}

/* Hack because there is no write map for now */
fn write_hashset(
    x: &HashSet<SenderExtension>,
    output_is_le: bool,
    bit_size: Option<usize>,
) -> Result<BitVec<Msb0, u8>, DekuError> {
    x.iter()
        .cloned()
        .collect::<Vec<_>>()
        .write(output_is_le, bit_size)
}

/* Hack because there is no write string for now */
fn write_string(
    x: &str,
    output_is_le: bool,
    bit_size: Option<usize>,
) -> Result<BitVec<Msb0, u8>, DekuError> {
    x.as_bytes().to_vec().write(output_is_le, bit_size)
}

/**
 * Extension to a sender packet.
 * See the core protocol.
 */
#[derive(Debug, Clone, Hash, PartialEq, Eq, DekuRead, DekuWrite)]
#[deku(endian = "big", id_type = "u8")]
#[non_exhaustive]
pub enum SenderExtension {
    // XXX: Remove this once SenderPacket has an extension
    #[deku(id = "0")]
    #[allow(non_camel_case_types)]
    _hack,
}

impl SenderPacket {
    /**
     * Creates a new SenderPacket using the given name, MIME type, extensions
     * and data length.
     */
    pub fn new(
        filename: String,
        mimetype: String,
        extensions: HashSet<SenderExtension>,
        data_len: u64,
    ) -> Self {
        Self {
            filename_len: filename.len() as _,
            mimetype_len: mimetype.len() as _,
            filename,
            mimetype,
            extensions_len: extensions.len() as _,
            extensions,
            data_len,
        }
    }

    /**
     * Reads a SenderPacket from the given reader.
     */
    pub fn read(r: &mut dyn std::io::Read) -> Result<Self, DekuError> {
        // XXX: Keep this updated!
        let mut buf = vec![0; 4096];
        r.read(&mut buf)
            .map_err(|_| DekuError::InvalidParam("Failed to read".to_string()))?;
        use std::convert::TryFrom;
        Self::try_from(&buf[..])
    }

    /**
     * Writes a SenderPacket to the given writer.
     */
    pub fn write(&self, w: &mut dyn std::io::Write) -> Result<(), DekuError> {
        use std::convert::TryInto;
        let out: Vec<u8> = (*self).clone().try_into()?;
        w.write_all(&out)
            .map_err(|_| DekuError::InvalidParam("Failed to write".to_string()))
    }

    /**
     * Get the filename of this SenderPacket.
     */
    pub fn get_filename(&self) -> &str {
        &self.filename
    }

    /**
     * Get the MIME type of this SenderPacket.
     */
    pub fn get_mimetype(&self) -> &str {
        &self.mimetype
    }

    /**
     * Get the data length of this SenderPacket.
     */
    pub fn get_data_len(&self) -> u64 {
        self.data_len
    }
}

/// Maximum length of the filename in a SenderPacket.
pub const MAX_FILENAME_LEN: u16 = 4084;
/// Maximum length of the MIME type in a SenderPacket.
pub const MAX_MIMETYPE_LEN: u16 = 4084;

#[cfg(test)]
mod test {
    use super::*;
    use std::convert::{TryFrom, TryInto};

    #[test]
    fn test_read() {
        use byteorder::{WriteBytesExt, BE};
        use std::io::Write;
        let filename = "example.txt";
        let mimetype = "text/plain";
        let data_len = 278475344u64;
        let triple_byte = ((filename.len() as u32) << 12) | mimetype.len() as u32;
        let mut data = vec![];
        data.write_u24::<BE>(triple_byte).unwrap();
        data.write_all(filename.as_bytes()).unwrap();
        data.write_all(mimetype.as_bytes()).unwrap();
        data.write_u8(0).unwrap(); // exts_len
        data.write_u64::<BE>(data_len).unwrap();

        let packet = SenderPacket::try_from(&data[..]).unwrap();
        assert_eq!(packet.extensions.len(), 0);
        assert_eq!(packet.filename, filename);
        assert_eq!(packet.mimetype, mimetype);
        assert_eq!(packet.data_len, data_len);
    }

    #[test]
    fn test_read_invalid_filename() {
        use byteorder::{WriteBytesExt, BE};
        use std::io::Write;
        // From https://stackoverflow.com/a/3886015
        // Invalid 4 Octet Sequence (in 3rd Octet)
        let filename = [0xf0, 0x90, 0x28, 0xbc];
        let mimetype = "text/plain";
        let data_len = 278475344u64;
        let triple_byte = ((filename.len() as u32) << 12) | mimetype.len() as u32;
        let mut data = vec![];
        data.write_u24::<BE>(triple_byte).unwrap();
        data.write_all(&filename).unwrap();
        data.write_all(mimetype.as_bytes()).unwrap();
        data.write_u8(0).unwrap(); // exts_len
        data.write_u64::<BE>(data_len).unwrap();

        let packet = SenderPacket::try_from(&data[..]);
        assert!(packet.is_err());
    }

    #[test]
    fn test_read_invalid_mimetype() {
        use byteorder::{WriteBytesExt, BE};
        use std::io::Write;
        let filename = "example.txt";
        // From https://stackoverflow.com/a/3886015
        // Invalid 4 Octet Sequence (in 3rd Octet)
        let mimetype = [0xf0, 0x90, 0x28, 0xbc];
        let data_len = 278475344u64;
        let triple_byte = ((filename.len() as u32) << 12) | mimetype.len() as u32;
        let mut data = vec![];
        data.write_u24::<BE>(triple_byte).unwrap();
        data.write_all(filename.as_bytes()).unwrap();
        data.write_all(&mimetype).unwrap();
        data.write_u8(0).unwrap(); // exts_len
        data.write_u64::<BE>(data_len).unwrap();

        let packet = SenderPacket::try_from(&data[..]);
        assert!(packet.is_err());
    }

    #[test]
    fn test_write() {
        use byteorder::{WriteBytesExt, BE};
        use std::io::Write;
        let filename = "example.txt";
        let mimetype = "text/plain";
        let data_len = 278475344u64;
        let triple_byte = ((filename.len() as u32) << 12) | mimetype.len() as u32;
        let mut expected = vec![];
        expected.write_u24::<BE>(triple_byte).unwrap();
        expected.write_all(filename.as_bytes()).unwrap();
        expected.write_all(mimetype.as_bytes()).unwrap();
        expected.write_u8(0).unwrap(); // exts_len
        expected.write_u64::<BE>(data_len).unwrap();

        let packet = SenderPacket::new(
            filename.to_string(),
            mimetype.to_string(),
            HashSet::new(),
            data_len,
        );
        let out: Vec<u8> = packet.try_into().unwrap();

        assert_eq!(out, expected);
    }
}
