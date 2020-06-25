import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class Wave extends StatefulWidget {
  @override
  _WaveRouteState createState() => _WaveRouteState();
}

class _WaveRouteState extends State<Wave> with SingleTickerProviderStateMixin {
  double waveRadius = 0.0;
  double waveGap = 10.0;
  Animation<double> _animation;
  AnimationController controller;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    // _timer = new Timer(const Duration(milliseconds: 4000), () {
    _timer = new Timer(const Duration(milliseconds: 0), () {
      setState(() {
        controller.stop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween(begin: 0.0, end: 70.0).animate(controller)
      ..addListener(() {
        setState(() {
          waveRadius = _animation.value;
        });
      });

    return CustomPaint(
      size: Size(double.infinity, double.infinity),
      painter: CircleWavePainter(waveRadius),
      child: Container(
        height: 0,
      ),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: <Widget>[
      //     Center(
      //       child: Text(
      //         'Locating nearby devices',
      //         textAlign: TextAlign.center,
      //         style: const TextStyle(
      //           fontSize: 26.0,
      //           fontWeight: FontWeight.w500,
      //           color: Color(0xFF759055),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CircleWavePainter extends CustomPainter {
  final double waveRadius;
  final Paint wavePaint = Paint()
    ..color = Colors.white30
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..isAntiAlias = true;

  CircleWavePainter(this.waveRadius);

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width * 0.5;
    // double centerY = size.height * 0.8;
    double centerY = size.height * 0;
    double maxRadius = centerX * centerX + centerY * centerY;

    var currentRadius = waveRadius;
    while (currentRadius < maxRadius) {
      canvas.drawCircle(Offset(centerX, centerY), currentRadius, wavePaint);
      // determines distance between each wave
      currentRadius += 65.0;
    }
  }

  @override
  bool shouldRepaint(CircleWavePainter oldDelegate) {
    return oldDelegate.waveRadius != waveRadius;
  }
}
