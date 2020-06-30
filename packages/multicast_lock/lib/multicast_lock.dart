import 'dart:async';

import 'package:flutter/services.dart';

/// Allows an application to receive Wifi Multicast packets. Normally the Wifi
/// stack filters out packets not explicitly addressed to this device. Acquring
/// a MulticastLock will cause the stack to receive packets addressed to
/// multicast addresses. Processing these extra packets can cause a noticeable
/// battery drain and should be disabled when not needed.
class MulticastLock {

  static const MethodChannel _channel = const MethodChannel('multicast_lock');
  static MulticastLock _instance;

  factory MulticastLock() {
    if (_instance == null) {
      _instance = MulticastLock.private();
    }
    return _instance;
  }

  MulticastLock.private();

  /// Locks Wifi Multicast on until release() is called.
  Future<void> acquire() async {
    await _channel.invokeMethod('acquire');
  }

  /// Unlocks Wifi Multicast, restoring the filter of packets not addressed specifically to this device and saving power.
  Future<void> release() async {
    await _channel.invokeMethod('release');
  }

  /// Checks whether this MulticastLock is currently held.
  Future<bool> isHeld() async {
    final bool result = await _channel.invokeMethod('isHeld');
    return result;
  }
}

