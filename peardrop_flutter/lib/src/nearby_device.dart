// this file will contain all releavnt info for nearby devices (for now just dummy data)

import 'package:flutter/cupertino.dart';

class Device {
  String device_name;
  IconData icon_name;

  Device(dn, icon) {
    device_name = dn;
    icon_name = icon;
  }

  String getName() {
    return device_name;
  }

  IconData getIcon() {
    return icon_name;
  }
}
