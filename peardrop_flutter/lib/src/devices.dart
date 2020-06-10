// this is the main page of the app (the first you see) and will show nearby devices that (when clicked on) will allow you to select file(s) to share

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peardrop/src/nearby_device.dart';
import 'package:file_picker/file_picker.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    final title = 'PearDrop';

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    String _fileName;
    String _path;
    Map<String, String> _paths;
    String _extension;
    bool _loadingPath = false;
    // if multi-pick = true mutliple files can be selected
    bool _multiPick = false;
    FileType _pickingType = FileType.any;
    TextEditingController _controller = new TextEditingController();

    @override
    void initState() {
      super.initState();
      _controller.addListener(() => _extension = _controller.text);
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

    // dummy data
    var numDevices = 1;
    var devices = new List(numDevices);
    devices[0] = new Device("Seth's Laptop", Icons.phone_iphone);
    // devices[1] = new Device("Bob's Macbook", Icons.laptop_mac);
    // devices[2] = new Device("Anirudh's PC", Icons.laptop_windows);
    // devices[3] = new Device("Jack's Samsung", Icons.phone_android);
    // devices[4] = new Device("Suzy's Mac", Icons.laptop_mac);

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Center(
            child: Text(title,
                style: TextStyle(
                    fontFamily: 'Open Sans', fontWeight: FontWeight.w700)),
            // TODO: determine solid color VS gradient  // backgroundColor: Color(0xff6b9080),
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
          // TODO: uncomment buttons when pages are ready to be implemented
          // leading: IconButton(
          //   tooltip: 'History',
          //   icon: Icon(Icons.history),
          //   onPressed: () => Navigator.pushNamed(context, '/history'),
          // ),
          // actions: <Widget>[
          //   IconButton(
          //     tooltip: 'Settings',
          //     icon: Icon(Icons.settings),
          //     onPressed: () => Navigator.pushNamed(context, '/settings'),
          //   ),
          // ],
        ),
        body: GridView.count(
          crossAxisCount: 3,
          children: List.generate(devices.length, (index) {
            return Column(
              children: [
                Spacer(),
                RawMaterialButton(
                  onPressed: () => _openFileExplorer(),
                  elevation: 0.0,
                  fillColor: Color(0xffeaf4f4),
                  child: Icon(
                    devices[index].getIcon(),
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: Text(
                    devices[index].getName(),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        bottomNavigationBar: Stack(
          children: [
            new Container(
              height: 30.0,
              color: Colors.white12,
              child: Center(
                child: Text(
                  '1.0.0+0',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
