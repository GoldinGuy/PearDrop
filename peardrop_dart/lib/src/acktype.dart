import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'ffi.dart';

/// The type of an [AckType].
enum AckTypeType {
  SENDER_PACKET,
  DATA_PACKET,
  AD_PACKET,
}

/// Type of packet an [AckPacket] is acknowledging.
class AckType {
  /// Raw pointer to underlying acktype_t.
  Pointer<Void> ptr;

  /// Create a normal [AckType].
  AckType.normal(AckTypeType type2) {
    ptr = native_acktype_create_normal(type2 as Uint8);
    assert(ptr != nullptr, 'Failed to create normal acktype');
  }
  /// Create an [AckType] that accepts.
  AckType.accept(AckTypeType type2) {
    ptr = native_acktype_create_accept(type2 as Uint8);
    assert(ptr != nullptr, 'Failed to create accept acktype');
  }
  /// Create an [AckType] that rejects.
  AckType.reject(AckTypeType type2) {
    ptr = native_acktype_create_reject(type2 as Uint8);
    assert(ptr != nullptr, 'Failed to create reject acktype');
  }
  /// Creates an [AckType] from a raw value.
  AckType.raw(Uint8 raw) {
    ptr = native_acktype_from_raw(raw);
    assert(ptr != nullptr, 'Failed to create acktype from raw');
  }

  /// Get the type of this [AckType].
  AckTypeType get type {
    Pointer<Uint8> out = allocate();
    var res = native_acktype_get_type(ptr, out);
    assert((res as int) == 0, 'Failed to get type of acktype');
    AckTypeType value = out.value as AckTypeType;
    free(out);
    return value;
  }

  /// Get the raw value of this [AckType].
  int get raw {
    Pointer<Uint8> out = allocate();
    var res = native_acktype_to_raw(ptr, out);
    assert((res as int) == 0, 'Failed to get raw of acktype');
    int value = out.value;
    free(out);
    return value;
  }

  void dispose() {
    native_acktype_free(ptr);
  }
}