import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomVersionBar extends StatelessWidget {
  BottomVersionBar({this.version, this.deviceName});

  final String version, deviceName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your device is visible as ' + deviceName,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Text(
              version,
              style: TextStyle(color: Colors.grey[500]),
            ),
          )
        ],
      ),
    );
  }
}
