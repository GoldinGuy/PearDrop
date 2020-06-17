use super::*;

pub type ackpacket = std::ffi::c_void;

/// Creates an AckPacket from the given buffer.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn ackpacket_read(buf: *const u8, len: usize) -> *mut ackpacket {
    let s_buf = unsafe { std::slice::from_raw_parts(buf, len) };
    let packet = AckPacket::from_buffer(s_buf);
    match packet {
        // TODO: Error handling
        Err(_) => std::ptr::null_mut(),
        Ok(p) => Box::into_raw(Box::new(p)) as *mut _,
    }
}

/// Writes an AckPacket to a buffer and returns it.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn ackpacket_write(packet: *const ackpacket, out_buf: *mut *mut u8, out_len: *mut usize)
    -> i32 {
    if packet.is_null() || out_buf.is_null() || out_len.is_null() {
        return 1;
    }
    let packet = unsafe { &*(packet as *const AckPacket) };
    let v_buf = packet.to_buffer();
    write_vec(v_buf, out_buf, out_len)
}

/// Frees an AckPacket.
#[no_mangle]
pub extern "C" fn ackpacket_free(packet: *mut ackpacket) {
    unsafe { Box::from_raw(packet as *mut AckPacket) };
}

pub use peardrop_protocol::AckTypeType; // reexport

pub type acktype = std::ffi::c_void;

/// Creates an AckType that is accepting.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn acktype_create_accept(type_: u8) -> *mut acktype {
    use num_traits::FromPrimitive;
    if let Some(ty) = AckTypeType::from_u8(type_) {
        Box::into_raw(Box::new(AckType::AcceptReject(ty, true))) as *mut _
    } else {
        std::ptr::null_mut()
    }
}

/// Creates an AckType that is rejecting.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn acktype_create_reject(type_: u8) -> *mut acktype {
    use num_traits::FromPrimitive;
    if let Some(ty) = AckTypeType::from_u8(type_) {
        Box::into_raw(Box::new(AckType::AcceptReject(ty, false))) as *mut _
    } else {
        std::ptr::null_mut()
    }
}

/// Creates a normal AckType.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn acktype_create_normal(type_: u8) -> *mut acktype {
    use num_traits::FromPrimitive;
    if let Some(ty) = AckTypeType::from_u8(type_) {
        Box::into_raw(Box::new(AckType::Normal(ty))) as *mut _
    } else {
        std::ptr::null_mut()
    }
}

/// Frees an AckType.
#[no_mangle]
pub extern "C" fn acktype_free(type_: *mut acktype) {
    unsafe { Box::from_raw(type_ as *mut AckType) };
}