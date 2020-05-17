use super::Marshal;
use thiserror::Error;

/**
 * Acknowledgement packet extension.
 *
 * Empty as it is implemented by other structs.
 *
 * TODO: Add Error type.
 */
pub trait AckExtension: std::fmt::Debug {}

/**
 * Receiver acknowledge packet.
 * See the core protocol.
 */
#[derive(Debug)]
pub struct AckPacket {
    type_: AckType,
    extensions: Vec<Box<dyn AckExtension>>,
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
        if ext_len != 0 {
            unimplemented!();
        }
        let double_nibble = (u8::from(self.type_.raw()) << 4) | ext_len as u8;
        w.write_u8(double_nibble)?;
        Ok(())
    }
}

impl AckPacket {
    /**
     * Creates a new AckPacket using the given type and extensions.
     */
    pub fn new(type_: AckType, extensions: Vec<Box<dyn AckExtension>>) -> Self {
        Self { type_, extensions }
    }

    fn read_exts(
        _r: &mut dyn std::io::Read,
        ext_len: ux::u4,
    ) -> Result<Vec<Box<dyn AckExtension>>, AckPacketError> {
        // TODO: implement
        if ext_len != ux::u4::new(0) {
            unimplemented!()
        } else {
            Ok(Vec::new())
        }
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
}

/**
 * Error while constructing an AckType.
 */
#[derive(Error, Debug)]
pub enum AckTypeError {
    #[error("Invalid acknowledgement type")]
    InvalidType,
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
            .ok_or(AckTypeError::InvalidType)
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
            let type_raw = 1 << 3 | AckTypeType::AdPacket as u8;
            let data = [type_raw << 4 | 0 /* ext_len */];
            let mut cursor = std::io::Cursor::new(data);
            let packet = AckPacket::read(&mut cursor).unwrap();
            assert_eq!(packet.extensions.len(), 0);
            assert_eq!(packet.get_type().get_type(), AckTypeType::AdPacket);
            assert_eq!(packet.get_type().is_accepted(), Some(true));
            assert_eq!(packet.get_type().raw(), ux::u4::new(type_raw));
        }

        #[test]
        fn test_write() {
            let type_ = AckType::Normal(AckTypeType::DataPacket);
            let packet = AckPacket::new(type_, Vec::new());
            let mut out = Vec::new();
            let expected = [u8::from(type_.raw()) << 4 | 0];
            packet.write(&mut out).unwrap();
            assert_eq!(out, expected);
        }
    }
}
