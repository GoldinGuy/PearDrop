import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/home.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

class DeviceProgressIndicator extends StatefulWidget {
  DeviceProgressIndicator(
      {this.centerIcon, this.fileShare, this.devices, this.i});
  final IconData centerIcon;
  final DeviceSelectCallback fileShare;
  // final SetPanelCallback setPanel;
  final List<Device> devices;
  final int i;

  @override
  _DeviceProgressIndicatorState createState() => _DeviceProgressIndicatorState(
      centerIcon: centerIcon,
      fileShare: fileShare,
      // setPanel: setPanel,
      devices: devices,
      i: i);
}

typedef void DeviceSelectCallback(int index);
// typedef void SetPanelCallback(bool panelOpen, PearPanel panel);

class _DeviceProgressIndicatorState extends State<DeviceProgressIndicator>
    with TickerProviderStateMixin {
  double percentage = 0.0, newPercentage = 0.0;
  AnimationController DeviceAnimationController;
  _DeviceProgressIndicatorState(
      {this.centerIcon, this.fileShare, this.devices, this.i});
  IconData centerIcon;
  final DeviceSelectCallback fileShare;
  // final SetPanelCallback setPanel;
  final List<Device> devices;
  final int i;
  int _state = 0;

  @override
  Widget build(BuildContext context) {
    centerIcon = widget.centerIcon;
    return RawMaterialButton(
      child: setUpButtonChild(),
      onPressed: () {
        setState(() {
          if (_state == 0) {
            animateButton();
          }
        });
        print("attempting to send");
        // setPanel(true, PearPanel.sharing);
        fileShare(i);
      },
      elevation: 0.0,
      fillColor: Color(0xff91c27d),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  Widget setUpButtonChild() {
    if (_state == 0) {
      return Icon(
        devices[i].getIcon(),
        size: 35.0,
        color: Colors.white,
      );
    } else if (_state == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Icon(
        Icons.check,
        color: Colors.white,
        size: 35.0,
      );
    }
  }

  void animateButton() {
    setState(() {
      _state = 1;
    });
    Timer.periodic(
      Duration(milliseconds: 5300),
      (Timer timer) => setState(() {
        _state = 2;
      }),
    );
  }
}
