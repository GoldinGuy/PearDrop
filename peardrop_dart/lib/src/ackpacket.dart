import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ffi.dart';
import 'util.dart';
import 'acktype.dart';

/// A packet that acknowledges another packet being received.
class AckPacket {
  /// Raw pointer to underlying ackpacket_t.
  Pointer<Void> ptr;

  /// Creates an [AckPacket] from the given [AckType].
  AckPacket(AckType type) {
    ptr = native_ackpacket_create(type.ptr);
    assert(ptr != nullptr, 'Failed to create AckPacket');
  }

  /// Read an [AckPacket] from the given buffer.
  AckPacket.read(List<int> buffer) {
    // Copy into C buffer
    var cbuffer = cbcopy(buffer);
    ptr = native_ackpacket_read(cbuffer, buffer.length);
    assert(ptr != nullptr, 'Failed to read AckPacket');
    free(cbuffer);
  }

  /// Gets the type of this [AckPacket].
  AckType get type {
    var res = native_ackpacket_get_type(ptr);
    assert(res != nullptr, 'Failed to get type of AckPacket');
    return AckType.ptr(res);
  }

  /// Gets the TCP extension's port of this [AckPacket], if present.
  int get tcpPort {
    Pointer<Uint16> out = allocate();
    var res = native_ackpacket_ext_tcp_get(ptr, out);
    assert(res == 0, 'Failed to get TCP extension of AckPacket');
    var value = out.value;
    free(out);
    return value == 0 ? null : value;
  }

  /// Sets the TCP extension's port of this AckPacket.
  set tcpPort(int newValue) {
    var res = native_ackpacket_ext_tcp_update(ptr, newValue);
    assert(res == 0, 'Failed to set TCP extension of AckPacket');
  }

  /// Writes this [AckPacket] into a buffer and returns it.
  List<int> write() {
    Pointer<Pointer<Uint8>> cbptr = allocate();
    Pointer<Uint64> clptr = allocate();
    var res = native_ackpacket_write(ptr, cbptr, clptr);
    assert(res == 0, 'Failed to write AckPacket');
    var out = bbcopy(cbptr.value, clptr.value);
    free(cbptr);
    free(clptr);
    return out;
  }

  void dispose() {
    native_ackpacket_free(ptr);
  }
}
