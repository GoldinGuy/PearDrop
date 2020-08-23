// this file contains all relevant info for nearby devices

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:peardrop/src/utilities/word_list.dart';

enum SharingState { neutral, sharing, done, failed }

class Device {
  IconData _iconName;
  InternetAddress _ipAddress;
  PeardropReceiver _receiver;
  SharingState state;

  Device(IconData icon, PeardropReceiver receive) {
    _receiver = receive;
    _ipAddress = receive.ip;
    _iconName = icon;
    state = SharingState.neutral;
  }

  Device.dummy(IconData icon, InternetAddress address) {
    _ipAddress = address;
    _iconName = icon;
    state = SharingState.neutral;
  }

  String get name {
    return WordList.ipToWords(ip);
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
