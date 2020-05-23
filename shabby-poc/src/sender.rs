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
    mime_type: String,
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
        let mut filename_v = vec![0; u16::from(filename_len) as usize];
        r.read_exact(&mut filename_v)?;
        let mut mimetype_v = vec![0; u16::from(mimetype_len) as usize];
        r.read_exact(&mut mimetype_v)?;
        unimplemented!()
    }

    /**
     * Writes this SenderPacket to the given writer.
     */
    fn write(&self, w: &mut dyn std::io::Write) -> Result<(), Self::Error> {
        unimplemented!()
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
    #[error("IO error: {0}")]
    IO(#[from] std::io::Error),
}

impl SenderPacket {
    pub fn new(
        filename: String,
        mime_type: String,
        extensions: Vec<Box<dyn SenderExtension>>,
        data_len: u64,
    ) -> Self {
        Self {
            filename,
            mime_type,
            extensions,
            data_len,
        }
    }
}
