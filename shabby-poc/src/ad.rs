/**
 * Advertisement packet extension.
 *
 * Empty as it is implemented by other structs.
 */
pub trait AdExtension: super::Extension {}

/**
 * Advertisement packet.
 * See the core protocol.
 */
pub struct AdPacket {
    extensions: Vec<Box<dyn AdExtension>>,
}
