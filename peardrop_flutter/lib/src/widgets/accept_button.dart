import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

class AcceptButton extends StatefulWidget {
  AcceptButton({@required this.accept});
  final Function() accept;

  @override
  _AcceptButtonState createState() => _AcceptButtonState(accept: accept);
}

class _AcceptButtonState extends State<AcceptButton> {
  _AcceptButtonState({@required this.accept});
  final Function() accept;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(40, 17, 40, 5),
      child: GestureDetector(
        onTap: () async {
          setState(() => isPressed = true);
          await accept();
          setState(() => isPressed = false);
        },
        child: Container(
          width: 80,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff91c27d),
                Color(0xff559364),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(5, 5),
                blurRadius: 10,
              )
            ],
          ),
          child: Center(child: getStateWidget()),
        ),
      ),
    );
  }

  Widget getStateWidget() {
    if (isPressed) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Text(
        'Accept',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }
}
