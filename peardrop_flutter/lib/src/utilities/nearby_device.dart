// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'package:flutter/cupertino.dart';

class Device {
  String ipAddress, deviceName;
  IconData iconName;

  Device(dn, icon, ip) {
    deviceName = dn;
    ipAddress = ip;
    iconName = icon;
  }

  setName(name) {
    deviceName = name;
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
