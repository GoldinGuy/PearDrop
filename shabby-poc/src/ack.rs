use super::{Marshal, Size};
use thiserror::Error;

/**
 * TCP acknowledgement packet extension.
 * See network extensions.
 */
#[derive(Debug, Clone)]
pub struct TCPAckExtension {
    pub ad_port: u16,
}

impl Size for TCPAckExtension {
    const SIZE: u8 = std::mem::size_of::<u16>() as _;
}

/**
 * Type of the acknowledgement packet extension.
 */
#[repr(u8)]
#[derive(num_derive::FromPrimitive, Debug, Copy, Clone, PartialEq, Eq)]
pub enum AckExtensionType {
    TCP,
}

/**
 * Receiver acknowledge packet.
 * See the core protocol.
 */
#[derive(Debug, Clone)]
pub struct AckPacket {
    type_: AckType,
    pub extensions: AckExtensions,
}

#[derive(Debug, Clone, Default)]
pub struct AckExtensions {
    pub tcp: Option<TCPAckExtension>,
}

impl AckExtensions {
    pub fn len(&self) -> u8 {
        let mut len = 0;
        if self.tcp.is_some() {
            len += 1;
        }
        len
    }
}

impl Marshal for AckPacket {
    type Error = AckPacketError;

    /**
     * Reads an AckPacket from the given reader.
     */
    fn read(r: &mut dyn std::io::Read) -> Result<Self, Self::Error> {
        use byteorder::ReadBytesExt;
        use ux::u4;
        /* type + ext len */
        let double_nibble = r.read_u8()?;
        let type_ = AckType::new(u4::new((double_nibble & 0xf0) >> 4))?;
        let ext_len = u4::new(double_nibble & 0xf);
        let exts = Self::read_exts(r, ext_len)?;
        Ok(Self::new(type_, exts))
    }

    /**
     * Writes this AckPacket to the given writer.
     */
    fn write(&self, w: &mut dyn std::io::Write) -> Result<(), Self::Error> {
        use byteorder::WriteBytesExt;
        let ext_len = self.extensions.len();
        let double_nibble = (u8::from(self.type_.raw()) << 4) | ext_len;
        w.write_u8(double_nibble)?;
        Self::write_exts(w, &self.extensions)?;
        Ok(())
    }
}

impl AckPacket {
    /**
     * Creates a new AckPacket using the given type and extensions.
     */
    pub fn new(type_: AckType, exts: AckExtensions) -> Self {
        Self {
            type_,
            extensions: exts,
        }
    }

    fn read_exts(
        r: &mut dyn std::io::Read,
        ext_len: ux::u4,
    ) -> Result<AckExtensions, AckPacketError> {
        use byteorder::{ReadBytesExt, BE};
        use num_traits::FromPrimitive;
        let mut exts = AckExtensions::default();
        for _ in 0..(u8::from(ext_len)) {
            let ty = r.read_u8()?;
            let ty = AckExtensionType::from_u8(ty).ok_or(AckExtensionError::InvalidType(ty))?;
            use AckExtensionType::*;
            match ty {
                TCP => {
                    let len = r.read_u8()?;
                    if len != TCPAckExtension::SIZE {
                        return Err(AckExtensionError::InvalidSize(ty, len).into());
                    }
                    let port = r.read_u16::<BE>()?;
                    exts.tcp = Some(TCPAckExtension { ad_port: port });
                }
            }
        }
        Ok(exts)
    }

    fn write_exts(w: &mut dyn std::io::Write, exts: &AckExtensions) -> Result<(), AckPacketError> {
        use byteorder::{WriteBytesExt, BE};
        if let Some(ref tcp) = exts.tcp {
            w.write_u8(AckExtensionType::TCP as _)?;
            w.write_u8(TCPAckExtension::SIZE)?;
            w.write_u16::<BE>(tcp.ad_port)?;
        }
        Ok(())
    }

    /**
     * Get the type of this AckPacket.
     */
    pub fn get_type(&self) -> AckType {
        self.type_
    }
}

/**
 * Error while constructing an AckPacket.
 */
