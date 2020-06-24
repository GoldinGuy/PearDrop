import 'dart:io' show Platform;
import 'dart:ffi';

import 'package:ffi/ffi.dart';

final String _libraryPath =
Platform.isAndroid ? "libpeardrop_capi.so" :
Platform.isMacOS ? "libpeardrop_capi.dylib" :
Platform.isLinux ? "libpeardrop_capi.so" :
Platform.isWindows ? "libpeardrop_capi.dll" : null;
final DynamicLibrary _peardropNative = Platform.isIOS
    ? DynamicLibrary.process()
    : DynamicLibrary.open(_libraryPath);

F _nativeF<F>(String name) { return _peardropNative.lookupFunction(name); }

// For all the platforms we use, (u)intptr_t is equivalent to uint64_t since
// we are only using 64-bit platforms (save android i686, but idk about that).
// TODO: Fix

final native_ackpacket_create = _nativeF<Pointer<Void> Function(Pointer<Void>)>("ackpacket_create");
final native_ackpacket_ext_tcp_get = _nativeF<Int32 Function(Pointer<Void>, Pointer<Uint16>)>("ackpacket_ext_tcp_get");
final native_ackpacket_ext_tcp_update = _nativeF<Int32 Function(Pointer<Void>, Uint16)>("ackpacket_ext_tcp_update");
final native_ackpacket_free = _nativeF<Function(Pointer<Void>)>("ackpacket_free");
final native_ackpacket_read = _nativeF<Pointer<Void> Function(Pointer<Uint8>, Uint64)>("ackpacket_read");
final native_ackpacket_write = _nativeF<Int32 Function(Pointer<Void>, Pointer<Pointer<Uint8>>, Pointer<Uint64>)>("ackpacket_write");

final native_acktype_create_accept = _nativeF<Pointer<Void> Function(Uint8)>("acktype_create_accept");
final native_acktype_create_normal = _nativeF<Pointer<Void> Function(Uint8)>("acktype_create_normal");
final native_acktype_create_reject = _nativeF<Pointer<Void> Function(Uint8)>("acktype_create_reject");
final native_acktype_free = _nativeF<Function(Pointer<Void>)>("acktype_free");
final native_acktype_from_raw = _nativeF<Pointer<Void> Function(Uint8)>("acktype_from_raw");
final native_acktype_get_type = _nativeF<Int32 Function(Pointer<Void>, Pointer<Uint8>)>("acktype_get_type");
final native_acktype_is_accepted = _nativeF<Int32 Function(Pointer<Void>, Pointer<Uint8>)>("acktype_is_accepted");
final native_acktype_to_raw = _nativeF<Int32 Function(Pointer<Void>, Pointer<Uint8>)>("acktype_to_raw");

final native_adpacket_create = _nativeF<Pointer<Void> Function()>("adpacket_create");
final native_adpacket_ext_tcp_get = _nativeF<Int32 Function(Pointer<Void>, Pointer<Uint16>)>("adpacket_ext_tcp_get");
final native_adpacket_ext_tcp_update = _nativeF<Int32 Function(Pointer<Void>, Uint16)>("adpacket_ext_tcp_update");
final native_adpacket_free = _nativeF<Function(Pointer<Void>)>("adpacket_free");
final native_adpacket_read = _nativeF<Pointer<Void> Function(Pointer<Uint8>, Uint64)>("adpacket_read");
final native_adpacket_write = _nativeF<Int32 Function(Pointer<Void>, Pointer<Pointer<Uint8>>, Pointer<Uint64>)>("adpacket_write");

final native_senderpacket_create = _nativeF<Pointer<Void> Function(Pointer<Utf8>, Pointer<Utf8>, Uint64)>("senderpacket_create");
final native_senderpacket_free = _nativeF<Function(Pointer<Void>)>("senderpacket_free");
final native_senderpacket_get_data_length = _nativeF<Int32 Function(Pointer<Void>, Pointer<Uint64>)>("senderpacket_get_data_length");
final native_senderpacket_get_filename = _nativeF<Pointer<Utf8> Function(Pointer<Void>)>("senderpacket_get_filename");
final native_senderpacket_get_mimetype = _nativeF<Pointer<Utf8> Function(Pointer<Void>)>("senderpacket_get_mimetype");
final native_senderpacket_read = _nativeF<Pointer<Void> Function(Pointer<Uint8>, Uint64)>("senderpacket_read");
final native_senderpacket_write = _nativeF<Int32 Function(Pointer<Void>, Pointer<Pointer<Uint8>>, Pointer<Uint64>)>("senderpacket_write");

final native_string_free = _nativeF<Function(Pointer<Utf8>)>("string_free");