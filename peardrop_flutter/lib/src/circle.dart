import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class CirclePage extends StatefulWidget {
  @override
  _CircleWaveRouteState createState() => _CircleWaveRouteState();
}

class _CircleWaveRouteState extends State<CirclePage>
    with SingleTickerProviderStateMixin {
  double waveRadius = 0.0;
  double waveGap = 10.0;
  Animation<double> _animation;
  AnimationController controller;
  Timer _timer;

  _AnimatedFlutterLogoState() {}

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

    _timer = new Timer(const Duration(milliseconds: 4000), () {
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: CircleWavePainter(waveRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'Locating nearby devices',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF759055),
                ),
              ),
            ),
            Container(
              width: 200,
              height: 440,
              alignment: Alignment.bottomCenter,
              child: Icon(
                Icons.wifi_tethering,
                color: Color(0xFF759055),
                size: 60.0,
              ),
            ),
          ],
        ),
      ),
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
  var wavePaint;
  CircleWavePainter(this.waveRadius) {
    wavePaint = Paint()
      ..color = Colors.grey[200]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
  }
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2.0;
    double centerY = size.height / 1.25;
    double maxRadius = hypot(centerX, centerY);

    var currentRadius = waveRadius;
    while (currentRadius < maxRadius) {
      canvas.drawCircle(Offset(centerX, centerY), currentRadius, wavePaint);
      currentRadius += 70.0;
    }
  }

  @override
  bool shouldRepaint(CircleWavePainter oldDelegate) {
    return oldDelegate.waveRadius != waveRadius;
  }

  double hypot(double x, double y) {
    return math.sqrt(x * x + y * y);
  }
}
