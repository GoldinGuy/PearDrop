use super::*;
use std::ffi::CString;

pub type senderpacket = std::ffi::c_void;

/// Creates a SenderPacket from the given buffer.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn senderpacket_read(buf: *const u8, len: i32) -> *mut senderpacket {
    let s_buf = unsafe { std::slice::from_raw_parts(buf, len as _) };
    let packet = SenderPacket::from_buffer(s_buf);
    match packet {
        // TODO: Error handling
        Err(_) => std::ptr::null_mut(),
        Ok(p) => Box::into_raw(Box::new(p)) as *mut _,
    }
}

/// Writes a SenderPacket to a buffer and returns it.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn senderpacket_write(packet: *const senderpacket, out_buf: *mut *mut u8, out_len: *mut usize) -> i32 {
    if packet.is_null() || out_buf.is_null() || out_len.is_null() {
        return 1;
    }
    let packet = unsafe { &*(packet as *const SenderPacket) };
    let v_buf = packet.to_buffer();
    write_vec(v_buf, out_buf, out_len)
}

/// Frees a SenderPacket.
#[no_mangle]
pub extern "C" fn senderpacket_free(packet: *mut senderpacket) {
    unsafe { Box::from_raw(packet as *mut SenderPacket) };
}

/// Get the data length of a SenderPacket.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn senderpacket_get_data_length(packet: *const senderpacket, out_len: *mut u64) -> i32 {
    if packet.is_null() || out_len.is_null() {
        return 1;
    }
    unsafe {
        let packet = &*(packet as *const SenderPacket);
        *out_len = packet.get_data_len();
    };
    0
}

/// Get the filename of a SenderPacket.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn senderpacket_get_filename(packet: *const senderpacket) -> *mut u8 {
    if packet.is_null() {
        return std::ptr::null_mut();
    }
    let packet = unsafe { &*(packet as *const SenderPacket) };
    // FIXME: Have to copy the string
    // Unwrap is safe because &str cannot contain NUL
    let cs = CString::new(packet.get_filename()).unwrap();
    cs.into_raw() as _
}

/// Get the MIME type of a SenderPacket.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn senderpacket_get_mimetype(packet: *const senderpacket) -> *mut u8 {
    if packet.is_null() {
        return std::ptr::null_mut();
    }
    let packet = unsafe { &*(packet as *const SenderPacket) };
    // FIXME: Have to copy the string
    // Unwrap is safe because &str cannot contain NUL
    let cs = CString::new(packet.get_mimetype()).unwrap();
    cs.into_raw() as _
}
