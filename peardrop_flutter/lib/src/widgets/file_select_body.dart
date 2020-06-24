import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/home.dart';

typedef void FileSelectCallback(SetFileCallback file);
typedef void SetFileCallback(bool value, String name);

class FileSelectBody extends StatelessWidget {
  FileSelectBody({this.fileSelect, this.deviceName, this.setFile});

  final FileSelectCallback fileSelect;
  final SetFileCallback setFile;
  final String deviceName;
  final List<Image> headers = [
    Image.asset('assets/images/header1.png'),
    Image.asset('assets/images/header2.png'),
    Image.asset('assets/images/header3.png'),
    Image.asset('assets/images/header4.png'),
    Image.asset('assets/images/header5.png'),
    Image.asset('assets/images/header6.png'),
    Image.asset('assets/images/header7.png'),
  ];

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff91c27d),
            Color(0xff559364),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Container(
                child: getHeaderImage(),
                height: 288,
              ),
            ),
            // Image(image: new AssetImage("assets/images/share.gif")),
            Text(
              'Share With PearDrop',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 23),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(35, 15, 35, 10),
              child: RichText(
                text: TextSpan(
                    text: 'Your device is visible as ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: deviceName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            '. \nClick below to start sharing, or begin from another nearby device',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ]),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  fileSelect(setFile);
                },
                child: Container(
                  width: 185,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffe7f0ef),
                        Color(0xffe7f0ef),
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
                      'Select a file',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: <Color>[
                              Color(0xff91c27d),
                              Color(0xff559364),
                            ],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Image getHeaderImage() {
    return headers[Random().nextInt(headers.length)];
  }
}
