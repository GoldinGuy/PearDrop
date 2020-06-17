use super::*;

pub type adpacket = std::ffi::c_void;

/// Creates an AdPacket from the given buffer.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn adpacket_read(buf: *const u8, len: i32) -> *mut adpacket {
    let s_buf = unsafe { std::slice::from_raw_parts(buf, len as _) };
    let packet = AdPacket::from_buffer(s_buf);
    match packet {
        // TODO: Error handling
        Err(_) => std::ptr::null_mut(),
        Ok(p) => Box::into_raw(Box::new(p)) as *mut _,
    }
}

/// Creates an AdPacket.
#[no_mangle]
pub extern "C" fn adpacket_create() -> *mut adpacket {
    let packet = AdPacket::new(std::collections::HashSet::new());
    Box::into_raw(Box::new(packet)) as *mut _
}

/// Add or update the TCP extension on an AdPacket.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn adpacket_ext_tcp_update(packet: *mut adpacket, port: u16) -> i32 {
    if packet.is_null() {
        return 1;
    }
    let packet = unsafe { &mut *(packet as *mut AdPacket) };
    // Remove TCP extension if it already exists
    {
        let mut e = None;
        for ext in &packet.extensions {
            match ext {
                // TODO: It may be expensive to clone an extension, look into no-copy
                AdExtension::TCP { ad_port: _ } => e = Some(ext.clone()),
                _ => {},
            }
        }
        if let Some(e) = e {
            packet.extensions.remove(&e);
        }
    }
    // Add new extension
    let ext = AdExtension::TCP { ad_port: port };
    packet.extensions.insert(ext);
    0
}

/// Reads the TCP extension on an AdPacket.
///
/// Returns zero if the extension is not present.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn adpacket_ext_tcp_get(packet: *const adpacket, out_port: *mut u16) -> i32 {
    if packet.is_null() || out_port.is_null() {
        return 1;
    }
    // XXX: Not an unsafe block because let port is completely safe.
    let packet = unsafe { &*(packet as *const AdPacket) };
    let port = packet.extensions.iter().find_map(|x| match x {
        AdExtension::TCP { ad_port: port } => Some(*port),
        _ => None,
    }).unwrap_or_default();
    unsafe { *out_port = port };
    0
}

/// Writes an AdPacket to a buffer and returns it.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn adpacket_write(packet: *const adpacket, out_buf: *mut *mut u8, out_len: *mut usize) -> i32 {
    if packet.is_null() || out_buf.is_null() || out_len.is_null() {
        return 1;
    }
    let packet = unsafe { &*(packet as *const AdPacket) };
    let v_buf = packet.to_buffer();
    write_vec(v_buf, out_buf, out_len)
}

/// Frees an AdPacket.
#[no_mangle]
pub extern "C" fn adpacket_free(packet: *mut adpacket) {
    unsafe { Box::from_raw(packet as *mut AdPacket) };
}