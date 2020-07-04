// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:peardrop/src/utilities/word_list.dart';

enum SharingState { neutral, sharing, done }

class Device {
  String _deviceName;
  IconData _iconName;
  InternetAddress _ipAddress;
  PeardropReceiver _receiver;
  SharingState state;

  Device(IconData icon, PeardropReceiver receive) {
    _receiver = receive;
    _deviceName = WordList.ipToWords(receive.ip);
    _ipAddress = receive.ip;
    _iconName = icon;
    state = SharingState.neutral;
  }

  Device.dummy(IconData icon, InternetAddress address) {
    _deviceName = WordList.ipToWords(address);
    _ipAddress = address;
    _iconName = icon;
    state = SharingState.neutral;
  }

  String get name {
    return _deviceName;
  }

  InternetAddress get ip {
    return _ipAddress;
  }

  IconData get icon {
    return _iconName;
  }

  PeardropReceiver get receiver {
    return _receiver;
  }
}
