#![deny(unsafe_code)]

mod ad;
pub use ad::*;

mod ack;
pub use ack::*;

mod sender;
pub use sender::*;

/**
 * Generic extension.
 *
 * Should be able to be read from a Read, and written to a Write.
 */
pub trait Extension: std::fmt::Debug {
    // TODO: add to implementers. Until then, stubbed.
    // type Error = dyn std::error::Error;
    /**
     * Serialize (or write) this extension to a Write.
     */
    fn write(&self, w: &mut dyn std::io::Write) -> Result<(), Box<dyn std::error::Error>>;
    /**
     * Deserialize (or read) this extension from a Read.
     */
    fn read(r: &mut dyn std::io::Read) -> Result<Self, Box<dyn std::error::Error>>
    where
        Self: Sized;
}
