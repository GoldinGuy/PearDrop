import 'dart:async';

import 'package:flutter/services.dart';

class Peardrop {
  static const MethodChannel _channel =
      const MethodChannel('peardrop');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
