import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';
import 'package:peardrop/src/widgets/progress_device.dart';
import 'package:peardrop/src/widgets/radar.dart';

typedef void DeviceSelectCallback(int index);
typedef void ResetCallBack();
typedef void FileSelectCallback();

class DeviceSelectBody extends StatelessWidget {
  DeviceSelectBody(
      {this.devices,
      this.fileShare,
      this.fileSelect,
      this.fileName,
      this.version,
      this.deviceName,
      this.reset});

  final List<Device> devices;
  final DeviceSelectCallback fileShare;
  final ResetCallBack reset;
  final String deviceName, fileName, version;
  final FileSelectCallback fileSelect;

  @override
  Widget build(BuildContext context) {
    var deviceHeight = 25.0;
    if (Platform.isWindows || Platform.isMacOS) {
      deviceHeight = 2.5;
    }

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
      child: Column(children: [
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
        // Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       InkWell(
        //         onTap: () => reset(),
        //         child: Padding(
        //           padding: EdgeInsets.all(15),
        //           child: Icon(
        //             // Icons.arrow_back_ios,
        //             Icons.library_books,
        //             color: Colors.white,
        //             size: 24,
        //           ),
        //         ),
        //       ),
        //       InkWell(
        //         onTap: () => Navigator.pushNamed(context, '/tos'),
        //         child: Padding(
        //           padding: EdgeInsets.all(15),
        //           child: Icon(
        //             Icons.info,
        //             color: Colors.white,
        //             size: 24,
        //           ),
        //         ),
        //       )
        //     ]),
        Expanded(
          child: Radar(
            children: List.generate(devices.length, (i) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200],
                    ),
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 6),
                    child: Text(
                      devices[i].getName(),
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DeviceProgressIndicator(
                    fileShare: fileShare,
                    i: i,
                    devices: devices,
                  )
                ],
              );
            }),
          ),
        ),
        // bottom widget displaying user device and file information
        Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: const Offset(0.0, 4.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(deviceName,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                                color: Colors.black)),
                        Text(version,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.grey)),
                        InkWell(
                          onTap: () {
                            fileSelect();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[200],
                              ),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.fromLTRB(15, 5, 15, 16),
                              child: Expanded(
                                child: getFileContainer(),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 85,
              height: 85,
              // margin: EdgeInsets.only(bottom: 50),
              decoration:
                  ShapeDecoration(shape: CircleBorder(), color: Colors.white),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset('assets/images/icon.png').image,
                  ),
                ),
                // ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget getFileContainer() {
    if (fileName != null && fileName != '') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Icon(
              Icons.expand_more,
              size: 20,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Icon(
              Icons.description,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(fileName,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xff559364),
                )),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Icon(
              Icons.expand_more,
              size: 20,
            ),
          ),
          Center(
            child: Text('Select a file to start sharing',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xff559364),
                )),
          ),
        ],
      );
    }
  }
}
