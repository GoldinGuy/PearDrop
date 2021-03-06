import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:peardrop/src/utilities/nearby_device.dart';
import 'package:peardrop/src/widgets/progress_device.dart';
import 'package:peardrop/src/widgets/radar.dart';

class PearDropBody extends StatelessWidget {
  PearDropBody({
    this.devices,
    this.fileSelect,
    this.fileSelected,
    this.fileName,
    this.version,
    this.setSharing,
    this.deviceName,
  });

  final List<Device> devices;
  final String deviceName, fileName, version;
  final Function() fileSelect;
  final Function(bool value) setSharing;
  final bool fileSelected;

  final List<Image> headers = [
    Image.asset('assets/images/header1.png'),
    Image.asset('assets/images/header2.png'),
    Image.asset('assets/images/header3.png'),
  ];

  @override
  Widget build(BuildContext context) {
    var deviceHeight = 25.0;
    if (Platform.isWindows || Platform.isMacOS) {
      deviceHeight = 2.5;
    }
    return Material(
      child: Container(
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
        child: Column(
          children: [
            SizedBox(
              height: deviceHeight,
            ),
            Align(
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/tos'),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              alignment: Alignment.topRight,
            ),
            _getBody(),
            _getInfoContainer(MediaQuery.of(context).size.width),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    if (!fileSelected) {
      var deviceHeight = 28.0;
      if (Platform.isWindows || Platform.isMacOS) {
        deviceHeight = 17;
      }
      return Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: deviceHeight,
                    left: 15,
                    right: 15,
                  ),
                  child: Text(
                    'Share With PearDrop',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 15,
                    right: 15,
                    bottom: deviceHeight,
                  ),
                  child: Text(
                    'Press below to start sharing, or begin from another nearby device',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 7, 0, 3),
                  child: Container(
                    child: headers[Random().nextInt(headers.length)],
                    height: 288,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Radar(
          children: List.generate(devices.length, (i) {
            return Container(
              decoration: BoxDecoration(),
              child: DeviceWidget(device: devices[i], setSharing: setSharing),
            );
          }),
        ),
      );
    }
  }

  Widget _getInfoContainer(double width) {
    var containerHeight = 20.0;
    if (Platform.isWindows || Platform.isMacOS) {
      containerHeight = 40.0;
    }
    final innerContainer = SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: containerHeight),
            child: Text(
              deviceName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: InkWell(
              onTap: fileSelect,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.fromLTRB(15, 5, 15, 11),
                child: _getFileContainer(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              version,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
    if (!fileSelected) {
      return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Column(
              children: [
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: const Offset(0.0, 4.0),
                      ),
                    ],
                  ),
                  child: innerContainer,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: const Offset(0.0, 4.0),
                      ),
                    ],
                  ),
                  child: innerContainer,
                ),
              ],
            ),
          ),
          Container(
            width: 85,
            height: 85,
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white,
            ),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset('assets/images/icon.png').image,
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget _getFileContainer() {
    final expand = Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      child: Icon(
        Icons.expand_more,
        size: 20,
      ),
    );
    if (fileName != null && fileName.isNotEmpty) {
      return Row(
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
              p.basename(fileName),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xff559364),
              ),
            ),
          ),
          expand,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  'Select a file to start sharing',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xff559364),
                  ),
                ),
              ),
            ),
          ),
          expand,
        ],
      );
    }
  }
}
