import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class ReceiveSheet {
  void getReceiveSheet(BuildContext context, PeardropFile file, List<int> data,
      Directory directory) {
    var temp;
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
                      Navigator.pop(context);
                      // Navigator.pop(context, '🙋 Yes');
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('Share'),
                    onPressed: () async {
                      await WcFlutterShare.share(
                        sharePopupTitle: 'PearDrop',
                        mimeType: file.mimetype,
                        fileName: file.filename,
                        bytesOfFile: data,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('Save & Open'),
                    onPressed: () {
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
                      onTap: () async => {
                            if (await Permission.storage.isGranted != true)
                              Permission.storage.request(),
                            temp = await File(
                                '${directory.path}/${file.filename}'),
                            temp.writeAsBytesSync(data),
                            print('${temp.absolute.path}'),
                            print('saved file to device'),
                            Navigator.pop(context),
                          }),
                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    onTap: () async => {
                      await WcFlutterShare.share(
                        sharePopupTitle: 'PearDrop',
                        mimeType: file.mimetype,
                        fileName: file.filename,
                        bytesOfFile: data,
                      ),
                      print('shared file'),
                      Navigator.pop(context),
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.open_in_browser),
                    title: Text('Save & Open'),
                    onTap: () async => {
                      if (await Permission.storage.isGranted != true)
                        Permission.storage.request(),
                      temp = await File('${directory.path}/${file.filename}'),
                      temp.writeAsBytesSync(data),
                      print('${temp.absolute.path}'),
                      print('saved file to device'),
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
}
