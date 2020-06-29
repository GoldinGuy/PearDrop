import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/home.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

class DeviceProgressIndicator extends StatefulWidget {
  DeviceProgressIndicator({this.fileShare, this.devices, this.i});
  final DeviceSelectCallback fileShare;
  final List<Device> devices;
  final int i;

  @override
  _DeviceProgressIndicatorState createState() => _DeviceProgressIndicatorState(
      fileShare: fileShare, devices: devices, i: i);
}

typedef void DeviceSelectCallback(int index);

class _DeviceProgressIndicatorState extends State<DeviceProgressIndicator>
    with TickerProviderStateMixin {
  double percentage = 0.0, newPercentage = 0.0;
  AnimationController DeviceAnimationController;
  _DeviceProgressIndicatorState({this.fileShare, this.devices, this.i});
  final DeviceSelectCallback fileShare;
  final List<Device> devices;
  final int i;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: setUpButtonChild(),
      onPressed: () {
        if (devices[i].getSharingState() == SharingState.neutral) {
          setState(() {
            animateButton();
          });
          print("attempting to send");
          fileShare(i);
        }
      },
      elevation: 0.0,
      fillColor: Color(0xff91c27d),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  Widget setUpButtonChild() {
    if (devices[i].getSharingState() == SharingState.sharing) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (devices[i].getSharingState() == SharingState.done) {
      return Icon(
        Icons.check,
        color: Colors.white,
        size: 35.0,
      );
    } else {
      return Icon(
        devices[i].getIcon(),
        size: 35.0,
        color: Colors.white,
      );
    }
  }

  void animateButton() {
    setState(() {
      devices[i].setSharingState(SharingState.sharing);
    });
  }
}
