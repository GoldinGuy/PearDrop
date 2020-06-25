import 'dart:io';

import 'package:device_info/device_info.dart';

class DeviceDetails {
  // DeviceDetails({this.deviceId});
  static String deviceId = 'device';

  static Future<void> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.name; // unique ID on iOS
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = androidDeviceInfo.product; // unique ID on Android
    }
  }
}
