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
    setState(() {
      fileSelected = false;
    });
    setPearPanel(false, PearPanel.accepting);
  }

// sets whether there is currently a file selected or not
  void setFileSelected(bool selected) {
    setState(() {
      fileSelected = selected;
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
        body: _getBody(),
        // bottomNavigationBar: BottomVersionBar(
        //   version: '1.0.0+0',
        // ),
      ),
    );
  }

// returns main app body
  Widget _getBody() {
    if (fileSelected) {
      double _panelHeightOpen;
      if (pearPanel != PearPanel.receiving && pearPanel != PearPanel.sharing) {
        setState(() {
          _panelHeightOpen = MediaQuery.of(context).size.height * 0.35;
        });
      } else {
        setState(() {
          _panelHeightOpen = MediaQuery.of(context).size.height * 0.25;
        });
      }
      return Stack(
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
            body: DeviceSelectBody(
                devices: devices,
                reset: reset,
                fileShare: share.handleFileShare,
                deviceName: WordList().ipToWords(deviceId).toString(),
                setPanel: setPearPanel),
            panelBuilder: (sc) => SlidingPanel(
              peerDevice: devices[share.peerIndex],
              sc: sc,
              fileName: share.fileName,
              pearPanel: pearPanel,
              reset: reset,
              accept: share.handleFileReceive,
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
          ),
        ],
      );
    } else if (!fileSelected) {
      return FileSelectBody(
        fileSelect: share.handleFileSelect,
        setFileSelected: setFileSelected,
        deviceName: WordList().ipToWords(deviceId).toString(),
      );
    } else {
      return DeviceSelectBody(
        devices: devices,
        fileShare: share.handleFileShare,
        deviceName: WordList().ipToWords(deviceId).toString(),
        setPanel: setPearPanel,
      );
    }
  }
}
