use deku::prelude::*;
use std::collections::HashSet;

/**
 * Advertisement packet.
 * See the core protocol.
 */
#[derive(Debug, Clone, DekuRead, DekuWrite)]
#[deku(endian = "big")]
pub struct AdPacket {
    extensions_len: u8,
    #[deku(
        count = "extensions_len",
        /* vec <-> hashset */
        map = "|x: Vec<AdExtension>| -> Result<_, DekuError> { Ok(x.into_iter().collect::<HashSet<_>>()) }",
        writer = "write_hashset(&self.extensions, output_is_le, field_bits)"
    )]
    pub extensions: HashSet<AdExtension>,
}

pub const TCP_EXTENSION_TYPE: u8 = 0;

/* Hack because there is no write map for now */
fn write_hashset(
    x: &HashSet<AdExtension>,
    output_is_le: bool,
    bit_size: Option<usize>,
) -> Result<BitVec<Msb0, u8>, DekuError> {
    x.iter()
        .cloned()
        .collect::<Vec<_>>()
        .write(output_is_le, bit_size)
}

/**
 * Extension to an advertisement packet.
 * See the core protocol.
 */
#[derive(Debug, Clone, Hash, PartialEq, Eq, DekuRead, DekuWrite)]
#[deku(endian = "big", id_type = "u8")]
#[non_exhaustive]
pub enum AdExtension {
    #[deku(id = "TCP_EXTENSION_TYPE")]
    TCP { ad_port: u16 },
}

impl AdPacket {
    /**
     * Creates a new AdPacket using the given extensions.
     */
    pub fn new(extensions: HashSet<AdExtension>) -> Self {
        Self {
            extensions_len: extensions.len() as _,
            extensions,
        }
    }

    /**
     * Reads an AdPacket from the given reader.
     */
    pub fn read(r: &mut dyn std::io::Read) -> Result<Self, DekuError> {
        // XXX: Keep this updated!
        let mut buf = vec![0; 128];
        r.read(&mut buf)
            .map_err(|_| DekuError::InvalidParam("Failed to read".to_string()))?;
        use std::convert::TryFrom;
        Self::try_from(&buf[..])
    }

    /**
     * Writes an AdPacket to the given writer.
     */
    pub fn write(&self, w: &mut dyn std::io::Write) -> Result<(), DekuError> {
        use std::convert::TryInto;
        let out: Vec<u8> = (*self).clone().try_into()?;
        w.write_all(&out)
            .map_err(|_| DekuError::InvalidParam("Failed to write".to_string()))
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use std::convert::{TryFrom, TryInto};

    mod packet {
        use super::*;

        #[test]
        fn test_read() {
            let data = [0 /* ext_len */];
            let packet = AdPacket::try_from(&data[..]).unwrap();
            assert_eq!(packet.extensions.len(), 0);
        }

        #[test]
        fn test_write() {
            let packet = AdPacket::new(HashSet::new());
            let out: Vec<u8> = packet.try_into().unwrap();
            let expected = [0];
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
                TCP_EXTENSION_TYPE, /* type = tcp */
                ((port >> 8) & 0xff) as _,
                (port & 0xff) as _,
            ];
            let packet = AdPacket::try_from(&data[..]).unwrap();
            assert_eq!(packet.extensions.len(), 1);
            assert!(packet
                .extensions
                .contains(&AdExtension::TCP { ad_port: port }));
        }

        #[test]
        fn test_tcp_write() {
            let ad_port = 14678;
            let tcp_ext = AdExtension::TCP { ad_port };
            let exts = {
                let mut h = HashSet::new();
                h.insert(tcp_ext);
                h
            };
            let expected = [
                1, /* ext_len */
                /* tcp extension */
                TCP_EXTENSION_TYPE, /* type = tcp */
                ((ad_port >> 8) & 0xff) as _,
                (ad_port & 0xff) as _,
            ];
            let packet = AdPacket::new(exts);
            let out: Vec<u8> = packet.try_into().unwrap();
            assert_eq!(out, expected);
        }
    }
}
