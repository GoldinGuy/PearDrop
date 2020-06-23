import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:peardrop/src/home.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(new HomePage());
}
