import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinearPercentageProgressIndicator extends StatefulWidget {
  @override
  _LinearPercentageProgressIndicatorState createState() =>
      _LinearPercentageProgressIndicatorState();
}

class _LinearPercentageProgressIndicatorState
    extends State<LinearPercentageProgressIndicator>
    with TickerProviderStateMixin {
  bool _loading;
  double _progressValue;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _progressValue = 0.0;
    _updateProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LinearProgressIndicator(
        value: _progressValue,
        minHeight: 20,
      ),
      // Text('${(_progressValue * 100).round()}%'),
    );
  }

  // we use this function to simulate a download
  // by updating the progress value
  void _updateProgress() {
    const threeSec = const Duration(seconds: 3);
    new Timer.periodic(threeSec, (Timer t) {
      if (!mounted) return;
      setState(() {
        _progressValue += 0.2;
        // we "finish" downloading here
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          _loading = false;
          t.cancel();
          _progressValue:
          0.0;
          return;
        }
      });
    });
  }
}
