use thiserror::Error;

/**
 * Acknowledgement packet extension.
 *
 * Empty as it is implemented by other structs.
 */
pub trait AckExtension: super::Extension {}

/**
 * Receiver acknowledge packet.
 * See the core protocol.
 */
pub struct AckPacket {
    type_: AckType,
    extensions: Vec<Box<dyn AckExtension>>,
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
pub enum AckType {
    AcceptReject(AckTypeType, bool),
    Normal(AckTypeType),
}

impl AckType {
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
}

/**
 * Packet type of AckType.
 * See the core protocol.
 */
#[repr(u8)] // should really be u3/u4 but Rust won't allow me to specify it
#[derive(num_derive::FromPrimitive)]
pub enum AckTypeType {
    SenderPacket,
    DataPacket,
    AdPacket,
}
