import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceProgressIndicator extends StatefulWidget {
  DeviceProgressIndicator({this.centerIcon});
  final IconData centerIcon;

  @override
  _DeviceProgressIndicatorState createState() =>
      _DeviceProgressIndicatorState(centerIcon: centerIcon);
}

class _DeviceProgressIndicatorState extends State<DeviceProgressIndicator>
    with TickerProviderStateMixin {
  double percentage = 0.0, newPercentage = 0.0;
  AnimationController DeviceAnimationController;
  _DeviceProgressIndicatorState({this.centerIcon});
  IconData centerIcon;

  @override
  void initState() {
    super.initState();
    setState(() {
      percentage = 0.0;
    });
    DeviceAnimationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, DeviceAnimationController.value);
        });
      });
  }

  void startTimer() {
    percentage = 0.0;
    newPercentage = 0.0;
    if (!mounted) return;
    new Timer.periodic(
      Duration(seconds: 2),
      (Timer timer) => setState(() {
        if (newPercentage == 100.0) {
          timer.cancel();
        } else {
          percentage = newPercentage;
          newPercentage += 10;
          DeviceAnimationController.forward(from: 0.0);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    centerIcon = widget.centerIcon;
    return Center(
      child: Container(
        height: 95.0,
        width: 95.0,
        child: CustomPaint(
          foregroundPainter: MyPainter(
              lineColor: Colors.grey,
              completeColor: Color(0xff91c27d),
              completePercent: percentage,
              width: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: RaisedButton(
                elevation: 0,
                color: Colors.white,
                splashColor: Colors.white,
                shape: CircleBorder(),
                // child: Text(
                //   percentage.toInt().toString() + '%',
                //   style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                // ),
                child: Icon(
                  centerIcon,
                  color: Colors.white,
                  size: 45,
                ),
                onPressed: () {
                  startTimer();
                }),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
