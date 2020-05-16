/**
 * Generic extension.
 *
 * Should be able to be read from a Read, and written to a Write.
 */
pub trait Extension {
    /**
     * Serialize (or write) this extension to a Write.
     */
    fn write(&self, w: &mut dyn std::io::Write);
    /**
     * Deserialize (or read) this extension from a Read.
     */
    fn read(r: &mut dyn std::io::Read) -> Self
    where
        Self: Sized;
}
