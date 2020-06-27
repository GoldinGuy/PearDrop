import 'dart:io';

import 'package:flutter/material.dart';
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum PearPanel { sharing, receiving, accepting, done }

class _HomePageState extends State<HomePage> {
  List<Device> devices = [];
  InternetAddress deviceId = new InternetAddress('190.160.225.16');
  bool pearPanelOpen = false, fileSelected = false;
  int peerIndex = 0;
  FileSelect select;
  String filePath = '';
  PeardropFile file;
  PanelController _pc = new PanelController();
  PearPanel pearPanel = PearPanel.accepting;

  @override
  void initState() {
    super.initState();
    select = new FileSelect();
    fileSelected = false;
    DeviceDetails.getDeviceDetails();
    // dummy data
    devices.add(
        Device.dummy(Icons.laptop_windows, InternetAddress('3.219.241.180')));
    // devices.add(Device(Icons.laptop_windows,
    //     InternetAddress('2001:0db8:85a3:0000:0000:8a2e:0370:7334')));
    _handleFileAccept();
  }

  //   Sending:
// Call Peardrop.send with the file information, which returns a Future<Stream<PeardropReceiver>>.
// Each receiver is bound to the original file, so calling PeardropReceiver.send will attempt to send the file to the receiver, possibly throwing an exception if rejected.

// Receiving:
// Call Peardrop.receive which returns a Future<PeardropFile>.
// The file has information available, from which you can call PeardropFile.accept (yielding the contents of the file, List<int>), or PeardropFile.reject (which rejects the send).

// handles what happens when file is being accepted
  void _handleFileAccept() async {
    while (true) {
      try {
        file = await Peardrop.receive();
        if (file != null) {
          setState(() {
            file = file;
          });
          setPearPanel(true, PearPanel.accepting);
          setFile(true, file.filename);
        }
      } catch (e) {
        print('error caught: $e');
      }
    }
  }

  // handles what happens after file is accepted
  void _handleFileReceive() {
    file.accept();
  }

  // handleFileSend(fileName, filePath, mime, ip) {}
  void _handleFileSelect() async {
    select.openFileExplorer(setFile);
    String fileName = select.nameFromPath(filePath);
    List<int> list = await select.readFileByte(filePath);
    while (true) {
      Stream<PeardropReceiver> stream =
          await Peardrop.send(list, fileName, mime(fileName));
      try {
        stream.listen((PeardropReceiver receiver) {
          devices.add(Device(Icons.phone_iphone, receiver));
          print('devices' + devices.toString());
        });
      } catch (e) {
        print('error caught: $e');
      }
    }
  }

  // handles what happens after file is selected and device chosen
  void _handleFileShare(int index) async {
    peerIndex = index;
    try {
      await devices[peerIndex].getReceiver().send();
    } catch (e) {
      print('error caught: $e');
    }
  }

// resets the app back to the main screen
  void reset() {
    setFile(false, null);
    setPearPanel(false, PearPanel.accepting);
  }

  void _cancel() {
    file.reject();
  }

// sets whether there is currently a file selected or not
  void setFile(bool selected, String name) {
    setState(() {
      fileSelected = selected;
      filePath = name;
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
              maxHeight: _panelHeightOpen,
              minHeight: 0.0,
              defaultPanelState: PanelState.CLOSED,
              backdropEnabled: true,
              backdropOpacity: 0.2,
              isDraggable: false,
              body: _getBody(),
              panelBuilder: (sc) => SlidingPanel(
                peerDevice: devices[peerIndex],
                sc: sc,
                pearPanel: pearPanel,
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

  // returns main app body
  Widget _getBody() {
    if (fileSelected) {
      return DeviceSelectBody(
          devices: devices,
          reset: reset,
          version: '1.0.0+0',
          fileName: select.nameFromPath(filePath),
          fileShare: _handleFileShare,
          deviceName: WordList().ipToWords(deviceId),
          setPanel: setPearPanel);
    } else {
      return FileSelectBody(
        fileSelect: _handleFileSelect,
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
