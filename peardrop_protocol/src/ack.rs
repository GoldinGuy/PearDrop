use deku::prelude::*;
use std::collections::HashSet;

/**
 * Receiver acknowledge packet.
 * See the core protocol.
 */
#[derive(Debug, Clone, DekuRead, DekuWrite)]
#[deku(endian = "big")]
pub struct AckPacket {
    #[deku(
        bits = "4",
        map = "AckType::new",
        writer = "write_acktype(&self.type_, output_is_le, field_bits)"
    )]
    type_: AckType,
    #[deku(
        bits = "4",
        writer = "(self.extensions.len() as u8).write(output_is_le, field_bits)"
    )]
    extensions_len: u8,
    #[deku(count = "extensions_len",
        /* vec <-> hashset */
        map = "|x: Vec<AckExtension>| -> Result<_, DekuError> { Ok(x.into_iter().collect::<HashSet<_>>()) }",
        writer = "write_hashset(&self.extensions, output_is_le, field_bits)"
    )]
    pub extensions: HashSet<AckExtension>,
}

pub const TCP_EXTENSION_TYPE: u8 = 0;

/* Hack because there is no write map for now */
fn write_hashset(
    x: &HashSet<AckExtension>,
    output_is_le: bool,
    bit_size: Option<usize>,
) -> Result<BitVec<Msb0, u8>, DekuError> {
    x.iter()
        .cloned()
        .collect::<Vec<_>>()
        .write(output_is_le, bit_size)
}

fn write_acktype(
    x: &AckType,
    output_is_le: bool,
    bit_size: Option<usize>,
) -> Result<BitVec<Msb0, u8>, DekuError> {
    x.raw().write(output_is_le, bit_size)
}

/**
 * Extension to an advertisement packet.
 * See the core protocol.
 */
#[derive(Debug, Clone, Hash, PartialEq, Eq, DekuRead, DekuWrite)]
#[deku(endian = "big", id_type = "u8")]
#[non_exhaustive]
pub enum AckExtension {
    #[deku(id = "TCP_EXTENSION_TYPE")]
    TCP { ad_port: u16 },
}

impl AckPacket {
    /**
     * Creates a new AckPacket using the given type and extensions.
     */
    pub fn new(type_: AckType, exts: HashSet<AckExtension>) -> Self {
        Self {
            type_,
            extensions_len: exts.len() as _,
            extensions: exts,
        }
    }

    /**
     * Creates an AckPacket from the given buffer.
     */
    pub fn from_buffer(buf: &[u8]) -> Result<Self, DekuError> {
        // NOTE: Don't use TryFrom because it panics on extra data
        let (_, res) = Self::from_bytes((&buf[..], 0))?;
        Ok(res)
    }

    /**
     * Reads an AckPacket from the given reader.
     */
    pub fn read(r: &mut dyn std::io::Read) -> Result<Self, DekuError> {
        // XXX: Keep this updated!
        let mut buf = vec![0; 128];
        r.read(&mut buf)
            .map_err(|_| DekuError::InvalidParam("Failed to read".to_string()))?;
        Self::from_buffer(&buf[..])
    }

    /**
     * Writes an AckPacket to a buffer.
     */
    pub fn to_buffer(&self) -> Result<Vec<u8>, DekuError> {
        use std::convert::TryInto;
        (*self).clone().try_into()
    }

    /**
     * Writes an AckPacket to the given writer.
     */
    pub fn write(&self, w: &mut dyn std::io::Write) -> Result<(), DekuError> {
        use std::convert::TryInto;
        let out: Vec<u8> = (*self).clone().try_into()?;
        w.write_all(&out)
            .map_err(|_| DekuError::InvalidParam("Failed to write".to_string()))
    }

    /**
     * Get the type of this AckPacket.
     */
    pub fn get_type(&self) -> AckType {
        self.type_
    }
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
    pub fn new(raw: u8) -> Result<Self, DekuError> {
        use num_traits::FromPrimitive;
        // Try to parse low 3 bits
        let low = raw & 0b111;
        if let Some(ty) = AckTypeType::from_u8(low) {
            use AckTypeType::*;
            // Check if it is accept/reject
            match ty {
                SenderPacket | AdPacket => Ok(Self::AcceptReject(ty, raw & 0b1000 == 0b1000)),
                _ => Self::normal(raw),
            }
        } else {
            // Attempt to parse all 4 bits or Err
            Self::normal(raw)
        }
    }

