use super::*;

/**
 * Creates an AdPacket from the given buffer.
 *
 * Returns NULL on error.
 */
#[no_mangle]
extern "C" fn adpacket_read(buf: *const u8, len: i32) -> *mut AdPacket {
    let s_buf = unsafe { std::slice::from_raw_parts(buf, len as _) };
    let packet = AdPacket::from_buffer(s_buf);
    match packet {
        // TODO: Error handling
        Err(_) => std::ptr::null_mut(),
        Ok(p) => Box::into_raw(Box::new(p)),
    }
}

/**
 * Writes an AdPacket to a buffer and returns it.
 *
 * Returns non-zero on error.
 */
#[no_mangle]
extern "C" fn adpacket_write(packet: *const AdPacket, out_buf: *mut *mut u8, out_len: *mut usize) -> i32 {
    if packet.is_null() || out_buf.is_null() || out_len.is_null() {
        return 1;
    }
    let packet = unsafe { &*packet };
    let v_buf = packet.to_buffer();
    write_vec(v_buf, out_buf, out_len)
}