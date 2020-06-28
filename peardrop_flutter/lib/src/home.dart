import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_ip/get_ip.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:mime_type/mime_type.dart';
import 'package:peardrop/src/utilities/device_details.dart';
import 'package:peardrop/src/utilities/file_select.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/file_select_body.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utilities/nearby_device.dart';
import 'widgets/device_select_body.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// enum PearPanel { sharing, receiving, accepting, done }

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  bool pearPanelOpen = false, fileSelected = false;
  int peerIndex = 0;
  FileSelect select;
  String filePath = '', deviceName = 'Unknown';
  InternetAddress ip;
  PeardropFile file;
  final PanelController _pc = PanelController();
  // PearPanel pearPanel = PearPanel.accepting;

  @override
  void initState() {
    super.initState();
    select = FileSelect();
    fileSelected = false;
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

  void _handleFileReceive() {
    file.accept();
  }

  Future<void> _handleFileSelect() async {
    await select.openFileExplorer(setFile);
    if (filePath != '') {
      // do {

      String fileName = select.nameFromPath(filePath);
      var temp = File(filePath);
      List<int> list = await temp.readAsBytes();
      Stream<PeardropReceiver> stream =
          await Peardrop.send(list, fileName ?? '', mime(fileName) ?? '');
      try {
        stream.listen((PeardropReceiver receiver) {
          bool duplicate = false;
          for (var device in devices) {
            if (device.getIP() == receiver.ip) {
              duplicate = true;
            }
          }
          if (receiver.ip != ip && !duplicate) {
            setState(() {
              devices.add(Device(Icons.phone_iphone, receiver));
            });
          }
          print('devices: ' + devices.toString());
        });
      } catch (e) {
        print('error caught: $e');
      }
      // } while (devices.isEmpty);
    }
  }

  void _handleFileShare(int index) async {
    peerIndex = index;
    await devices[peerIndex].getReceiver().send();
  }

  void reset() {
    setFile(false, null);
    setPearPanel(false);
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

// sets panel appearence and opens and closes it based on boolean
  // void setPearPanel(bool isOpen, PearPanel panel) {
  //   setState(() {
  //     pearPanelOpen = isOpen;
  //     pearPanel = panel;
  //   });
  //   if (pearPanelOpen) {
  //     _pc.open();
  //   } else if (!pearPanelOpen) {
  //     _pc.close();
  //   }
  // }

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
    ip = (await NetworkInterface.list(
            includeLinkLocal: false, includeLoopback: false))
        .map((interface) => interface.addresses.last)
        .first;
    deviceName = WordList().ipToWords(ip);
  }

  @override
  Widget build(BuildContext context) {
    // double _panelHeightOpen = determinePanelHeight();
    setState(() {
      // _panelHeightOpen = _panelHeightOpen;
      filePath = filePath;
    });
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
              body: _getBody(),
              panelBuilder: (sc) => SlidingPanel(
                peerDevice:
                    peerIndex < devices.length ? devices[peerIndex] : null,
                sc: sc,
                // pearPanel: pearPanel,
                reset: reset,
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

  Widget _getBody() {
    if (fileSelected) {
      return DeviceSelectBody(
        devices: devices,
        reset: reset,
        version: '1.0.0+0',
        fileName: select.nameFromPath(filePath),
        fileShare: _handleFileShare,
        deviceName: deviceName,
        // setPanel: setPearPanel
      );
    } else {
      return FileSelectBody(
        fileSelect: _handleFileSelect,
        deviceName: deviceName,
      );
    }
  }

  // double determinePanelHeight() {
  //   if (pearPanel != PearPanel.receiving && pearPanel != PearPanel.sharing) {
  //     return MediaQuery.of(context).size.height * 0.35;
  //     // TODO: fix panel height being too small on some devices due to small app size return 200;
  //   } else {
  //     // return MediaQuery.of(context).size.height * 0.51;
  //     return 360;
  //   }
  // }
}
