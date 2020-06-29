import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/utilities/file_select.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

typedef void FileReceiveCallBack();
typedef void ResetCallBack();
typedef void CancelCallBack();
typedef void SetPearPanelCallback(bool isOpen);

class SlidingPanel extends StatelessWidget {
  SlidingPanel(
      {this.peerDevice,
      this.sc,
      this.filePath,
      this.setPearPanel,
      this.accept,
      this.cancel,
      this.reset});

  final String filePath;
  final Device peerDevice;
  final ScrollController sc;
  final FileReceiveCallBack accept;
  final ResetCallBack reset;
  final CancelCallBack cancel;
  final SetPearPanelCallback setPearPanel;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ('An Unknown Device' ?? peerDevice.getName()) +
                        ' would like to share',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[200],
                          ),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(15, 5, 15, 16),
                          child: Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Icon(
                                    Icons.description,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child:
                                      Text(FileSelect().nameFromPath(filePath),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Color(0xff559364),
                                          )),
                                ),
                              ],
                            ),
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(40, 17, 40, 5),
                        child: GestureDetector(
                          onTap: () {
                            setPearPanel(false);
                            accept();
                          },
                          child: Container(
                            width: 80,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff91c27d),
                                  Color(0xff559364),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(5, 5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ],
            ),
          ],
        ));
  }
}
