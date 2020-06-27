import 'dart:io';
import 'dart:typed_data';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

typedef void SetFileCallback(bool value, String name);

class FileSelect {
  String _path, _filePath = '', _extension;
  Map<String, String> _paths;
  bool _multiPick = false, _loadingPath = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = new TextEditingController();

  // allows user to upload files
  void openFileExplorer(SetFileCallback setFile) async {
    _controller.addListener(() => _extension = _controller.text);
    String initialDirectory;
    if (Platform.isMacOS || Platform.isWindows) {
      initialDirectory = (await getApplicationDocumentsDirectory()).path;
      final result = await showOpenPanel(
          allowsMultipleSelection: true, initialDirectory: initialDirectory);
      _path = '${result.paths.join('\n')}';
    } else if (Platform.isIOS || Platform.isAndroid) {
      _loadingPath = true;
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
    }
    _loadingPath = false;
    _filePath = _path;
    // _filePath = _path != null
    //     ? _path.split('/').last
    //     : _paths != null ? _paths.keys.toString() : '...';
    if (_filePath == '' || _filePath == null || _filePath == '...') {
      _filePath = '';
      setFile(false, _filePath);
    } else {
      setFile(true, _filePath);
    }
  }

  String nameFromPath(String filePath) {
    if (filePath == _path) {
      String fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';
      if (Platform.isWindows || Platform.isMacOS) {
        final fileReg = RegExp(r'(.+)\\(.+)', multiLine: true);
        fileName = fileReg
            .allMatches(filePath)
            .map((m) => m.group(2))
            .toString()
            .replaceAll('(', '')
            .replaceAll(')', '');
        print('fileName: ' + fileName);
        return fileName;
      } else {
        return fileName;
      }
    } else {
      return filePath;
    }
  }

  Future<Uint8List> _readFileByte(String filePath) async {
    var myUri = Uri.parse(filePath);
    var temp = File.fromUri(myUri);

    Uint8List bytes;
    await temp.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });

    return bytes;
  }
}
