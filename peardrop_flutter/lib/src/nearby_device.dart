// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'package:flutter/cupertino.dart';

class Device {
  String deviceName;
  IconData iconName;

  Device(dn, icon) {
    deviceName = dn;
    iconName = icon;
  }

  String getName() {
    return deviceName;
  }

  IconData getIcon() {
    return iconName;
  }
}
