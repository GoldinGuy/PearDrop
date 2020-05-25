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
    // if multi-pick is true mutliple files can be selected
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
    var numDevices = 3;
    var devices = new List(numDevices);
    devices[0] = new Device("Seth's iPhone", Icons.phone_iphone);
    devices[1] = new Device("Nick's Macbook", Icons.laptop_mac);
    devices[2] = new Device("Uanirudhx's PC", Icons.laptop_windows);

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(title),
          // TODO: determine which bg color is better - backgroundColor: Color(0xff759055),
          backgroundColor: Color(0xff6b9080),
          // TODO: alter buttons to lead to actual pages
          actions: <Widget>[
            IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: GridView.count(
          crossAxisCount: 3,
          children: List.generate(devices.length, (index) {
            return Column(
              children: [
                Spacer(),
                // TODO: determine shape outline vs bg
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
                Text(
                  devices[index].getName(),
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
