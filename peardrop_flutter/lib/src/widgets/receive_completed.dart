import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class ReceiveSheet {
  static void showReceiveSheet(BuildContext context, PeardropFile file,
      List<int> data, Directory directory) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
                title: const Text('Receive Complete'),
                // message: const Text(''),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: const Text('Save'),
                    onPressed: () {
                      saveFile(file, data, directory);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('Share'),
                    onPressed: () async {
                      shareFile(file, data, directory);
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('Save & Open'),
                    onPressed: () {
                      saveFile(file, data, directory);
                      openFile(file, directory);
                      Navigator.pop(context);
                    },
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: const Text('Cancel'),
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ));
          });
    } else {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.save),
                      title: Text('Save'),
                      onTap: () => {
                            saveFile(file, data, directory),
                            Navigator.pop(context),
                          }),
                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    onTap: () => {
                      shareFile(file, data, directory),
                      Navigator.pop(context),
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.open_in_browser),
                    title: Text('Save & Open'),
                    onTap: () => {
                      saveFile(file, data, directory),
                      openFile(file, directory),
                      Navigator.pop(context),
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.cancel),
                    title: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => {
                      Navigator.pop(context),
                    },
                  ),
                ],
              ),
            );
          });
    }
  }

  static void saveFile(
      PeardropFile file, List<int> data, Directory directory) async {
    var temp;
    if (!(await Permission.storage.isGranted)) {
      await Permission.storage.request();
    }
    temp = File('${directory.path}/${file.filename}');
    temp.writeAsBytesSync(data);
    print('${temp.absolute.path}');
    print('saved file to device');
  }

  static void shareFile(
      PeardropFile file, List<int> data, Directory directory) async {
    await WcFlutterShare.share(
      sharePopupTitle: 'PearDrop',
      mimeType: file.mimetype,
      fileName: file.filename,
      bytesOfFile: data,
    );
    print('shared file');
  }

  static void openFile(PeardropFile file, Directory directory) {
    final filePath = '${directory.path}/${file.filename}';
    OpenFile.open(filePath);
  }
}
