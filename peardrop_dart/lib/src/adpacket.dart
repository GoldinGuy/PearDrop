import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ffi.dart';
import 'util.dart';

/// A packet that advertises the sending of a file.
class AdPacket {
  /// Raw pointer to underlying adpacket_t.
  Pointer<Void> ptr;

  /// Creates an [AdPacket].
  AdPacket() {
    ptr = native_adpacket_create();
    assert(ptr != nullptr, 'Failed to create AdPacket');
  }
  /// Reads an [AdPacket] from the given buffer.
  AdPacket.read(List<Uint8> buffer) {
    var cbuffer = cbcopy(buffer);
    ptr = native_adpacket_read(cbuffer, buffer.length as Uint64);
    assert(ptr != nullptr, 'Failed to read AdPacket');
    free(cbuffer);
  }

  /// Gets the TCP extension's port of this AckPacket, if present.
  int get tcpPort {
    Pointer<Uint16> out = allocate();
    var res = native_adpacket_ext_tcp_get(ptr, out);
    assert((res as int) == 0, 'Failed to get TCP extension of AdPacket');
    var value = out.value;
    free(out);
    return value == 0 ? null : value;
  }
  /// Sets the TCP extension's port of this AckPacket.
  set tcpPort(int newValue) {
    var res = native_adpacket_ext_tcp_update(ptr, newValue as Uint16);
    assert((res as int) == 0, 'Failed to set TCP extension of AdPacket');
  }

  /// Writes this [AckPacket] into a buffer and returns it.
  List<Uint8> write() {
    Pointer<Pointer<Uint8>> cbptr = allocate();
    Pointer<Uint64> clptr = allocate();
    var res = native_adpacket_write(ptr, cbptr, clptr);
    assert((res as int) == 0, 'Failed to write AdPacket');
    var out = bbcopy(cbptr.value, clptr.value);
    free(cbptr);
    free(clptr);
    return out;
  }
}