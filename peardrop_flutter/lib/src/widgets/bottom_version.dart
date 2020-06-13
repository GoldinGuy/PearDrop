import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomVersionBar extends StatelessWidget {
  BottomVersionBar({this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        new Container(
          height: 30.0,
          color: Colors.white10,
          child: Center(
            child: Text(
              version,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ),
      ],
    );
  }
}
