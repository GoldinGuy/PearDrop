use thiserror::Error;

/**
 * Acknowledgement packet extension.
 *
 * Empty as it is implemented by other structs.
 *
 * TODO: Add Error type.
 */
pub trait AckExtension: super::Extension {}

/**
 * Receiver acknowledge packet.
 * See the core protocol.
 */
#[derive(Debug)]
pub struct AckPacket {
    type_: AckType,
    extensions: Vec<Box<dyn AckExtension>>,
}

impl AckPacket {
    /**
     * Reads an AckPacket from the given reader.
     */
    pub fn new(r: &mut dyn std::io::Read) -> Result<Self, AckPacketError> {
        use byteorder::ReadBytesExt;
        use ux::u4;
        /* type + ext len */
        let double_nibble = r.read_u8()?;
        let type_ = AckType::new(u4::new(double_nibble & 0xf0 >> 4))?;
        let ext_len = u4::new(double_nibble & 0xf);
        let exts = Self::read_exts(r, ext_len)?;
        Ok(Self {
            type_,
            extensions: exts,
        })
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

    #[test]
    fn test_acknowledge_data() {
        let data = [
            // type | ext len
            (AckTypeType::DataPacket as u8) << 4,
        ];
        let mut cursor = std::io::Cursor::new(data);
        let packet = AckPacket::new(&mut cursor).unwrap();
        println!("{:#?}", packet);
        assert_eq!(packet.get_type().get_type(), AckTypeType::DataPacket);
        assert_eq!(packet.get_type().is_accepted(), None);
    }
}
