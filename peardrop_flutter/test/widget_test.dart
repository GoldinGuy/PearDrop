// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:peardrop/src/home.dart';
import 'package:peardrop/src/tos.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';
import 'package:peardrop/src/utilities/tos_const.dart';
import 'package:peardrop/src/widgets/peardrop_body.dart';

class MockData {
  List<Device> getDevices() {
    // dummy data
    var temp = [
      Device.dummy(Icons.description, InternetAddress('26.189.192.87')),
      Device.dummy(Icons.description, InternetAddress('3.45.253.192')),
      Device.dummy(Icons.description, InternetAddress('194.137.8.31')),
    ];
    return temp;
  }
}

void main() {
  var filePath = 'filePath', deviceName = 'deviceName', version = 'versionNum';
  var devices = <Device>[];

  Widget homePage = MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(home: HomePage()),
  );

  Widget termsPage = MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(home: TermsDisplayScreen()),
  );

  Widget devicesPage = MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      home: Material(
        child: Scaffold(
          backgroundColor: Color(0xff293851),
          body: PearDropBody(
            devices: devices,
            fileSelect: () => {},
            version: version,
            fileName: filePath,
            deviceName: deviceName,
            fileSelected: true,
          ),
        ),
      ),
    ),
  );

// The following are UI tests

  testWidgets('Given app loads, ensure that intial screen loads properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(homePage);
    // check to see if default widgets display properly
    expect(find.text('Share With PearDrop'), findsOneWidget);
    expect(
      find.text(
          'Click below to start sharing, or begin from another nearby device'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Select a file to start sharing'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
  });

  testWidgets('Given TOS displays properly', (WidgetTester tester) async {
    await tester.pumpWidget(termsPage);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text(TOS_STRING), findsOneWidget);
  });

  group('Given there are nearby devices', () {
    test('Ensure that intial screen loads properly', () async {
      var devices = await MockData().getDevices();
      // ensure devices is functioning properly
      expect(devices.length, 3);
      expect(devices[0].name, 'beehive-eskimo');
      expect(devices[1].ip, InternetAddress('3.45.253.192'));
      expect(devices[2].icon, Icons.description);
    });

    testWidgets('Given a file is selected AND devices are nearby',
        (WidgetTester tester) async {
      await tester.pumpWidget(devicesPage);

      await tester.pumpWidget(devicesPage);

      expect(find.byIcon(Icons.info), findsOneWidget);
      // expect(find.byWidget(Radar()), findsOneWidget);
      expect(find.text('deviceName'), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.text('filePath'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.text('versionNum'), findsOneWidget);
    });
  });
}

class MockShare extends Mock implements Share {}

class Share {
  var fileState;
  Future<void> _handleFileReceive() async {
    fileState = 'fileReceived';
  }

  Future<void> _handleFileSelect() async {
    fileState = 'fileSelected';
  }

  Future<void> _handleFileShare() async {
    fileState = 'fileShared';
  }

  Future<void> _startReceive() async {
    await _handleFileReceive();
  }
}
