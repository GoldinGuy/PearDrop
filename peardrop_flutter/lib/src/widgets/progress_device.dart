import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

class DeviceProgressIndicator extends StatefulWidget {
  DeviceProgressIndicator({this.device});
  final Device device;

  @override
  _DeviceProgressIndicatorState createState() =>
      _DeviceProgressIndicatorState(device: device);
}

typedef void DeviceSelectCallback(int index);

class _DeviceProgressIndicatorState extends State<DeviceProgressIndicator>
    with TickerProviderStateMixin {
  double percentage = 0.0, newPercentage = 0.0;
  AnimationController animationController;
  _DeviceProgressIndicatorState({this.device});
  final Device device;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: getStateWidget(),
      onPressed: () async {
        if (device.state == SharingState.neutral) {
          animateButton();
          print('attempting to send');
          await fileShare();
        }
      },
      elevation: 0.0,
      fillColor: Color(0xff91c27d),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  Future<void> fileShare() async {
    await device.receiver.send();
    setState(() => device.state = SharingState.done);
    await Future.delayed(Duration(seconds: 2),
        () => setState(() => device.state = SharingState.neutral));
  }

  Widget getStateWidget() {
    if (device.state == SharingState.sharing) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (device.state == SharingState.done) {
      return Icon(
        Icons.check,
        color: Colors.white,
        size: 35.0,
      );
    } else {
      return Icon(
        device.icon,
        size: 35.0,
        color: Colors.white,
      );
    }
  }

  void animateButton() {
    setState(() {
      device.state = SharingState.sharing;
    });
  }
}
