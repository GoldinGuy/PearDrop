import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

import 'progress_indicator.dart';

class SlidingPanelReceive extends StatelessWidget {
  SlidingPanelReceive({
    this.peerDevice,
    this.sc,
    this.fileName,
    this.cancel,
  });
  // : super(listenable: sc);

  final String fileName;
  final ScrollController sc;
  final Device peerDevice;
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
              children: [cancel],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getTitle(),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Icon(
                                Icons.description,
                                size: 30,
                              ),
                            ),
                            Center(
                              child: Text(fileName,
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ]),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                  child: PercentageProgressIndicator(
                      centerIcon: peerDevice.getIcon()),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, 10, 3, 0),
                        child: Icon(
                          // Icons.device_unknown,
                          Icons.devices,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                          child: Text(
                              'Make sure both devices are unlocked, within a reasonable distance, and have Bluetooth and WiFi enabled',
                              style: TextStyle(fontSize: 15)),
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

  getTitle() {
    String nameOfSender = peerDevice.getName();
    if (nameOfSender != null && nameOfSender != '') {
      return Text(
        "Receiving File From " + nameOfSender,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 20.0,
        ),
      );
    } else {
      return Text(
        "Preparing to Receive",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 20.0,
        ),
      );
    }
  }
}
