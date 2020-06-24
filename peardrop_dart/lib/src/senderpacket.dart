import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ffi.dart';
import 'util.dart';

/// A packet that contains information about the file being sent.
class SenderPacket {
  /// Raw pointer to underlying senderpacket_t.
  Pointer<Void> ptr;

  /// Creates a [SenderPacket] from the given filename, MIME type and data length.
  SenderPacket(String filename, String mimetype, int data_len) {
    Pointer<Utf8> cfilename = Utf8.toUtf8(filename);
    Pointer<Utf8> cmimetype = Utf8.toUtf8(mimetype);
    ptr = native_senderpacket_create(cfilename, cmimetype, data_len);
    assert(ptr != nullptr, 'Failed to create SenderPacket');
    free(cfilename);
    free(cmimetype);
  }
  /// Reads a [SenderPacket] from the given buffer.
  SenderPacket.read(List<int> buffer) {
    var cbuffer = cbcopy(buffer);
    ptr = native_senderpacket_read(cbuffer, buffer.length);
    assert(ptr != nullptr, 'Failed to read SenderPacket');
    free(cbuffer);
  }

  /// Gets the filename of this [SenderPacket].
  String get filename {
    var res = native_senderpacket_get_filename(ptr);
    assert(res != nullptr, 'Failed to get filename of SenderPacket');
    var value = Utf8.fromUtf8(res);
    native_string_free(res);
    return value;
  }

  /// Gets the MIME type of this [SenderPacket].
  String get mimetype {
    var res = native_senderpacket_get_mimetype(ptr);
    assert(res != nullptr, 'Failed to get MIME type of SenderPacket');
    var value = Utf8.fromUtf8(res);
    native_string_free(res);
    return value;
  }

  /// Gets the data length of this [SenderPacket].
  int get data_len {
    Pointer<Uint64> out = allocate();
    var res = native_senderpacket_get_data_length(ptr, out);
    assert(res == 0, 'Failed to get data length of SenderPacket');
    var value = out.value;
    free(out);
    return value;
  }

  /// Writes this [SenderPacket] into a buffer and returns it.
  List<int> write() {
    Pointer<Pointer<Uint8>> cbptr = allocate();
    Pointer<Uint64> clptr = allocate();
    var res = native_senderpacket_write(ptr, cbptr, clptr);
    assert(res == 0, 'Failed to write SenderPacket');
    var out = bbcopy(cbptr.value, clptr.value);
    free(cbptr);
    free(clptr);
    return out;
  }

  void dispose() {
    native_senderpacket_free(ptr);
  }
}