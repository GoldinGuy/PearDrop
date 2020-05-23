use super::Marshal;
use thiserror::Error;

/**
 * Advertisement packet extension.
 *
 * Empty as it is implemented by other structs.
 *
 * TODO: Add Error type.
 */
pub trait AdExtension: std::fmt::Debug {}

/**
 * Advertisement packet.
 * See the core protocol.
 */
#[derive(Debug)]
pub struct AdPacket {
    extensions: Vec<Box<dyn AdExtension>>,
}

impl Marshal for AdPacket {
    type Error = AdPacketError;

    /**
     * Reads an AdPacket from the given reader.
     */
    fn read(r: &mut dyn std::io::Read) -> Result<Self, Self::Error> {
        use byteorder::ReadBytesExt;
        /* ext len */
        let ext_len = r.read_u8()?;
        let exts = Self::read_exts(r, ext_len)?;
        Ok(Self::new(exts))
    }

    /**
     * Writes an AdPacket to the given writer.
     */
    fn write(&self, w: &mut dyn std::io::Write) -> Result<(), Self::Error> {
        use byteorder::WriteBytesExt;
        let ext_len = self.extensions.len() as u8;
        if ext_len != 0 {
            unimplemented!();
        }
        w.write_u8(ext_len)?;
        Ok(())
    }
}

impl AdPacket {
    /**
     * Creates a new AdPacket using the given extensions.
     */
    pub fn new(extensions: Vec<Box<dyn AdExtension>>) -> Self {
        Self { extensions }
    }

    fn read_exts(
        _r: &mut dyn std::io::Read,
        ext_len: u8,
    ) -> Result<Vec<Box<dyn AdExtension>>, AdPacketError> {
        // TODO: implement
        if ext_len != 0 {
            unimplemented!()
        } else {
            Ok(Vec::new())
        }
    }
}

#[derive(Error, Debug)]
pub enum AdPacketError {
    #[error("{0}")]
    IO(#[from] std::io::Error),
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_read() {
        let data = [0 /* ext_len */];
        let mut cursor = std::io::Cursor::new(data);
        let packet = AdPacket::read(&mut cursor).unwrap();
        assert_eq!(packet.extensions.len(), 0);
    }

    #[test]
    fn test_write() {
        let packet = AdPacket::new(Vec::new());
        let mut out = Vec::new();
        let expected = [0];
        packet.write(&mut out).unwrap();
        assert_eq!(out, expected);
    }
}
