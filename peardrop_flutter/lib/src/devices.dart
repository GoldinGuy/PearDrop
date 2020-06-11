// this is the main page of the app (the first you see) and will show nearby devices that (when clicked on) will allow you to select file(s) to share

import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peardrop/src/nearby_device.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _path, _fileName, _extension, deviceId = "Device";
  Map<String, String> _paths;
  bool _loadingPath = false;
  // if multi-pick = true mutliple files can be selected
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
    getDeviceDetails();
  }

  getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = androidDeviceInfo.brand; // unique ID on Android
    }
  }

  // this method allows user to upload files
  void _openFileExplorer() async {
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
  }

  // this method clear the temporary cache
  void _clearCachedFiles() {
    FilePicker.clearTemporaryFiles().then((result) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed successyfully.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  final double _initFabHeight = 120.0;
  double _panelHeightOpen;
  double _panelHeightClosed = 95.0;

  @override
  Widget build(BuildContext context) {
    // this determines initial height
    _panelHeightOpen = MediaQuery.of(context).size.height * .55;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('PearDrop',
                style: TextStyle(
                    fontFamily: 'Open Sans', fontWeight: FontWeight.w700)),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                  Color(0xff91c27d),
                  Color(0xff559364),
                ])),
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SlidingUpPanel(
              maxHeight: _panelHeightOpen,
              minHeight: _panelHeightClosed,
              defaultPanelState: PanelState.CLOSED,
              // TODO: determine if parallax is neccessary
              // parallaxEnabled: true,
              // parallaxOffset: .5,
              body: _getBody(),
              panelBuilder: (sc) => _getPanel(sc),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0)),
              onPanelSlide: (double pos) => setState(() {}),
              collapsed: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0))),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Visible as ",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Open Sans',
                          ),
                        ),
                        Text(
                          '$deviceId',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    // TODO: change from dummy data
    var numDevices = 3, columns;
    var devices = new List(numDevices);
    devices[0] = new Device("Seth's XR", Icons.phone_iphone);
    devices[1] = new Device("Bob's Macbook", Icons.laptop_mac);
    devices[2] = new Device("Anirudh's PC", Icons.laptop_windows);
    if (devices.length < 4) {
      columns = devices.length;
    } else {
      columns = 3;
    }
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 60.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: columns,
                children: List.generate(devices.length, (index) {
                  return Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () => _openFileExplorer(),
                        elevation: 0.0,
                        fillColor: Color(0xff91c27d),
                        child: Icon(
                          devices[index].getIcon(),
                          size: 35.0,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(15.0),
                        shape: CircleBorder(),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                        child: Text(
                          devices[index].getName(),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
  }

  Widget _getPanel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Sharing to Bob's PC",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Open Sans',
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 30,
                      ),
                      Center(
                        child: Text('VOD_349278957_83.MP4',
                            style: TextStyle(
                                fontFamily: 'Open Sans', fontSize: 15)),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          padding: EdgeInsets.fromLTRB(2, 2, 2, 3),
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff559364)),
                          ),
                          height: 70,
                          width: 70,
                        ),
                        RawMaterialButton(
                          onPressed: () => _openFileExplorer(),
                          elevation: 0.0,
                          fillColor: Color(0xff91c27d),
                          child: Icon(
                            Icons.phone_iphone,
                            size: 35.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 30,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Text(
                              'Make sure both devices are unlocked, close together (within 1ft), and have bluetooth and WiFi enabled',
                              style: TextStyle(
                                  fontFamily: 'Open Sans', fontSize: 15)),
                        ),
                      )
                    ],
                  ),
                ),
                // Row()
              ],
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }
}
