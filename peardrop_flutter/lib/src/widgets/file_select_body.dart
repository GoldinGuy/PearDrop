import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peardrop/src/home.dart';

typedef void FileSelectCallback();
typedef void FileSelectedCallback(bool value);

class FileSelectBody extends StatelessWidget {
  FileSelectBody({this.fileSelect, this.deviceName, this.setFileSelected});

  final FileSelectCallback fileSelect;
  final FileSelectedCallback setFileSelected;
  final String deviceName;

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Image.asset('assets/images/share.gif'),
          ),
          // Image(image: new AssetImage("assets/images/share.gif")),
          Text(
            'Share With PearDrop',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(35, 10, 35, 10),
            child: Text(
              'Your device is visible as ' +
                  deviceName +
                  '. Click below to start sharing, or begin from another nearby device',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setFileSelected(true);
                fileSelect();
              },
              child: Container(
                width: 175,
                height: 40,
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
                    'Select a file',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
