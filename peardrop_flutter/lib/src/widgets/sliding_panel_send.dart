import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

class SlidingPanelSend extends StatelessWidget {
  SlidingPanelSend(
      {this.nameOfRecipient,
      this.iconOfRecipient,
      this.sc,
      this.fileName,
      this.cancel});

  final String nameOfRecipient, fileName;
  final ScrollController sc;
  final IconData iconOfRecipient;
  final CloseButton cancel;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Text('Cancel'),
                cancel,
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Sharing to " + nameOfRecipient,
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
                  padding: EdgeInsets.fromLTRB(0, 21, 0, 21),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 30,
                      ),
                      Center(
                        child: Text(fileName,
                            style: TextStyle(
                                fontFamily: 'Open Sans', fontSize: 15)),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
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
                          onPressed: () => {},
                          elevation: 0.0,
                          fillColor: Color(0xff91c27d),
                          child: Icon(
                            iconOfRecipient,
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
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, 5, 3, 0),
                        child: Icon(
                          // Icons.device_unknown,
                          Icons.devices,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
                          child: Text(
                              'Make sure both devices are unlocked, within a reasonable distance, and have Bluetooth and WiFi enabled',
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
