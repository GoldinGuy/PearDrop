import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ffi.dart';

/// The type of an [AckType].
abstract class AckTypeType {
  static const int SENDER_PACKET = 0;
  static const int DATA_PACKET = 1;
  static const int AD_PACKET = 2;
}

/// Type of packet an [AckPacket] is acknowledging.
class AckType {
  /// Raw pointer to underlying acktype_t.
  Pointer<Void> ptr;

  /// Creates an [AckType] from its underlying pointer.
  AckType.ptr(this.ptr);

  /// Create a normal [AckType].
  AckType.normal(int type2) {
    ptr = native_acktype_create_normal(type2);
    assert(ptr != nullptr, 'Failed to create normal AckType');
  }

  /// Create an [AckType] that accepts.
  AckType.accept(int type2) {
    ptr = native_acktype_create_accept(type2);
    assert(ptr != nullptr, 'Failed to create accept AckType');
  }

  /// Create an [AckType] that rejects.
  AckType.reject(int type2) {
    ptr = native_acktype_create_reject(type2);
    assert(ptr != nullptr, 'Failed to create reject AckType');
  }

  /// Creates an [AckType] from a raw value.
  AckType.raw(int raw) {
    ptr = native_acktype_from_raw(raw);
    assert(ptr != nullptr, 'Failed to create AckType from raw');
  }

  /// Get the type of this [AckType].
  int get type {
    Pointer<Uint8> out = allocate();
    var res = native_acktype_get_type(ptr, out);
    assert(res == 0, 'Failed to get type of AckType');
    var value = out.value;
    free(out);
    return value;
  }

  /// Get whether this [AckType] is accepted, will be false if not applicable.
  bool get isAccepted {
    Pointer<Uint8> out = allocate();
    var res = native_acktype_is_accepted(ptr, out);
    assert(res == 0, 'Failed to get whether AckType is accepted');
    bool value = out.value != 0;
    free(out);
    return value;
  }

  /// Get the raw value of this [AckType].
  int get raw {
    Pointer<Uint8> out = allocate();
    var res = native_acktype_to_raw(ptr, out);
    assert(res == 0, 'Failed to get raw value of AckType');
    int value = out.value;
    free(out);
    return value;
  }

  void dispose() {
    native_acktype_free(ptr);
  }
}
