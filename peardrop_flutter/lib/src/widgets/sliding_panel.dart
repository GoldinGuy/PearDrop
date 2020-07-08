import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:peardrop/src/utilities/word_list.dart';

class SlidingPanel extends StatefulWidget {
  SlidingPanel({this.file, this.sc, this.accept});
  final PeardropFile file;
  final ScrollController sc;
  final Function() accept;

  @override
  _SlidingPanelState createState() =>
      _SlidingPanelState(file: file, sc: sc, accept: accept);
}

class _SlidingPanelState extends State<SlidingPanel> {
  _SlidingPanelState({this.file, this.sc, this.accept});

  final PeardropFile file;
  final ScrollController sc;
  final Function() accept;
  bool buttonAccepted = false;

  @override
  Widget build(BuildContext context) {
    final deviceName = WordList.ipToWords(file?.ip) ?? 'An Unknown Device';
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Center(
        child: ListView(
          controller: sc,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$deviceName would like to share',
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
                            child: Text(
                              file?.filename ?? 'No filename',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff559364),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(40, 17, 40, 5),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            buttonAccepted = true;
                          });
                          accept;
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
                            child: getButtonContent(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getButtonContent() {
    if (!buttonAccepted) {
      return Text('Accept',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ));
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
  }
}
