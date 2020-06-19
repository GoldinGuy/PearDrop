// this is the main page of the app (the first you see) and will show nearby devices that (when clicked on) will allow you to select file(s) to share

import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/bottom_version.dart';
import 'package:peardrop/src/widgets/devices_grid.dart';
import 'package:peardrop/src/widgets/peardrop_appbar.dart';
import 'package:peardrop/src/widgets/sliding_panel_accept.dart';
import 'package:peardrop/src/widgets/sliding_panel_receive.dart';
import 'package:peardrop/src/widgets/sliding_panel_send.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'utilities/nearby_device.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

enum PearPanel { sharing, receiving, accepting }
typedef FileShareCallback(int index);
typedef FileReceiveCallback();

class _DevicesPageState extends State<DevicesPage> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PanelController _pc = new PanelController();
  List<Device> devices = [];
  int peerIndex = 0;
  String _path, _fileName, _extension;
  InternetAddress deviceId = new InternetAddress('190.160.225.16');
  Map<String, String> _paths;
  bool _multiPick = false, _loadingPath = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = new TextEditingController();
  PearPanel pearPanel = PearPanel.sharing;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    // TODO: determine how best to use deviceInfo | deviceId = DeviceDetails().getDeviceDetails() as String;
    // dummy data
    devices.add(Device(Icons.phone_iphone, InternetAddress('140.70.235.92')));
    devices.add(Device(Icons.laptop_windows, InternetAddress('3.219.241.180')));
  }

  // handles what happens after file is selected and device chosen
  handleFileShare(int index) {
    peerIndex = index;
    _openFileExplorer();
  }

  // handles what happens after file is accepted
  handleFileReceive() {
    setState(() {
      pearPanel = PearPanel.receiving;
    });
  }

  // cancels file sharing
  cancelShare() {
    _pc.close();
  }

  // allows user to upload files
  _openFileExplorer() async {
    String initialDirectory;
    if (Platform.isMacOS || Platform.isWindows) {
      initialDirectory = (await getApplicationDocumentsDirectory()).path;
      final result = await showOpenPanel(
          allowsMultipleSelection: true, initialDirectory: initialDirectory);
      _path = '${result.paths.join('\n')}';
      // if (result.canceled) {
      //       showDialog(
      //       context: context,
      //       builder: (BuildContext context) => _buildAboutDialog(context),
      //     );
      //   scaffold.showSnackBar(SnackBar(content: Text('File Share Canceled')));
      // } else {
      //   final scaffold = Scaffold.of(context);
      //   scaffold.showSnackBar(SnackBar(
      //       content: Text('${result.paths.join('\n')}' + ' Selected')));
      // }
      setState(() {
        pearPanel = PearPanel.sharing;
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
      await Future.delayed(const Duration(milliseconds: 600), () {
        if ('$_fileName' != null) {
          _pc.open();
        }
      });
    } else if (Platform.isIOS || Platform.isAndroid) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType,
              allowedExtensions: (_extension?.isNotEmpty ?? false)
                  ? _extension?.replaceAll(' ', '')?.split(',')
                  : null);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType,
              allowedExtensions: (_extension?.isNotEmpty ?? false)
                  ? _extension?.replaceAll(' ', '')?.split(',')
                  : null);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        pearPanel = PearPanel.sharing;
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
      await Future.delayed(const Duration(milliseconds: 600), () {
        if ('$_fileName' != null) {
          _pc.open();
        }
      });
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: PearDropAppBar().getAppBar('PearDrop'),
        body: _getBody(),
        // bottomNavigationBar: BottomVersionBar(
        //   version: '1.0.0+0',
        //   deviceName: WordList().ipToWords(deviceId),
        // ),
      ),
    );
  }

// returns main app body
  Widget _getBody() {
    double _panelHeightClosed = 90.0;
    // double _panelHeightOpen = MediaQuery.of(context).size.height * 0.55;
    double _panelHeightOpen = MediaQuery.of(context).size.height * 0.85;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        SlidingUpPanel(
          controller: _pc,
          maxHeight: _panelHeightOpen,
          minHeight: _panelHeightClosed,
          defaultPanelState: PanelState.CLOSED,
          backdropEnabled: true,
          renderPanelSheet: false,
          backdropOpacity: 0.2,
          isDraggable: false,
          body: DevicesGrid(
            devices: devices,
            func: handleFileShare,
          ),
          collapsed: BottomVersionBar(
            version: '1.0.0+0',
            deviceName: WordList().ipToWords(deviceId),
          ),
          panelBuilder: (sc) => _getPanel(sc),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          onPanelSlide: (double pos) => setState(() {}),
        ),
      ],
    );
  }

// returns panel based on situation
  Widget _getPanel(ScrollController sc) {
    if (pearPanel == PearPanel.sharing) {
      return SlidingPanelSend(
        peerDevice: devices[peerIndex],
        sc: sc,
        fileName: '$_fileName',
        cancel: CloseButton(
          onPressed: () => cancelShare(),
        ),
      );
    } else if (pearPanel == PearPanel.receiving) {
      return SlidingPanelReceive(
        peerDevice: devices[peerIndex],
        sc: sc,
        fileName: '$_fileName',
        cancel: CloseButton(
          onPressed: () => cancelShare(),
        ),
      );
    } else if (pearPanel == PearPanel.accepting) {
      return SlidingPanelAccept(
        peerDevice: devices[peerIndex],
        sc: sc,
        func: handleFileReceive,
        fileName: '$_fileName',
        cancel: CloseButton(
          onPressed: () => cancelShare(),
        ),
      );
    } else {
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            controller: sc,
            children: <Widget>[Text('An Error Occurred')],
          ));
    }
  }
}
