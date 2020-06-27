// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:peardrop/src/utilities/word_list.dart';

class Device {
  String _deviceName;
  IconData _iconName;
  InternetAddress _ipAddress;
  PeardropReceiver _receiver;

  Device(IconData icon, PeardropReceiver receive) {
    _receiver = receive;
    _deviceName = WordList().ipToWords(receive.ip);
    _ipAddress = receive.ip;
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

  PeardropReceiver getReceiver() {
    return _receiver;
  }
}
