import 'package:flutter/material.dart';
import 'package:peardrop/src/circle.dart';
import 'package:peardrop/src/devices.dart';
import 'package:peardrop/src/file_upload.dart';
import 'package:flutter/widgets.dart';
import 'package:peardrop/src/settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PearDrop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff6b9080),
      ),
      routes: {
        '/circle': (_) => CirclePage(),
        '/devices': (_) => DevicesPage(),
        '/settings': (_) => SettingsScreen(),
      },
      home: DevicesPage(),
    );
  }
}
