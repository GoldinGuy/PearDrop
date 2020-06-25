import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/device_details.dart';
import 'package:peardrop/src/utilities/sharing_service.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/file_select_body.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'utilities/nearby_device.dart';
import 'widgets/device_select_body.dart';
import 'widgets/inactive/peardrop_appbar.dart';

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
    DeviceDetails.getDeviceDetails();
    // dummy data
    devices.add(Device(Icons.phone_iphone, InternetAddress('140.70.235.92')));
    // devices.add(Device(Icons.laptop_windows, InternetAddress('3.219.241.180')));
    devices.add(Device(Icons.laptop_windows,
        InternetAddress('2001:0db8:85a3:0000:0000:8a2e:0370:7334')));
  }

// resets the app back to the main screen
  void reset() {
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
  void setPearPanel(bool isOpen, PearPanel panel) {
    setState(() {
      pearPanelOpen = isOpen;
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
    double _panelHeightOpen = determinePanelHeight();
    setState(() {
      _panelHeightOpen = _panelHeightOpen;
      fileName = fileName;
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
                setPearPanel: setPearPanel,
                accept: share.handleFileReceive,
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

  // returns main app body
  Widget _getBody() {
    if (fileSelected) {
      return DeviceSelectBody(
          devices: devices,
          reset: reset,
          version: '1.0.0+0',
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

  double determinePanelHeight() {
    if (pearPanel != PearPanel.receiving && pearPanel != PearPanel.sharing) {
      return MediaQuery.of(context).size.height * 0.35;
      // TODO: fix panel height being too small on some devices due to small app size return 200;
    } else {
      // return MediaQuery.of(context).size.height * 0.51;
      return 360;
    }
  }
}
