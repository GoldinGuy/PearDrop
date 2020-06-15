import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:peardrop/src/devices_page.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(new DevicesPage());
}
