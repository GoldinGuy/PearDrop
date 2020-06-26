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
  RenderRadar({@required TickerProvider vsync, List<RenderBox> children}) : assert(vsync != null) {
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

  /// Radius of the initial circle.
  final double initialRadius = 20;

  /// Gap between wave circles.
  final double waveGap = 60;

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
    var center = size.bottomCenter(offset).translate(0, 30);
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
    while (radius < max(size.height, size.width)) {
      context.canvas.drawCircle(center, radius, wavePaint);
      radius += waveGap;
    }
    // for now, draw children on the 5th wave
    var wave5radius = initialRadius + 5 * waveGap;
    var childGap = 8.0;
    // find intersection of circle and left edge, take the one with the lower y coord
    var leftEdgeI = smm(clsi(center, wave5radius, Offset.zero, Offset(0, size.height)), 1, -1);
    // find position of first child, distance + half width, higher x coord
    var child = firstChild;
    Offset nextPosition(Offset oldPosition, RenderBox newChild) {
      newChild.performResize();
      assert(newChild.size != null);
      var a = cci(oldPosition, childGap, center, wave5radius);
      assert(a != null);
      var b = smm(a, -1, 1);
      return smm(cci(smm(cci(oldPosition, childGap, center, wave5radius), -1, 1), child.size.width/2, center, wave5radius), -1, 1);
    }
    var position = nextPosition(leftEdgeI, child);
    while (child != null) {
      // Draw child, subtracing width and height halfway
      context.paintChild(child, position.translate(-child.size.width/2, -child.size.height/2));
      // Re-intersect, and get next position
      position = smm(cci(position, child.size.width/2, center, wave5radius), -1, 1);
      child = childAfter(child);
      position = nextPosition(position, child);
    }
  }
}

/// Utility: convert CG offset into math coordinates, and vice versa.
Offset cg2m(Offset p) { return Offset(p.dx, -p.dy); }

/// Simple min/max for offsets, -1 = lower/x, 1 = higher/y
Offset smm(List<Offset> offsets, int xy, int lh) {
  var offsets2 = offsets.toList();
  offsets2.sort((a, b) {
    if (xy == -1)
      if (lh == -1)
        return a.dx.compareTo(b.dx);
      else if (lh == 1)
        return b.dx.compareTo(a.dx);
    else if (xy == 1)
      if (lh == -1)
        return a.dy.compareTo(b.dy);
      else if (lh == 1)
        return b.dy.compareTo(a.dy);
    return null;
  });
  return offsets2.first;
}

/// Utility: Circle-circle intersection.
/// Returns the points where the two circles intersect,
/// otherwise null if they do not intersect / infinite solutions.
List<Offset> cci(Offset c, double r, Offset C, double R) {
  var EPS = double.minPositive;
  // Invert Y coords of c, C to put it in normal coords
  c = cg2m(c); C = cg2m(C);
  // https://stackoverflow.com/a/4495694
  double acossafe(double x) {
    if (x >= 1.0) return 0;
    if (x <= -1.0) return pi;
    return acos(x);
  }

  Offset rotatePoint(Offset fp, Offset pt, double a) {
    var p = pt - fp;
    return Offset(p.dx*cos(a)+p.dy*sin(a), p.dy*cos(a)-p.dx*sin(a));
  }

  if (r > R) {
    // swap r, R
    var tmp1 = r; r = R; R = tmp1;
  }
  var D = c - C;
  var d = sqrt(D.dx*D.dx + D.dy*D.dy);

  // infinite solutions
  if (d < EPS && (R-r).abs() < EPS) return null;
  // no solution, same center different radius
  else if (d < EPS) return null;

  var P = Offset((D.dx / d) * R + C.dx, (D.dy / d) * R + C.dy);

  // single intersection
  if (((R+r)-d).abs() < EPS || (R-(r+d)).abs() < EPS) return [cg2m(P)];

  // no intersection
  if ((d+r) < R || (r+R) < d) return [];

  var angle = acossafe((r*r-d*d-R*R)/(-2.0*d*R));
  var pt1 = rotatePoint(C, P, angle);
  var pt2 = rotatePoint(C, P, -angle);

  return [cg2m(pt1), cg2m(pt2)];
}

/// Utility: circle-line-segment intersection.
/// Returns the points where the circle and line segment intersect,
/// otherwise null if they do not intersect.
List<Offset> clsi(Offset c, double r, Offset p1, Offset p2) {
  var EPS = double.minPositive;
  // Convert points
  c = cg2m(c); p1 = cg2m(p1); p2 = cg2m(p2);
  // https://stackoverflow.com/a/23017208
  var D = p2 - p1;

  var A = D.dx*D.dx + D.dy*D.dy;
  var B = 2 * (D.dx * (p1.dx-c.dx) + D.dy * (p1.dy-c.dy));
  var C = (p1.dx-c.dx)*(p1.dx-c.dx) + (p1.dy-c.dy)*(p1.dy-c.dy) - r*r;

  var det = B*B - 4*A*C;
  if ((A <= EPS) || (det < 0)) {
    // no solutions
    return null;
  }
  else if (det == 0) {
    // one solution
    var t = -B / (2*A);
    return [cg2m(Offset(p1.dx+t*D.dx, p1.dy+t*D.dy))];
  } else {
    // two solutions
    var t = (-B + sqrt(det)) / (2*A);
    var i1 = Offset(p1.dx+t*D.dx, p1.dy+t*D.dy);
    t = (-B - sqrt(det)) / (2*A);
    var i2 = Offset(p1.dx+t*D.dx, p1.dy+t*D.dy);
    return [cg2m(i1), cg2m(i2)];
  }
}
