import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:peardrop/src/home.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() {
  // resize and reposition the window to be centered horizontally and shifted up from center on desktop
  if (!Platform.isIOS && !Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    window_size.getWindowInfo().then((window) {
      if (window.screen != null) {
        final screenFrame = window.screen.visibleFrame;
        final width = 430.0, height = 600.0;
        final left = ((screenFrame.width - width) / 2).roundToDouble();
        final top = ((screenFrame.height - height) / 3).roundToDouble();
        final frame = Rect.fromLTWH(left, top, width, height);
        window_size.setWindowFrame(frame);
        window_size.setWindowTitle('PearDrop');

        if (Platform.isMacOS) {
          window_size.setWindowMinSize(Size(440, 600));
          window_size.setWindowMaxSize(Size(800, 1200));
        }
      }
    });
  }
  runApp(new PearDrop());
}

class PearDrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PearDrop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff6b9080),
        accentColor: Color(0xff91c27d),
        fontFamily: 'Open Sans',
      ),
      routes: {
        '/home': (_) => HomePage(),
      },
      home: HomePage(),
    );
  }
}
