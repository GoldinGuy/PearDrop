// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/utilities/word_list.dart';

class Device {
  String _deviceName;
  IconData _iconName;
  InternetAddress _ipAddress;

  Device(IconData icon, InternetAddress ip) {
    _deviceName = WordList().ipToWords(ip).toString();
    _ipAddress = ip;
    _iconName = icon;
  }

  String getName() {
    return _deviceName;
  }

  InternetAddress getIP() {
    return _ipAddress;
  }

  IconData getIcon() {
    return _iconName;
  }
}
