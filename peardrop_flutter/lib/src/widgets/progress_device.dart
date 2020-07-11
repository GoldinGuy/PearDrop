import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

class DeviceWidget extends StatefulWidget {
  DeviceWidget({@required this.device, this.setSharing});
  final Device device;
  final Function(bool value) setSharing;
  @override
  _DeviceWidgetState createState() =>
      _DeviceWidgetState(device: device, setSharing: setSharing);
}

class _DeviceWidgetState extends State<DeviceWidget> {
  _DeviceWidgetState({@required this.device, this.setSharing});
  Device device;
  final Function(bool value) setSharing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[200],
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(bottom: 6),
          child: Text(
            device.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        RawMaterialButton(
          child: getStateWidget(),
          onPressed: () async {
            if (device.state == SharingState.neutral) {
              setSharing(true);
              setState(() => device.state = SharingState.sharing);
              print('attempting to send');
              await fileShare();
            }
          },
          elevation: 0.0,
          fillColor: Color(0xff91c27d),
          padding: EdgeInsets.all(15.0),
          shape: CircleBorder(),
        )
      ],
    );
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
    } else if (device.state == SharingState.failed) {
      return Icon(
        Icons.close,
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

  Future<void> fileShare() async {
    try {
      await device.receiver.send();
      setState(() => device.state = SharingState.done);
    } catch (e) {
      print('error caught: $e');
      setState(() => device.state = SharingState.failed);
    }
    setSharing(false);
  }
}
