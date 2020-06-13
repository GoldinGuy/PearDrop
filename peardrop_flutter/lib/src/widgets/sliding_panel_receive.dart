import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SlidingPanelReceive extends StatelessWidget {
  SlidingPanelReceive(
      {this.nameOfSender,
      this.iconOfSender,
      this.sc,
      this.fileName,
      this.cancel,
      this.deviceName});
  // : super(listenable: sc);

  final String nameOfSender, fileName, deviceName;
  final ScrollController sc;
  final IconData iconOfSender;
  final CloseButton cancel;

  @override
  Widget build(BuildContext context) {
    final spinkit = SpinKitDoubleBounce(
      color: Colors.white,
    );
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Center(
                    child: Stack(
                      children: [
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        //   padding: EdgeInsets.fromLTRB(2, 2, 2, 3),
                        //   child: CircularProgressIndicator(
                        //     strokeWidth: 6,
                        //     valueColor: AlwaysStoppedAnimation<Color>(
                        //         Color(0xff559364)),
                        //   ),
                        //   height: 80,
                        //   width: 70,
                        // ),
                        RawMaterialButton(
                          onPressed: () => {},
                          elevation: 0.0,
                          fillColor: Color(0xff91c27d),
                          child: spinkit,
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 3),
                  child: Center(
                    child: Text('Your device is visible as',
                        style:
                            TextStyle(fontFamily: 'Open Sans', fontSize: 16)),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                  child: Center(
                    child: Text(
                      deviceName,
                      style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
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

  getTitle() {
    if (nameOfSender != null && nameOfSender != '') {
      return Text(
        "Receiving File From " + nameOfSender,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Open Sans',
          fontSize: 20.0,
        ),
      );
    } else {
      return Text(
        "Preparing to Receive",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Open Sans',
          fontSize: 20.0,
        ),
      );
    }
  }
}
