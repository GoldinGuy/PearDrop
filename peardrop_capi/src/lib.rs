#![allow(non_camel_case_types)]

use peardrop_protocol::*;

// NOTE: All doc-comments are written using "///" so that cbindgen recognizes them

// write a Vec as per the API surface (this is just DRY.)
fn write_vec(v_buf: Result<Vec<u8>, DekuError>, out_buf: *mut *mut u8, out_len: *mut usize) -> i32 {
    match v_buf {
        // TODO: Error handling
        Err(_) => 2,
        Ok(mut v) => {
            // TODO: Replace with Vec::into_raw_parts once stabilized
            unsafe {
                *out_buf = v.as_mut_ptr();
                *out_len = v.len();
            };
            std::mem::forget(v);
            0
        }
    }
}

/// Frees a string previously retrieved from this API.
#[no_mangle]
pub extern "C" fn string_free(s: *mut u8) {
    unsafe { CString::from_raw(s as _) };
}

mod ack;
pub use ack::*;

mod ad;
pub use ad::*;

mod sender;
pub use sender::*;
use std::ffi::CString;
