#![deny(unsafe_code)]

mod ad;
pub use ad::*;

mod ack;
pub use ack::*;

mod sender;
pub use sender::*;

/**
 * Generic interface for marshalling objects.
 *
 * Why not Serde? Because we are not going through another format for encoding.
 * We're just writing this as bytes to a stream. Therefore each object
 * serializes itself differently.
 *
 * Should implement Debug.
 */
pub trait Marshal: std::fmt::Debug {
    type Error;
    /**
     * Marshal this object to a Write.
     */
    fn write(&self, w: &mut dyn std::io::Write) -> Result<(), Self::Error>;
    /**
     * Unmarshal this object from a Read.
     */
    fn read(r: &mut dyn std::io::Read) -> Result<Self, Self::Error>
    where
        Self: Sized;
}
