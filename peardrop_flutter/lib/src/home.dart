import 'dart:async';
import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:mime_type/mime_type.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:peardrop/src/utilities/file_select.dart';
import 'package:peardrop/src/utilities/ip.dart';
import 'package:peardrop/src/utilities/version_const.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/receive_completed.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'utilities/nearby_device.dart';
import 'widgets/peardrop_body.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  String deviceName = 'PearDrop Device', version = VERSION_STRING, filePath;
  PeardropFile file;
  Future<void> receiverFuture;
  bool _isReceiving = true, _isSharing = false;
  final pc = PanelController();
  Directory _directory;
  Timer _locateNearbyDevices;

  @override
  void initState() {
    super.initState();
    // dummy data
    //devices.add(
    //    Device.dummy(Icons.phone_iphone, InternetAddress('26.189.192.87')));
    //devices.add(Device.dummy(Icons.computer, InternetAddress('3.45.253.192')));
    () async {
      final ip = await getMainIP();
      setState(() => deviceName = WordList.ipToWords(ip));
      if (Platform.isIOS || Platform.isAndroid) {
        initDirectory();
      }
    }();
    _refreshReceiving();
    () async {
      if (Platform.isIOS || Platform.isAndroid) {
        final info = await PackageInfo.fromPlatform();
        setState(() => version = '${info.version}+${info.buildNumber}');
      }
    }();
  }

  void setSharing(bool value) {
    setState(() => _isSharing = value);
  }

  void _refreshReceiving() {
    setState(() => _isReceiving = false);
    receiverFuture = _beginReceive();
  }

  void initDirectory() async {
    Directory temp;
    if (Platform.isIOS) {
      temp = await getApplicationDocumentsDirectory();
    } else {
      temp = await DownloadsPathProvider.downloadsDirectory;
    }
    setState(() => _directory = temp);
  }

  Future<void> _beginReceive() async {
    setState(() => _isReceiving = true);
    while (_isReceiving) {
      try {
        print('attempting to receieve');
        var temp = await Peardrop.receive();
        if (temp != null) {
          setState(() {
            file = temp;
            pc.open();
          });
        }
      } catch (e) {
        print('error caught: $e');
      }
    }
  }

  void _handleFileReceive() async {
    var data = await file.accept();
    await pc.close();
    if (Platform.isAndroid || Platform.isIOS) {
      // open modal
      ReceiveSheet().getReceiveSheet(context, file, data, _directory);
    } else {
      // select file and save
      var result = await showSavePanel(suggestedFileName: file.filename);
      if (result.canceled || result.paths.isEmpty) return;
      var path = result.paths.first;
      await File(path).writeAsBytes(data, flush: true);
    }
  }

  Future<void> _handleFileSelect() async {
    if (_locateNearbyDevices != null) {
      _locateNearbyDevices.cancel();
    }
    print('attempting to select');
    var temp = await selectFile();
    setState(() => {filePath = temp, devices = []});
    if (filePath != null) {
      await _handleFileShare();
      _locateNearbyDevices = Timer.periodic(
          Duration(seconds: 15),
          (Timer t) => {
                if (!_isSharing)
                  {
                    setState(() => devices = []),
                    print('refreshing devices'),
                    _handleFileShare(),
                  }
              });
    } else {
      _refreshReceiving();
    }
  }

  Future<void> _handleFileShare() async {
    setState(() => devices = []);
    final fileName = p.basename(filePath);
    _refreshReceiving();
    final data = await File(filePath).readAsBytes();
    final receivers =
        await Peardrop.send(data, fileName, mime(fileName) ?? 'Unknown File');
    _refreshReceiving();
    print('attempting to send');
    receivers.listen((PeardropReceiver receiver) async {
      final duplicate = devices.any((device) =>
          (device.ip == receiver.ip) ||
          (device.name == Device(Icons.description, receiver).name));

      if (!(await isSelfIP(receiver.ip)) && !duplicate) {
        setState(() {
          devices.add(Device(Icons.description, receiver));
        });
      }

      print('devices: ' + devices?.toString());
    });
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
              maxHeight: MediaQuery.of(context).size.height * 0.36,
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
                setSharing: setSharing,
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
