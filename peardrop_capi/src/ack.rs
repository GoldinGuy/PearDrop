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

/// Creates an AckPacket from the given AckType.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn ackpacket_create(type_: *mut acktype) -> *mut ackpacket {
    if type_.is_null() {
        return std::ptr::null_mut();
    }
    // A: Copy the AckType onto the stack
    let type2 = unsafe { &*(type_ as *const AckType) }.clone();
    // B: Free the AckType provided
    acktype_free(type_);
    let packet = AckPacket::new(type2, std::collections::HashSet::new());
    Box::into_raw(Box::new(packet)) as *mut _
}

/// Add or update the TCP extension on an AckPacket.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn ackpacket_ext_tcp_update(packet: *mut ackpacket, port: u16) -> i32 {
    if packet.is_null() {
        return 1;
    }
    let packet = unsafe { &mut *(packet as *mut AckPacket) };
    // Remove TCP extension if it already exists
    {
        let mut e = None;
        for ext in &packet.extensions {
            match ext {
                // TODO: It may be expensive to clone an extension, look into no-copy
                AckExtension::TCP { ad_port: _ } => e = Some(ext.clone()),
                _ => {},
            }
        }
        if let Some(e) = e {
            packet.extensions.remove(&e);
        }
    }
    // Add new extension
    let ext = AckExtension::TCP { ad_port: port };
    packet.extensions.insert(ext);
    0
}

/// Reads the TCP extension on an AckPacket.
///
/// Returns zero if the extension is not present.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn ackpacket_ext_tcp_get(packet: *const ackpacket, out_port: *mut u16) -> i32 {
    if packet.is_null() || out_port.is_null() {
        return 1;
    }
    // XXX: Not an unsafe block because let port is completely safe.
    let packet = unsafe { &*(packet as *const AckPacket) };
    let port = packet.extensions.iter().find_map(|x| match x {
        AckExtension::TCP { ad_port: port } => Some(*port),
        _ => None,
    }).unwrap_or_default();
    unsafe { *out_port = port };
    0
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

/// Creates an AckType from its raw representation.
///
/// Returns NULL on error.
#[no_mangle]
pub extern "C" fn acktype_from_raw(raw: u8) -> *mut acktype {
    if let Ok(ty) = AckType::new(raw) {
        Box::into_raw(Box::new(ty)) as *mut _
    } else {
        std::ptr::null_mut()
    }
}

/// Gets the raw representation of an AckType.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn acktype_to_raw(type_: *const acktype, out_raw: *mut u8) -> i32 {
    if type_.is_null() || out_raw.is_null() {
        return 1;
    }
    unsafe {
        let type_ = &*(type_ as *const AckType);
        *out_raw = type_.raw();
    };
    0
}

/// Gets the type of an AckType.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn acktype_get_type(type_: *const acktype, out_type: *mut u8) -> i32 {
    if type_.is_null() || out_type.is_null() {
        return 1;
    }
    unsafe {
        let type_ = &*(type_ as *const AckType);
        *out_type = type_.get_type() as _;
    };
    0
}

/// Gets whether an AckType is accepted.
///
/// Additionally, returns false if the type of the given AckType is not an accept/reject type.
///
/// Returns non-zero on error.
#[no_mangle]
pub extern "C" fn acktype_is_accepted(type_: *const acktype, out_is_accepted: *mut u8) -> i32 {
    if type_.is_null() || out_is_accepted.is_null() {
        return 1;
    }
    unsafe {
        let type_ = &*(type_ as *const AckType);
        *out_is_accepted = type_.is_accepted().unwrap_or_default() as _;
    };
    0
}

/// Frees an AckType.
#[no_mangle]
pub extern "C" fn acktype_free(type_: *mut acktype) {
    unsafe { Box::from_raw(type_ as *mut AckType) };
}