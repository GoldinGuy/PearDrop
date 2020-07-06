import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RadarParentData extends ContainerBoxParentData<RenderBox> {}

class Radar extends StatefulWidget {
  @override
  final Key key;
  final List<Widget> children;

  Radar({this.key, this.children});

  @override
  RadarState createState() => RadarState();
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
  RenderRadar({@required TickerProvider vsync, List<RenderBox> children})
      : assert(vsync != null) {
    addAll(children);
    _controller =
        AnimationController(vsync: vsync, duration: Duration(seconds: 4));
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
  Offset _lastOffset;

  /// Radius of the initial circle.
  final double initialRadius = 20;

  /// Gap between wave circles.
  final double waveGap = 60;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! RadarParentData) {
      child.parentData = RadarParentData();
    }
  }

  List<Offset> _points = [];
  List<Offset> _drawPoints = [];
  List<Rect> _children = [];

  @override
  void performLayout() {
    size = constraints.biggest;
    assert(size.isFinite);
    if (childCount == 0) return;
    if (_lastOffset == null) {
      //markNeedsLayout();
      var child = firstChild;
      while (child != null) {
        child.layout(constraints.loosen(), parentUsesSize: true);
        child = childAfter(child);
      }
      return;
    }
    _points = [];
    _drawPoints = [];
    _children = [];

    var center = size.bottomCenter(_lastOffset).translate(0, 42.5);
    // for now, draw children on the 5th wave
    var wave5radius = initialRadius + 5 * waveGap;
    var childGap = 50.0;
    // find intersection of circle and left edge, take the one with the lower y coord
    var leftEdgeI = smm(
        clsi(center, wave5radius, Offset.zero, Offset(0, size.height)), 1, -1);
    _points.add(leftEdgeI);

    // find position of first child, distance + half width, higher x coord
    var child = firstChild;
    Offset nextPosition(Offset oldPosition, RenderBox newChild) {
      newChild.layout(constraints.loosen(), parentUsesSize: true);
      var b = smm(cci(oldPosition, childGap, center, wave5radius), -1, 1);
      return b;
    }

    // find proper y offset
    double findYOffset(Offset position, RenderBox child) {
      var np =
          smm(cci(position, child.size.width / 2, center, wave5radius), -1, 1);
      return np.dy - child.size.height * 0.7;
    }

    var position = nextPosition(leftEdgeI, child);
    _points.add(position);
    while (child != null) {
      // Draw child, subtracting height halfway
      // Set offset
      final parentData = child.parentData as RadarParentData;
      // Find proper Y offset
      var yoff = findYOffset(position, child);
      var q = Offset(position.dx, yoff);
      parentData.offset = q;
      _drawPoints.add(q);
      _children
          .add(Rect.fromLTWH(q.dx, q.dy, child.size.width, child.size.height));
      // Move position by width of child
      position =
          smm(cci(position, child.size.width, center, wave5radius), -1, 1);
      _points.add(position);
      child = parentData.nextSibling;
      if (child != null) {
        position = nextPosition(position, child);
        _points.add(position);
      }
    }

    var rightEdgeI = smm(
        clsi(center, wave5radius, Offset(size.width, 0),
            Offset(size.width, size.height)),
        1,
        -1);
    _points.add(rightEdgeI);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    if (_lastOffset == null) return false;
    var child = lastChild;
    while (child != null) {
      final childParentData = child.parentData as RadarParentData;
      final isHit = result.addWithPaintOffset(
        offset: childParentData.offset - _lastOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          //assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  Offset _lastPaintOffset;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!isRunning) {
      _controller.forward();
      isRunning = true;
    }
    if (_lastPaintOffset != offset) {
      print('Offset = $offset');
      _lastPaintOffset = offset;
    }
    if (_lastOffset != offset) {
      _lastOffset = offset;
      return;
    }
    // draw points
    // draw path through all points
    final paintPoint = Paint()
      ..color = Colors.red
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final paintDrawPoint = Paint()
      ..color = Colors.blue
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final paintCurve = Paint()
      ..color = Colors.red
      ..isAntiAlias = true
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final paintChildBox = Paint()
      ..color = Colors.yellow
      ..isAntiAlias = true
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final yOff = 0.0;
    final path = Path();
    for (final point in _points) {
      if (point == _points.first) {
        path.moveTo(point.dx, point.dy + yOff);
      } else {
        path.lineTo(point.dx, point.dy + yOff);
      }
    }
    //context.canvas.drawPath(path, paintCurve);
    for (final point in _points) {
      //context.canvas.drawCircle(point.translate(0, yOff), 5, paintPoint);
    }
    for (final point in _drawPoints) {
      //context.canvas.drawCircle(point.translate(0, yOff), 5, paintDrawPoint);
    }
    for (final rect in _children) {
      //context.canvas.drawRect(rect, paintChildBox);
    }
    _lastValue = _controller.value;
    var currentRadians = _tween.value;
    // Calculate number of waves, starting from the bottom
    var center = size.bottomCenter(offset).translate(0, 42.5);
    // draw arc
    var arcSize = size.height * 0.8;
    var arcPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white12,
          Colors.white12.withAlpha(0),
        ],
        stops: [0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: arcSize))
      ..style = PaintingStyle.fill;
    var arcSlice = 0.1 * pi;
    context.canvas.drawArc(Rect.fromCircle(center: center, radius: arcSize),
        currentRadians, arcSlice, true, arcPaint);
    // draw waves
    var radius = initialRadius;
    var wavePaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    var wavePaint2 = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..isAntiAlias = true;
    while (radius < max(size.height, size.width)) {
      context.canvas.drawCircle(center, radius, wavePaint);
      //context.canvas
      //    .drawCircle(size.bottomCenter(Offset.zero), radius, wavePaint2);
      radius += waveGap;
    }
    // Paint children
    var child = firstChild;
    while (child != null) {
      var parentData = child.parentData as RadarParentData;
      context.paintChild(child, parentData.offset);
      child = parentData.nextSibling;
    }
    //defaultPaint(context, offset.translate(0, 42.5));
  }

  // void dispose() {
  //   _controller.dispose();
  // }
  @override
  void dispose() {
    _controller.dispose(); // you need this
  }
}

