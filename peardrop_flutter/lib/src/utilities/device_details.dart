import 'dart:io';

import 'package:device_info/device_info.dart';

class DeviceDetails {
  // DeviceDetails({this.deviceId});
  static String deviceId = 'device';

  static Future<String> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = androidDeviceInfo.brand; // unique ID on Android
    }
    return deviceId;
  }
}
