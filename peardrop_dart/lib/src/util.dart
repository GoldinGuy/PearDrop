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

/// Copies a List<int> into a C-heap buffer.
Pointer<Uint8> cbcopy(List<int> buffer) {
  Pointer<Uint8> cbuffer = allocate(count: buffer.length);
  memcpy(buffer, cbuffer.asTypedList(buffer.length));
  return cbuffer;
}

/// Copies a C-heap buffer into a List<int>.
List<int> bbcopy(Pointer<Uint8> ptr, int length) {
  List<int> buffer = List(length);
  memcpy(ptr.asTypedList(length), buffer);
  return buffer;
}