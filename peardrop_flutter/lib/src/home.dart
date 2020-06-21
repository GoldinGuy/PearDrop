import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/sharing_service.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/bottom_version.dart';
import 'package:peardrop/src/widgets/file_select_body.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'utilities/nearby_device.dart';
import 'widgets/device_select_body.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum PearPanel { sharing, receiving, accepting, done }

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  InternetAddress deviceId = new InternetAddress('190.160.225.16');
  bool pearPanelOpen = false, fileSelected = false;
  SharingService share;
  String fileName = '';
  PanelController _pc = new PanelController();
  PearPanel pearPanel = PearPanel.accepting;

  @override
  void initState() {
    super.initState();
    share = new SharingService();
    fileSelected = false;
    // TODO: determine how best to use deviceInfo | deviceId = DeviceDetails().getDeviceDetails() as String;
    // dummy data
    devices.add(Device(Icons.phone_iphone, InternetAddress('140.70.235.92')));
    devices.add(Device(Icons.laptop_windows, InternetAddress('3.219.241.180')));
  }

// resets the app back to the main screen
  void reset() {
    // setState(() {
    //   fileSelected = false;
    // });
    setFile(false, '');
    setPearPanel(false, PearPanel.accepting);
  }

// sets whether there is currently a file selected or not
  void setFile(bool selected, String file) {
    setState(() {
      fileSelected = selected;
      fileName = file;
    });
  }

// sets panel appearence and opens and closes it based on boolean
  void setPearPanel(bool value, PearPanel panel) {
    setState(() {
      pearPanelOpen = value;
      pearPanel = panel;
    });
    if (pearPanelOpen) {
      _pc.open();
    } else if (!pearPanelOpen) {
      _pc.close();
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen;
    if (pearPanel != PearPanel.receiving && pearPanel != PearPanel.sharing) {
      _panelHeightOpen = MediaQuery.of(context).size.height * 0.35;
    } else {
      _panelHeightOpen = MediaQuery.of(context).size.height * 0.25;
    }
    setState(() {
      _panelHeightOpen = _panelHeightOpen;
      fileName = fileName;
    });
    Color background;
    if (!fileSelected) {
      background = Color(0xff293851);
    } else {
      background = Color(0xff559364);
    }
    return Material(
      child: Scaffold(
        backgroundColor: background,
        // appBar: PearDropAppBar().getAppBar('PearDrop'),
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SlidingUpPanel(
              controller: _pc,
              maxHeight: _panelHeightOpen,
              minHeight: 0.0,
              defaultPanelState: PanelState.CLOSED,
              backdropEnabled: true,
              backdropOpacity: 0.2,
              isDraggable: false,
              body: _getBody(),
              panelBuilder: (sc) => SlidingPanel(
                peerDevice: devices[share.peerIndex],
                sc: sc,
                fileName: fileName,
                pearPanel: pearPanel,
                reset: reset,
                accept: share.handleFileReceive,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
            ),
          ],
        ),
        bottomNavigationBar: BottomVersionBar(
          version: '1.0.0+0',
          fileName: fileName,
        ),
      ),
    );
  }

// returns main app body
  Widget _getBody() {
    if (fileSelected) {
      return DeviceSelectBody(
          devices: devices,
          reset: reset,
          fileName: fileName,
          fileShare: share.handleFileShare,
          deviceName: WordList().ipToWords(deviceId),
          setPanel: setPearPanel);
    } else {
      return FileSelectBody(
        fileSelect: share.handleFileSelect,
        setFile: setFile,
        deviceName: WordList().ipToWords(deviceId),
      );
    }
  }
}
