import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/devices_page.dart';
import 'package:peardrop/src/utilities/sharing_service.dart';

typedef FileReceiveCallback();

class SlidingPanelAccept extends StatelessWidget {
  SlidingPanelAccept({
    this.nameOfSender,
    this.iconOfSender,
    this.sc,
    this.fileName,
    this.func,
    this.cancel,
  });
  // : super(listenable: sc);

  final String nameOfSender, fileName;
  final ScrollController sc;
  final IconData iconOfSender;
  final FileReceiveCallback func;
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  nameOfSender,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Open Sans',
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                RawMaterialButton(
                  onPressed: () => {},
                  elevation: 0.0,
                  fillColor: Color(0xff91c27d),
                  child: Icon(
                    iconOfSender,
                    size: 35.0,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  'would like to share a file with you',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Open Sans',
                    fontSize: 16.0,
                  ),
                ),
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
                            Icon(
                              Icons.description,
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
                    ]),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(40, 16, 40, 2),
                  child: GestureDetector(
                    onTap: () {
                      func();
                    },
                    child: Container(
                      width: 100,
                      height: 50,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }
}
