import 'dart:async';
import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:mime_type/mime_type.dart';
import 'package:peardrop/src/utilities/device_details.dart';
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
  bool pearPanelOpen = false, fileSelected = false;
  int peerIndex = 0;
  FileSelect select;
  String filePath = '', deviceName = 'PearDrop Device';
  InternetAddress ip;
  PeardropFile file;
  final PanelController _pc = PanelController();

  @override
  void initState() {
    super.initState();
    select = FileSelect();
    fileSelected = false;
    // devices.add(
    //     Device.dummy(Icons.phone_iphone, InternetAddress('26.189.192.87')));
    _getDeviceName();
    DeviceDetails.getDeviceDetails();
    _handleFileAccept();
  }

  void _handleFileAccept() async {
    while (true) {
      try {
        file = await Peardrop.receive();
        if (file != null) {
          setState(() {
            file = file;
          });
          setPearPanel(true);
          setFile(true, file.filename);
        }
      } catch (e) {
        print('error caught: $e');
      }
    }
  }

  void _handleFileReceive() async {
    var temp = await file.accept();
    if (Platform.isAndroid || Platform.isIOS) {
      // share
      await WcFlutterShare.share(
        sharePopupTitle: 'PearDrop',
        mimeType: file.mimetype,
        fileName: file.filename,
        bytesOfFile: temp,
      );
    } else {
      // file chooser + save
      var result = await showSavePanel(suggestedFileName: file.filename);
      if (result.canceled || result.paths.isEmpty) return;
      var path = result.paths.first;
      await File(path).writeAsBytes(temp, flush: true);
    }
  }

  Future<void> _handleFileSelect() async {
    await select.openFileExplorer(setFile);
    if (filePath != '') {
      String fileName = select.nameFromPath(filePath);
      var temp = File(filePath);
      List<int> list = await temp.readAsBytes();
      Stream<PeardropReceiver> stream =
          await Peardrop.send(list, fileName ?? '', mime(fileName) ?? '');
      try {
        stream.listen((PeardropReceiver receiver) async {
          bool duplicate = false;
          for (var device in devices) {
            if (device.getIP() == receiver.ip) {
              duplicate = true;
            }
          }

          if (!(await isSelfIP(receiver.ip)) && !duplicate) {
            setState(() {
              devices.add(Device(Icons.phone_iphone, receiver));
            });
          }
          print('devices: ' + devices.toString());
        });
      } catch (e) {
        print('error caught: $e');
      }
    }
  }

  void _handleFileShare(int index) async {
    peerIndex = index;
    await devices[peerIndex].getReceiver().send();
    Timer.periodic(
      Duration(milliseconds: 5300),
      (Timer timer) => setState(() {
        devices[peerIndex].setSharingState(SharingState.done);

        timer.cancel();
      }),
    );
    Timer.periodic(
      Duration(milliseconds: 7300),
      (Timer timer2) => setState(() {
        devices[peerIndex].setSharingState(SharingState.neutral);

        timer2.cancel();
      }),
    );
  }

  void _cancel() {
    file.reject();
  }

  void setFile(bool selected, String path) {
    setState(() {
      fileSelected = selected;
      filePath = path;
    });
  }

  void setPearPanel(bool isOpen) {
    setState(() {
      pearPanelOpen = isOpen;
    });
    if (pearPanelOpen) {
      _pc.open();
    } else if (!pearPanelOpen) {
      _pc.close();
    }
  }

  Future<void> _getDeviceName() async {
    ip = await getMainIP();
    setState(() {
      deviceName = WordList().ipToWords(ip);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Material(
      child: Scaffold(
        backgroundColor: Color(0xff293851),
        // appBar: PearDropAppBar().getAppBar('PearDrop'),
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SlidingUpPanel(
              controller: _pc,
              maxHeight: MediaQuery.of(context).size.height * 0.35,
              minHeight: 0.0,
              defaultPanelState: PanelState.CLOSED,
              backdropEnabled: true,
              backdropOpacity: 0.2,
              isDraggable: false,
              body: PearDropBody(
                  devices: devices,
                  fileSelect: _handleFileSelect,
                  version: '1.0.0+0',
                  fileName: select.nameFromPath(filePath),
                  fileShare: _handleFileShare,
                  deviceName: deviceName,
                  fileSelected: fileSelected),
              panelBuilder: (sc) => SlidingPanel(
                peerDevice:
                    peerIndex < devices.length ? devices[peerIndex] : null,
                sc: sc,
                setPearPanel: setPearPanel,
                filePath: filePath,
                cancel: _cancel,
                accept: _handleFileReceive,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
            ),
          ],
        ),
        // bottomNavigationBar: BottomVersionBar(
        //   version: '1.0.0+0',
        //   fileName: fileName,
        // ),
      ),
    );
  }
}
