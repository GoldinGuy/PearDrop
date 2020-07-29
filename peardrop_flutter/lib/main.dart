import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:peardrop/src/home.dart';
import 'package:peardrop/src/utilities/sentry.dart';
import 'package:peardrop/src/settings.dart';
import 'package:peardrop/src/tos.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() async {
  await runZoned(
    () async {
      FlutterError.onError = (details, {bool forceReport = false}) {
        reportException(
          exception: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
      };

      // resize and reposition the window to be centered horizontally and shifted up from center on desktop
      if (!Platform.isIOS && !Platform.isAndroid) {
        WidgetsFlutterBinding.ensureInitialized();
        await window_size.getWindowInfo().then((window) {
          if (window.screen != null) {
            final screenFrame = window.screen.visibleFrame;
            // double width = (screenFrame.width / 4.4).roundToDouble(),
            //     height = (screenFrame.height / 1.5).roundToDouble();
            final width = 425.0, height = 785.0;
            final left = ((screenFrame.width - width) / 2).roundToDouble();
            final top = ((screenFrame.height - height) / 3).roundToDouble();
            final frame = Rect.fromLTWH(left, top, width, height);
            window_size.setWindowFrame(frame);
            window_size.setWindowTitle('PearDrop');

            if (Platform.isMacOS) {
              window_size.setWindowMinSize(Size(420, 780));
              window_size.setWindowMaxSize(Size(420, 780));
            }
          }
        });
      }
      runApp(PearDrop());
    },
    onError: (Object error, StackTrace stackTrace) {
      reportException(
        exception: error,
        stackTrace: stackTrace,
      );
    },
  );
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
        '/tos': (_) => TermsDisplayScreen(),
        '/settings': (_) => SettingsScreen(),
      },
      home: HomePage(),
    );
  }
}
