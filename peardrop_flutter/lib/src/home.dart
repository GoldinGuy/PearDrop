import 'dart:async';
import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:mime_type/mime_type.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:peardrop/src/utilities/file_select.dart';
import 'package:peardrop/src/utilities/ip.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

import 'utilities/nearby_device.dart';
import 'widgets/peardrop_body.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  String deviceName = 'PearDrop Device', version = "0.0.0+1", filePath;
  PeardropFile file;
  Future<void> receiverFuture;
  final pc = PanelController();

  @override
  void initState() {
    super.initState();
    //devices.add(
    //    Device.dummy(Icons.phone_iphone, InternetAddress('26.189.192.87')));
    //devices.add(Device.dummy(Icons.computer, InternetAddress('3.45.253.192')));
    () async {
      final ip = await getMainIP();
      setState(() => deviceName = WordList.ipToWords(ip));
    }();
    receiverFuture = _startReceive();
    () async {
      if (Platform.isIOS || Platform.isAndroid) {
        final info = await PackageInfo.fromPlatform();
        setState(() => version = '${info.version}+${info.buildNumber}');
      } else {
        // TODO: fix so it actually displays version for desktop
        setState(() => version = '1.0.0+11');
      }
    }();
  }

  Future<void> _startReceive() async {
    while (true) {
      try {
        file = await Peardrop.receive();
        if (file != null) {
          setState(() {
            file = file;
            pc.open();
          });
        }
      } catch (e) {
        print('error caught: $e');
      }
    }
  }

  void _handleFileReceive() async {
    setState(() => filePath = null);
    var data = await file.accept();
    await pc.close();
    if (Platform.isAndroid || Platform.isIOS) {
      // share
      await WcFlutterShare.share(
        sharePopupTitle: 'PearDrop',
        mimeType: file.mimetype,
        fileName: file.filename,
        bytesOfFile: data,
      );
    } else {
      // file chooser + save
      var result = await showSavePanel(suggestedFileName: file.filename);
      if (result.canceled || result.paths.isEmpty) return;
      var path = result.paths.first;
      await File(path).writeAsBytes(data, flush: true);
    }
  }

  Future<void> _handleFileSelect() async {
    var temp = await selectFile();
    setState(() {
      devices = [];
      filePath = temp;
    });
    if (filePath != null) {
      final fileName = p.basename(filePath);
      final data = await File(filePath).readAsBytes();
      final receivers =
          await Peardrop.send(data, fileName, mime(fileName) ?? '');
      receivers.listen((PeardropReceiver receiver) async {
        final duplicate = devices.any((device) => device.ip == receiver.ip);

        if (!(await isSelfIP(receiver.ip)) && !duplicate) {
          setState(() {
            devices.add(Device(Icons.description, receiver));
          });
        }
        print('devices: ' + devices.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Color(0xff293851),
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SlidingUpPanel(
              controller: pc,
              maxHeight: MediaQuery.of(context).size.height * 0.35,
              minHeight: 0.0,
              defaultPanelState: PanelState.CLOSED,
              backdropEnabled: true,
              backdropOpacity: 0.2,
              isDraggable: false,
              onPanelClosed: () async {
                if (file != null) await file.reject();
              },
              body: PearDropBody(
                devices: devices,
                fileSelect: _handleFileSelect,
                version: version,
                fileName: filePath,
                deviceName: deviceName,
                fileSelected: filePath != null,
              ),
              panelBuilder: (sc) => SlidingPanel(
                file: file,
                accept: _handleFileReceive,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
