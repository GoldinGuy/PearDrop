// this is the main page of the app (the first you see) and will show nearby devices that (when clicked on) will allow you to select file(s) to share

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:peardrop/src/widgets/bottom_version.dart';
import 'package:peardrop/src/widgets/devices_grid.dart';
import 'package:peardrop/src/widgets/peardrop_appbar.dart';
import 'package:peardrop/src/widgets/sliding_panel_receive.dart';
import 'package:peardrop/src/widgets/sliding_panel_send.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'utilities/nearby_device.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

typedef FileShareCallback(int index);

class _DevicesPageState extends State<DevicesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PanelController _pc = new PanelController();
  List<Device> devices = [];
  String _path, _fileName, _extension, nameOfPeer = "Unknown", deviceId;
  IconData iconOfPeer;
  Map<String, String> _paths;
  // if multi-pick = true mutliple files can be selected
  bool _multiPick = false, _loadingPath = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    // TODO: determine how best to use deviceInfo | deviceId = DeviceDetails().getDeviceDetails() as String;

    // dummy data
    devices.add(Device("Seth's XR", Icons.phone_iphone));
    devices.add(Device("Bob's Macbook", Icons.laptop_mac));
    devices.add(Device("Anirudh's PC", Icons.laptop_windows));
  }

  // cancels file sharing
  cancelShare() {
    _pc.close();
  }

  // handles what happens after file is selected and device chosen
  handleFileShare(index) {
    iconOfPeer = devices[index].getIcon();
    nameOfPeer = devices[index].getName();
    _openFileExplorer();
  }

  // allows user to upload files
  _openFileExplorer() async {
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

  // main build function
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: PearDropAppBar().getAppBar('PearDrop'),
        body: _getBody(),
        bottomNavigationBar: BottomVersionBar(version: '1.0.0+0'),
      ),
    );
  }

// returns main app body
  Widget _getBody() {
    double _panelHeightClosed = 0.0;
    double _panelHeightOpen = MediaQuery.of(context).size.height * 0.55;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        SlidingUpPanel(
          controller: _pc,
          maxHeight: _panelHeightOpen,
          minHeight: _panelHeightClosed,
          defaultPanelState: PanelState.CLOSED,
          backdropEnabled: true,
          backdropOpacity: 0.5,
          isDraggable: false,
          body: DevicesGrid(
            devices: devices,
            func: handleFileShare,
          ),
          panelBuilder: (sc) => _getSendingPanel(sc),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          onPanelSlide: (double pos) => setState(() {}),
        ),
      ],
    );
  }

// returns panel that will display when sending
  Widget _getSendingPanel(ScrollController sc) {
    return SlidingPanelSend(
      nameOfRecipient: '$nameOfPeer',
      iconOfRecipient: iconOfPeer,
      sc: sc,
      fileName: '$_fileName',
      cancel: CloseButton(
        onPressed: () => cancelShare(),
      ),
    );
  }

// returns panel that will display when receiving
  Widget _getReceivingPanel(ScrollController sc) {
    return SlidingPanelReceive(
      nameOfSender: '$nameOfPeer',
      iconOfSender: iconOfPeer,
      sc: sc,
      fileName: '$_fileName',
      cancel: CloseButton(
        onPressed: () => cancelShare(),
      ),
      deviceName: 'foobar',
    );
  }

  // clears the temporary cache
  // void _clearCachedFiles() {
  //   FilePicker.clearTemporaryFiles().then((result) {
  //     _scaffoldKey.currentState.showSnackBar(
  //       SnackBar(
  //         backgroundColor: result ? Colors.green : Colors.red,
  //         content: Text((result
  //             ? 'Temporary files removed successyfully.'
  //             : 'Failed to clean temporary files')),
  //       ),
  //     );
  //   });
  // }
}
