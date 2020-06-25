import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RadarParentData extends ContainerBoxParentData<RenderBox> {}

class Radar extends StatefulWidget {
  final Key key;
  final List<Widget> children;

  Radar({this.key, this.children});

  @override
  createState() => RadarState();
}

class RadarState extends State<Radar> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Radar2(vsync: this, key: widget.key, children: widget.children);
  }
}

class Radar2 extends MultiChildRenderObjectWidget {
  final TickerProvider vsync;

  Radar2({Key key, List<Widget> children, @required this.vsync})
      : super(key: key, children: children);

  @override
  RenderRadar createRenderObject(BuildContext context) {
    return RenderRadar(vsync: vsync);
  }
}

class RenderRadar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RadarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RadarParentData> {
  RenderRadar({@required TickerProvider vsync}) : assert(vsync != null) {
    _controller =
        AnimationController(vsync: vsync, duration: Duration(seconds: 2));
    _controller.addListener(() {
      if (_controller.value != _lastValue) {
        markNeedsPaint();
      }
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _tween = Tween(begin: pi, end: 2 * pi).animate(_controller);
  }

  AnimationController _controller;
  double _lastValue;
  bool isRunning = false;
  Animation<double> _tween;

  /// Radius of the initial circle.
  final int initialRadius = 20;

  /// Gap between wave circles.
  final int waveGap = 20;

  @override
  bool get sizedByParent => true;
  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! RadarParentData)
      child.parentData = RadarParentData();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!isRunning) {
      _controller.forward();
      isRunning = true;
    }
    _lastValue = _controller.value;
    var currentRadians = _tween.value;
    // Calculate number of waves, starting from the bottom
    var center = size.bottomCenter(offset);
    // draw waves
    var arcSize = size.height * 0.8;
    var wavePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white12,
          Colors.white12.withAlpha(0),
        ],
        stops: [0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: arcSize))
      ..style = PaintingStyle.fill;
    var arcSlice = 0.1*pi;
    context.canvas.drawArc(Rect.fromCircle(center: center, radius: arcSize), currentRadians, arcSlice, true, wavePaint);
  }
}
