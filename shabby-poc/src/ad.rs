use super::{Marshal, Size};
use thiserror::Error;

/**
 * TCP acknowledgement packet extension.
 * See network extensions.
 */
#[derive(Debug, Clone)]
pub struct TCPAdExtension {
    pub ad_port: u16,
}

impl Size for TCPAdExtension {
    const SIZE: u8 = std::mem::size_of::<u16>() as _;
}

/**
 * Type of the advertisement packet extension.
 */
#[repr(u8)]
#[derive(num_derive::FromPrimitive, Debug, Copy, Clone, PartialEq, Eq)]
pub enum AdExtensionType {
    TCP,
}

/**
 * Advertisement packet.
 * See the core protocol.
 */
#[derive(Debug)]
pub struct AdPacket {
    pub extensions: AdExtensions,
}

#[derive(Debug, Clone, Default)]
pub struct AdExtensions {
    pub tcp: Option<TCPAdExtension>,
}

impl AdExtensions {
    pub fn len(&self) -> u8 {
        let mut len = 0;
        if self.tcp.is_some() {
            len += 1;
        }
        len
    }
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
        w.write_u8(ext_len)?;
        Self::write_exts(w, &self.extensions)?;
        Ok(())
    }
}

impl AdPacket {
    /**
     * Creates a new AdPacket using the given extensions.
     */
    pub fn new(extensions: AdExtensions) -> Self {
        Self { extensions }
    }

    fn read_exts(r: &mut dyn std::io::Read, ext_len: u8) -> Result<AdExtensions, AdPacketError> {
        use byteorder::{ReadBytesExt, BE};
        use num_traits::FromPrimitive;
        let mut exts = AdExtensions::default();
        for _ in 0..ext_len {
            let ty = r.read_u8()?;
            let ty = AdExtensionType::from_u8(ty).ok_or(AdExtensionError::InvalidType(ty))?;
            use AdExtensionType::*;
            match ty {
                TCP => {
                    let len = r.read_u8()?;
                    if len != TCPAdExtension::SIZE {
                        return Err(AdExtensionError::InvalidSize(ty, len).into());
                    }
                    let port = r.read_u16::<BE>()?;
                    exts.tcp = Some(TCPAdExtension { ad_port: port });
                }
            }
        }
        Ok(exts)
    }

    fn write_exts(w: &mut dyn std::io::Write, exts: &AdExtensions) -> Result<(), AdPacketError> {
        use byteorder::{WriteBytesExt, BE};
        if let Some(ref tcp) = exts.tcp {
            w.write_u8(AdExtensionType::TCP as _)?;
            w.write_u8(TCPAdExtension::SIZE)?;
            w.write_u16::<BE>(tcp.ad_port)?;
        }
        Ok(())
    }
}

#[derive(Error, Debug)]
pub enum AdPacketError {
    #[error("{0}")]
    IO(#[from] std::io::Error),
    #[error("{0}")]
    AdExtension(#[from] AdExtensionError),
}

#[derive(Error, Debug)]
pub enum AdExtensionError {
    #[error("Invalid extension type {0}")]
    InvalidType(u8),
    #[error("Invalid extension size for {0:#?} (got {1})")]
    InvalidSize(AdExtensionType, u8),
}

#[cfg(test)]
mod test {
    use super::*;

    mod packet {
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
            let packet = AdPacket::new(AdExtensions::default());
            let mut out = Vec::new();
            let expected = [0];
            packet.write(&mut out).unwrap();
            assert_eq!(out, expected);
        }
    }

    mod ext {
        use super::*;

        #[test]
        fn test_tcp_read() {
            let port: u16 = 14678;
            let data = [
                1, /* ext_len */
                /* tcp extension */
                AdExtensionType::TCP as _,
                TCPAdExtension::SIZE,
                ((port >> 8) & 0xff) as _,
                (port & 0xff) as _,
            ];
            let mut cursor = std::io::Cursor::new(data);
            let packet = AdPacket::read(&mut cursor).unwrap();
            assert_eq!(packet.extensions.len(), 1);
            match packet.extensions.tcp {
                Some(TCPAdExtension { ad_port: port2 }) => assert_eq!(port2, port),
                _ => assert!(false),
            }
        }

        #[test]
        fn test_tcp_write() {
            let tcp_ext = TCPAdExtension { ad_port: 14678 };
            let exts = AdExtensions {
                tcp: Some(tcp_ext.clone()),
            };
            let expected = [
                1, /* ext_len */
                /* tcp extension */
                AdExtensionType::TCP as _,
                TCPAdExtension::SIZE,
                ((tcp_ext.ad_port >> 8) & 0xff) as _,
                (tcp_ext.ad_port & 0xff) as _,
            ];
            let mut out = Vec::new();
            let packet = AdPacket::new(exts);
            packet.write(&mut out).unwrap();
            assert_eq!(&out, &expected);
        }
    }
}
