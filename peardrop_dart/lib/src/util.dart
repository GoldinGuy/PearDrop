// General utilities shared by most files.
import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Copies the contents of one List<T> into another.
void memcpy<T>(List<T> src, List<T> dst) {
  assert(dst.length >= src.length);
  for (var i = 0; i < src.length; i++) {
    dst[i] = src[i];
  }
}

/// Copies a List<Uint8> into a C-heap buffer.
Pointer<Uint8> cbcopy(List<Uint8> buffer) {
  Pointer<Uint8> cbuffer = allocate(count: buffer.length);
  memcpy(buffer, cbuffer.asTypedList(buffer.length));
  return cbuffer;
}

/// Copies a C-heap buffer into a List<Uint8>.
List<Uint8> bbcopy(Pointer<Uint8> ptr, int length) {
  List<Uint8> buffer = List(length);
  memcpy(ptr.asTypedList(length), buffer);
  return buffer;
}