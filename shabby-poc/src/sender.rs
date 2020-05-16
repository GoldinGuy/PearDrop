/**
 * Sender packet extension.
 *
 * Empty as it is implemented by other structs.
 *
 * TODO: Add Error type.
 */
pub trait SenderExtension: super::Extension {}

/**
 * Sender packet.
 * See the core protocol.
 */
pub struct SenderPacket {
    filename: String,
    mime_type: String,
    extensions: Vec<Box<dyn SenderExtension>>,
    data_len: u64,
}
