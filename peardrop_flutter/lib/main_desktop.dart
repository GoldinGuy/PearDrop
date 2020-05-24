import 'package:peardrop/src/circle.dart';
import 'package:peardrop/src/devices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(new DevicesPage());
}
