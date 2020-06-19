// this is the main page of the app (the first you see) and will show nearby devices that (when clicked on) will allow you to select file(s) to share

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/sharing_service.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/bottom_version.dart';
import 'package:peardrop/src/widgets/file_select_body.dart';
import 'package:peardrop/src/widgets/sliding_panel_accept.dart';
import 'package:peardrop/src/widgets/sliding_panel_receive.dart';
import 'package:peardrop/src/widgets/sliding_panel_send.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'utilities/nearby_device.dart';
import 'widgets/device_select_body.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// enum PearBody { selectingFile, pickingDevice, sharing }

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  InternetAddress deviceId = new InternetAddress('190.160.225.16');
  bool pearPanelOpen = false;
  bool fileSelected = false;
  SharingService share;
  PanelController _pc = new PanelController();

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

  void setFileSelected(bool selected) {
    setState(() {
      fileSelected = selected;
    });
  }

  void setPearPanel(bool panel) {
    setState(() {
      pearPanelOpen = panel;
    });
    if (pearPanelOpen) {
      _pc.open();
    } else if (!pearPanelOpen) {
      _pc.close();
    }
  }

// returns main app body
  Widget _getBody() {
    if (fileSelected) {
      double _panelHeightClosed = 0.0;
      double _panelHeightOpen = MediaQuery.of(context).size.height * 0.25;
      return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            controller: _pc,
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            defaultPanelState: PanelState.CLOSED,
            backdropEnabled: true,
            // renderPanelSheet: false,
            backdropOpacity: 0.2,
            isDraggable: false,
            body: DeviceSelectBody(
                devices: devices,
                fileShare: share.handleFileShare,
                deviceName: WordList().ipToWords(deviceId).toString(),
                setPanel: setPearPanel),
            panelBuilder: (sc) => _getPanel(sc),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            // onPanelSlide: (doublse pos) => setState(() {}),
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

  // returns panel based on situation
  Widget _getPanel(ScrollController sc) {
    // if (pearPanel == PearPanel.sharing) {
    return SlidingPanelSend(
      peerDevice: devices[share.peerIndex],
      sc: sc,
      fileName: share.fileName,
      cancel: CloseButton(
        onPressed: () => share.cancelShare(),
      ),
    );
    // } else if (pearPanel == PearPanel.receiving) {
    //   return SlidingPanelReceive(
    //     peerDevice: devices[share.peerIndex],
    //     sc: sc,
    //     fileName: share.fileName,
    //     cancel: CloseButton(
    //       onPressed: () => share.cancelShare(),
    //     ),
    //   );
    // } else {
    //   return SlidingPanelAccept(
    //     peerDevice: devices[share.peerIndex],
    //     sc: sc,
    //     func: share.handleFileReceive,
    //     fileName: share.fileName,
    //     cancel: CloseButton(
    //       onPressed: () => share.cancelShare(),
    //     ),
    //   );
    // }
  }
}
