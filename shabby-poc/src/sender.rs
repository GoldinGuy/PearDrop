use super::Marshal;
use thiserror::Error;

/**
 * Sender packet extension.
 *
 * Empty as it is implemented by other structs.
 *
 * TODO: Add Error type.
 */
pub trait SenderExtension: std::fmt::Debug {}

/**
 * Sender packet.
 * See the core protocol.
 */
#[derive(Debug)]
pub struct SenderPacket {
    filename: String,
    mimetype: String,
    extensions: Vec<Box<dyn SenderExtension>>,
    data_len: u64,
}

impl Marshal for SenderPacket {
    type Error = SenderPacketError;

    /**
     * Reads a SenderPacket from the given reader.
     */
    fn read(r: &mut dyn std::io::Read) -> Result<Self, Self::Error> {
        use byteorder::{ReadBytesExt, BE};
        use ux::u12;
        let triple_byte = r.read_u24::<BE>()?;
        // Take out filename length and MIME type length
        let filename_len = u12::new(((triple_byte & 0xfff000) >> 12) as u16);
        let mimetype_len = u12::new((triple_byte & 0xfff) as u16);
        if u16::from(filename_len) > MAX_FILENAME_LEN {
            return Err(SenderPacketError::FilenameLengthExceeded(filename_len));
        }
        if u16::from(mimetype_len) > MAX_MIMETYPE_LEN {
            return Err(SenderPacketError::MIMETypeLengthExceeded(mimetype_len));
        }

        // Read filename and MIME type
        let mut filename_v = vec![0; u16::from(filename_len) as usize];
        r.read_exact(&mut filename_v)?;
        let filename = match String::from_utf8(filename_v) {
            Ok(s) => s,
            Err(_) => return Err(SenderPacketError::InvalidFilename),
        };
        let mut mimetype_v = vec![0; u16::from(mimetype_len) as usize];
        r.read_exact(&mut mimetype_v)?;
        let mimetype = match String::from_utf8(mimetype_v) {
            Ok(s) => s,
            Err(_) => return Err(SenderPacketError::InvalidMIMEType),
        };

        // Read extensions
        let exts_len = r.read_u8()?;
        let exts = Self::read_exts(r, exts_len)?;

        // Read data lenth
        let data_len = r.read_u64::<BE>()?;

        Ok(Self::new(filename, mimetype, exts, data_len))
    }

    /**
     * Writes this SenderPacket to the given writer.
     */
    fn write(&self, w: &mut dyn std::io::Write) -> Result<(), Self::Error> {
        use byteorder::{WriteBytesExt, BE};
        let ext_len = self.extensions.len();
        if ext_len != 0 {
            unimplemented!();
        }

        // Write filename and MIME type
        let triple_byte = ((self.filename.len() as u32) << 12) | self.mimetype.len() as u32;
        w.write_u24::<BE>(triple_byte)?;
        w.write_all(&self.filename.as_bytes())?;
        w.write_all(&self.mimetype.as_bytes())?;

        // Write extensions
        w.write_u8(ext_len as u8)?;

        // Write data_len
        w.write_u64::<BE>(self.data_len)?;

        Ok(())
    }
}

impl SenderPacket {
    /**
     * Creates a new SenderPacket using the given name, MIME type, extensions
     * and data length.
     */
    pub fn new(
        filename: String,
        mimetype: String,
        extensions: Vec<Box<dyn SenderExtension>>,
        data_len: u64,
    ) -> Self {
        Self {
            filename,
            mimetype,
            extensions,
            data_len,
        }
    }

    fn read_exts(
        _r: &mut dyn std::io::Read,
        exts_len: u8,
    ) -> Result<Vec<Box<dyn SenderExtension>>, SenderPacketError> {
        if exts_len != 0 {
            unimplemented!()
        } else {
            Ok(Vec::new())
        }
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
pub const MAX_FILENAME_LEN: u16 = 4084; /* see kjetilkjeka/ux#5 */
/// Maximum length of the MIME type in a SenderPacket.
pub const MAX_MIMETYPE_LEN: u16 = 4084; /* see kjetilkjeka/ux#5 */

/**
 * Error while constructing a SenderPacket.
 */
#[derive(Error, Debug)]
pub enum SenderPacketError {
    #[error("Filename length exceeded {} bytes (got {0} bytes)", MAX_FILENAME_LEN)]
    FilenameLengthExceeded(ux::u12),
    #[error("MIME type length exceeded {} bytes (got {0} bytes)", MAX_MIMETYPE_LEN)]
    MIMETypeLengthExceeded(ux::u12),
    #[error("Filename is not valid UTF-8")]
    InvalidFilename,
    #[error("MIME type is not valid UTF-8")]
    InvalidMIMEType,
    #[error("IO error: {0}")]
    IO(#[from] std::io::Error),
}

#[cfg(test)]
mod test {
    use super::*;

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
        let mut cursor = std::io::Cursor::new(data);

        let packet = SenderPacket::read(&mut cursor).unwrap();
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
        let mut cursor = std::io::Cursor::new(data);

        let packet = SenderPacket::read(&mut cursor);
        /* Necessary because Error doesn't impl PartialEq */
        assert!(packet.is_err());
        match packet {
            Err(e) => match e {
                SenderPacketError::InvalidFilename => assert!(true),
                _ => assert!(false),
            },
            _ => unreachable!(),
        }
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
        let mut cursor = std::io::Cursor::new(data);

        let packet = SenderPacket::read(&mut cursor);
        /* Necessary because Error doesn't impl PartialEq */
        assert!(packet.is_err());
        match packet {
            Err(e) => match e {
                SenderPacketError::InvalidMIMEType => assert!(true),
                _ => assert!(false),
            },
            _ => unreachable!(),
        }
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
            Vec::new(),
            data_len,
        );
        let mut out = Vec::new();
        packet.write(&mut out).unwrap();

        assert_eq!(out, expected);
    }
}