/// Utility: convert CG offset into math coordinates, and vice versa.
Offset cg2m(Offset p) {
  return Offset(p.dx, -p.dy);
}

/// Simple min/max for offsets, -1 = lower/x, 1 = higher/y
Offset smm(List<Offset> offsets, int xy, int lh) {
  var offsets2 = offsets.toList();
  offsets2.sort((a, b) {
    if (xy == -1) {
      if (lh == -1) {
        return a.dx.compareTo(b.dx);
      } else if (lh == 1) {
        return b.dx.compareTo(a.dx);
      }
    } else if (xy == 1) {
      if (lh == -1) {
        return b.dy.compareTo(a.dy);
      } else if (lh == 1) {
        return a.dy.compareTo(b.dy);
      }
    }
    return null;
  });
  //print("smm: choosing ${offsets2.first} from ${offsets}");
  return offsets2.first;
}

/// Utility: Circle-circle intersection.
/// Returns the points where the two circles intersect, otherwise null if they do not intersect / infinite solutions.
List<Offset> cci(Offset c, double r, Offset C, double R) {
  var EPS = double.minPositive;
  // Invert Y coords of c, C to put it in normal coords
  c = cg2m(c);
  C = cg2m(C);
  // https://stackoverflow.com/a/44956948
  double distance(Offset p1, Offset p2) {
    var d = p1 - p2;
    return sqrt(d.dx * d.dx + d.dy * d.dy);
  }

  var d = distance(c, C);

  // no solutions
  if (d > r + R) return null;
  // no solutions
  if (d < (r - R).abs()) return null;
  // infinite solutions
  if (d == 0 && r == R) return null;

  var a = (r * r - R * R + d * d) / (2.0 * d);
  var h = sqrt(r * r - a * a);
  var P = Offset(c.dx + a * (C.dx - c.dx) / d, c.dy + a * (C.dy - c.dy) / d);

  var p1 = Offset(P.dx + h * (C.dy - c.dy) / d, P.dy - h * (C.dx - c.dx) / d);
  var p2 = Offset(P.dx - h * (C.dy - c.dy) / d, P.dy + h * (C.dx - c.dx) / d);

  if (d == r + R) return [cg2m(p1)];
  return [cg2m(p1), cg2m(p2)];
}

/// Utility: circle-line-segment intersection.
/// Returns the points where the circle and line segment intersect, otherwise null if they do not intersect.
List<Offset> clsi(Offset c, double r, Offset p1, Offset p2) {
  var EPS = double.minPositive;
  // Convert points
  c = cg2m(c);
  p1 = cg2m(p1);
  p2 = cg2m(p2);
  // https://stackoverflow.com/a/23017208
  var a2 = ((p2.dx - p1.dx) * (c.dy - p1.dy) - (c.dx - p1.dx) * (p2.dy - p1.dy))
      .abs();
  var _lab = p2 - p1;
  var lab = sqrt(_lab.dx * _lab.dx + _lab.dy * _lab.dy);

  var h = a2 / lab;

  // no solution
  if (h > r) {
    return null;
  }

  var D = Offset((p2.dx - p1.dx) / lab, (p2.dy - p1.dy) / lab);
  var t = D.dx * (c.dx - p1.dx) + D.dy * (c.dy - p1.dy);

  var dt = sqrt(r * r - h * h);

  var E = Offset(p1.dx + (t - dt) * D.dx, p1.dy + (t - dt) * D.dy);

  // one solution
  if (h == r) return [cg2m(E)];
  // two solutions
  var F = Offset(p1.dx - (t - dt) * D.dx, p1.dy - (t - dt) * D.dy);

  return [cg2m(E), cg2m(F)];
}