    // To prevent copy-and-paste in new
    fn normal(raw: u8) -> Result<Self, DekuError> {
        use num_traits::FromPrimitive;
        AckTypeType::from_u8(raw)
            .map(Self::Normal)
            .ok_or(DekuError::Parse(format!(
                "Invalid acknowledgement type {}",
                raw
            )))
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
     * Convert this into a raw u8.
     */
    pub fn raw(&self) -> u8 {
        match *self {
            Self::AcceptReject(ty, ar) => (ar as u8) << 3 | (ty as u8),
            Self::Normal(ty) => ty as u8,
        }
    }
}

/**
 * Packet type of AckType.
 * See the core protocol.
 */
#[repr(u8)]
#[derive(num_derive::FromPrimitive, Debug, Copy, Clone, PartialEq, Eq)]
pub enum AckTypeType {
    SenderPacket,
    DataPacket,
    AdPacket,
}

#[cfg(test)]
mod test {
    use super::*;
    use std::convert::{TryFrom, TryInto};

    mod type_ {
        use super::*;

        #[test]
        fn test_data() {
            let data = AckTypeType::DataPacket as u8;
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::DataPacket);
            assert_eq!(type_.is_accepted(), None);
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_sender_reject() {
            let data = 0 << 3 | AckTypeType::SenderPacket as u8;
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::SenderPacket);
            assert_eq!(type_.is_accepted(), Some(false));
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_sender_accept() {
            let data = 1 << 3 | AckTypeType::SenderPacket as u8;
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::SenderPacket);
            assert_eq!(type_.is_accepted(), Some(true));
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_ad_reject() {
            let data = 0 << 3 | AckTypeType::AdPacket as u8;
            let type_ = AckType::new(data).unwrap();
            assert_eq!(type_.get_type(), AckTypeType::AdPacket);
            assert_eq!(type_.is_accepted(), Some(false));
            assert_eq!(type_.raw(), data);
        }

        #[test]
        fn test_ad_accept() {
            let data = 1 << 3 | AckTypeType::AdPacket as u8;
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
            let data = [type_.raw() << 4 | 0 /* ext_len */];
            let packet = AckPacket::try_from(&data[..]).unwrap();
            assert_eq!(packet.extensions.len(), 0);
            assert_eq!(packet.get_type().get_type(), AckTypeType::AdPacket);
            assert_eq!(packet.get_type().is_accepted(), Some(true));
            assert_eq!(packet.get_type().raw(), type_.raw());
        }

        #[test]
        fn test_write() {
            let type_ = AckType::Normal(AckTypeType::DataPacket);
            let packet = AckPacket::new(type_, HashSet::new());
            let expected = [type_.raw() << 4 | 0];
            let out: Vec<u8> = packet.try_into().unwrap();
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
                TCP_EXTENSION_TYPE,
                ((port >> 8) & 0xff) as _,
                (port & 0xff) as _,
            ];
            let packet = AckPacket::try_from(&data[..]).unwrap();
            assert_eq!(packet.extensions.len(), 1);
            assert!(packet
                .extensions
                .contains(&AckExtension::TCP { ad_port: port }));
        }

        #[test]
        fn test_tcp_write() {
            let type_ = AckType::AcceptReject(AckTypeType::AdPacket, true);
            let ad_port = 14678;
            let tcp_ext = AckExtension::TCP { ad_port };
            let exts = {
                let mut h = HashSet::new();
                h.insert(tcp_ext);
                h
            };
            let expected = [
                type_.raw() << 4 | 1, /* ext_len */
                /* tcp extension */
                TCP_EXTENSION_TYPE,
                ((ad_port >> 8) & 0xff) as _,
                (ad_port & 0xff) as _,
            ];
            let packet = AckPacket::new(type_, exts);
            let out: Vec<u8> = packet.try_into().unwrap();
            assert_eq!(&out, &expected);
        }
    }
}
