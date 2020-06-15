// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/utilities/word_list.dart';

class Device {
  String ipAddress, deviceName;
  IconData iconName;

  Device(icon, ip) {
    deviceName = WordList().ipToWords(ip);
    ipAddress = ip;
    iconName = icon;
  }

  String getName() {
    return deviceName;
  }

  String getIP() {
    return ipAddress;
  }

  IconData getIcon() {
    return iconName;
  }
}
