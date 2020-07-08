import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libpeardrop/libpeardrop.dart';
import 'package:peardrop/src/utilities/word_list.dart';
import 'package:peardrop/src/widgets/accept_button.dart';

class SlidingPanel extends StatelessWidget {
  SlidingPanel({this.file, this.sc, this.accept});

  final PeardropFile file;
  final ScrollController sc;
  final Function() accept;

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
                    AcceptButton(accept: accept)
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
