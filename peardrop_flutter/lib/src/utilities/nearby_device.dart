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
  SharingState _state;

  Device(IconData icon, PeardropReceiver receive) {
    _receiver = receive;
    _deviceName = WordList().ipToWords(receive.ip);
    _ipAddress = receive.ip;
    _iconName = icon;
    _state = SharingState.neutral;
  }

  Device.dummy(IconData icon, InternetAddress address) {
    _deviceName = WordList().ipToWords(address);
    _ipAddress = address;
    _iconName = icon;
    _state = SharingState.neutral;
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

  SharingState getSharingState() {
    return _state;
  }

  void setSharingState(SharingState share) {
    _state = share;
  }
}