#[derive(Error, Debug)]
pub enum AckPacketError {
    #[error("{0}")]
    AckType(#[from] AckTypeError),
    #[error("IO error: {0}")]
    IO(#[from] std::io::Error),
    #[error("{0}")]
    AckExtension(#[from] AckExtensionError),
}

#[derive(Error, Debug)]
pub enum AckExtensionError {
    #[error("Invalid extension type {0}")]
    InvalidType(u8),
    #[error("Invalid extension size for {0:#?} (got {1})")]
    InvalidSize(AckExtensionType, u8),
}

/**
 * Error while constructing an AckType.
 */
#[derive(Error, Debug)]
pub enum AckTypeError {
    #[error("Invalid acknowledgement type {0}")]
    InvalidType(u8),
}

/**
 * Type of receiver acknowledge packet.
 * See the core protocol.
 */
#[derive(Debug, Copy, Clone)]
pub enum AckType {
    AcceptReject(AckTypeType, bool),
    Normal(AckTypeType),
}

impl AckType {
    /**
     * Creates a new AckType from the given raw u4.
     */
    pub fn new(raw: ux::u4) -> Result<Self, AckTypeError> {
        use num_traits::FromPrimitive;
        // Try to parse low 3 bits
        let low = u8::from(raw) & 0b111;
        if let Some(ty) = AckTypeType::from_u8(low) {
            use AckTypeType::*;
            // Check if it is accept/reject
            match ty {
                SenderPacket | AdPacket => {
                    Ok(Self::AcceptReject(ty, u8::from(raw) & 0b1000 == 0b1000))
                }
                _ => Self::normal(raw),
            }
        } else {
            // Attempt to parse all 4 bits or Err
            Self::normal(raw)
        }
    }

    // To prevent copy-and-paste in new
    fn normal(raw: ux::u4) -> Result<Self, AckTypeError> {
        use num_traits::FromPrimitive;
        AckTypeType::from_u8(raw.into())
            .map(Self::Normal)
            .ok_or(AckTypeError::InvalidType(raw.into()))
    }

    /**
     * Get the type of this AckType.
     */
    pub fn get_type(&self) -> AckTypeType {
        match *self {
            Self::AcceptReject(x, _) => x,
            Self::Normal(x) => x,
        }
    }

    /**
     * Gets whether this is an accept or reject.
     */
    pub fn is_accepted(&self) -> Option<bool> {
        match *self {
            Self::AcceptReject(_, x) => Some(x),
            _ => None,
        }
    }

    /**
     * Convert this into a raw u4.
     */
    pub fn raw(&self) -> ux::u4 {
        use ux::u4;
        match *self {
            Self::AcceptReject(ty, ar) => u4::new((ar as u8) << 3) | u4::new(ty as u8),
            Self::Normal(ty) => u4::new(ty as u8),
        }
    }
}

/**
 * Packet type of AckType.
 * See the core protocol.
 */
#[repr(u8)] // should really be u3/u4 but Rust won't allow me to specify it
#[derive(num_derive::FromPrimitive, Debug, Copy, Clone, PartialEq, Eq)]
pub enum AckTypeType {
    SenderPacket,
    DataPacket,
    AdPacket,
}

#[cfg(test)]
mod test {
    use super::*;

    mod type_ {
        use super::*;

        #[test]
        fn test_data() {
            let data = ux::u4::new(AckTypeType::DataPacket as u8);
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::DataPacket);
            assert_eq!(type_.is_accepted(), None);
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_sender_reject() {
            let data = ux::u4::new(0 << 3 | AckTypeType::SenderPacket as u8);
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::SenderPacket);
            assert_eq!(type_.is_accepted(), Some(false));
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_sender_accept() {
            let data = ux::u4::new(1 << 3 | AckTypeType::SenderPacket as u8);
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::SenderPacket);
            assert_eq!(type_.is_accepted(), Some(true));
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_ad_reject() {
            let data = ux::u4::new(0 << 3 | AckTypeType::AdPacket as u8);
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::AdPacket);
            assert_eq!(type_.is_accepted(), Some(false));
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_ad_accept() {
            let data = ux::u4::new(1 << 3 | AckTypeType::AdPacket as u8);
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::AdPacket);
            assert_eq!(type_.is_accepted(), Some(true));
            assert_eq!(type_.raw(), data);
        }
    }

    mod packet {
        use super::*;

        #[test]
        fn test_ext_len() {
            let type_ = AckType::AcceptReject(AckTypeType::AdPacket, true);
            let data = [u8::from(type_.raw()) << 4 | 0 /* ext_len */];
            let mut cursor = std::io::Cursor::new(data);
            let packet = AckPacket::read(&mut cursor).unwrap();
            assert_eq!(packet.extensions.len(), 0);
            assert_eq!(packet.get_type().get_type(), AckTypeType::AdPacket);
            assert_eq!(packet.get_type().is_accepted(), Some(true));
            assert_eq!(packet.get_type().raw(), type_.raw());
        }

        #[test]
        fn test_write() {
            let type_ = AckType::Normal(AckTypeType::DataPacket);
            let packet = AckPacket::new(type_, AckExtensions::default());
            let mut out = Vec::new();
            let expected = [u8::from(type_.raw()) << 4 | 0];
            packet.write(&mut out).unwrap();
            assert_eq!(out, expected);
        }
    }

    mod ext {
        use super::*;

        #[test]
        fn test_tcp_read() {
            let type_ = AckType::AcceptReject(AckTypeType::AdPacket, true);
            let port: u16 = 14678;
            let data = [
                u8::from(type_.raw()) << 4 | 1, /* ext_len */
                /* tcp extension */
                AckExtensionType::TCP as _,
                TCPAckExtension::SIZE,
                ((port >> 8) & 0xff) as _,
                (port & 0xff) as _,
            ];
            let mut cursor = std::io::Cursor::new(data);
            let packet = AckPacket::read(&mut cursor).unwrap();
            assert_eq!(packet.extensions.len(), 1);
            match packet.extensions.tcp {
                Some(TCPAckExtension { ad_port: port2 }) => assert_eq!(port2, port),
                _ => assert!(false),
            }
        }

        #[test]
        fn test_tcp_write() {
            let type_ = AckType::AcceptReject(AckTypeType::AdPacket, true);
            let tcp_ext = TCPAckExtension { ad_port: 14678 };
            let exts = AckExtensions {
                tcp: Some(tcp_ext.clone()),
            };
            let expected = [
                u8::from(type_.raw()) << 4 | 1, /* ext_len */
                /* tcp extension */
                AckExtensionType::TCP as _,
                TCPAckExtension::SIZE,
                ((tcp_ext.ad_port >> 8) & 0xff) as _,
                (tcp_ext.ad_port & 0xff) as _,
            ];
            let mut out = Vec::new();
            let packet = AckPacket::new(type_, exts);
            packet.write(&mut out).unwrap();
            assert_eq!(&out, &expected);
        }
    }
}
