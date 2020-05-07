import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

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

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          backgroundColor: Color(0xff759055),
          title: const Text('PearDrop',
              style: TextStyle(
                color: Colors.white,
              )),
        ),
        body: new Center(
            child: new Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: new SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new DropdownButton(
                      hint: new Text('Load path from'),
                      value: _pickingType,
                      items: <DropdownMenuItem>[
                        new DropdownMenuItem(
                          child: new Text('Audio'),
                          value: FileType.audio,
                        ),
                        new DropdownMenuItem(
                          child: new Text('Images'),
                          value: FileType.image,
                        ),
                        new DropdownMenuItem(
                          child: new Text('Video'),
                          value: FileType.video,
                        ),
                        new DropdownMenuItem(
                          child: new Text('All Media'),
                          value: FileType.media,
                        ),
                        new DropdownMenuItem(
                          child: new Text('All Files'),
                          value: FileType.any,
                        ),
                        // new DropdownMenuItem(
                        //   child: new Text('CUSTOM FORMAT'),
                        //   value: FileType.custom,
                        // ),
                      ],
                      onChanged: (value) => setState(() {
                            _pickingType = value;
                            if (_pickingType != FileType.custom) {
                              _controller.text = _extension = '';
                            }
                          })),
                ),
                new ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 100.0),
                  child: _pickingType == FileType.custom
                      ? new TextFormField(
                          maxLength: 15,
                          autovalidate: true,
                          controller: _controller,
                          decoration:
                              InputDecoration(labelText: 'File extension'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                        )
                      : new Container(),
                ),
                new ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 200.0),
                  child: new SwitchListTile.adaptive(
                    title:
                        new Text('Pick multiple', textAlign: TextAlign.right),
                    onChanged: (bool value) =>
                        setState(() => _multiPick = value),
                    value: _multiPick,
                    activeColor: Color(0xff759055),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () => _openFileExplorer(),
                        child: new Text("Upload files"),
                      ),
                      new RaisedButton(
                        onPressed: () => _clearCachedFiles(),
                        child: new Text("Clear temporary files"),
                      ),
                    ],
                  ),
                ),
                new Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator())
                      : _path != null || _paths != null
                          ? new Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: new Scrollbar(
                                  child: new ListView.separated(
                                itemCount: _paths != null && _paths.isNotEmpty
                                    ? _paths.length
                                    : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath =
                                      _paths != null && _paths.isNotEmpty;
                                  final String name = 'File $index: ' +
                                      (isMultiPath
                                          ? _paths.keys.toList()[index]
                                          : _fileName ?? '...');
                                  final path = isMultiPath
                                      ? _paths.values.toList()[index].toString()
                                      : _path;

                                  return new ListTile(
                                    title: new Text(
                                      name,
                                    ),
                                    subtitle: new Text(path),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        new Divider(),
                              )),
                            )
                          : new Container(),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
