import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:peardrop/src/home.dart';
import 'package:peardrop/src/utilities/file_select.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';
import 'package:peardrop/src/widgets/radar.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';

typedef void DeviceSelectCallback(int index);
typedef void SetPanelCallback(bool panelOpen, PearPanel panel);
typedef void ResetCallBack();

class DeviceSelectBody extends StatelessWidget {
  DeviceSelectBody(
      {this.devices,
      this.fileShare,
      this.fileName,
      this.setPanel,
      this.version,
      this.deviceName,
      this.reset});

  final List<Device> devices;
  final DeviceSelectCallback fileShare;
  final ResetCallBack reset;
  final SetPanelCallback setPanel;
  final String deviceName, fileName, version;

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
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => reset(),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/tos'),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              )
            ]),

        // TODO: design MultiChildRenderObjectWidget that can generate mutliple devices, fading them in and out as they appear nearby and displaying them in a random location within a set size
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
                  RawMaterialButton(
                    onPressed: () {
                      print("pressed");
                      setPanel(true, PearPanel.sharing);
                      fileShare(i);
                    },
                    elevation: 0.0,
                    fillColor: Color(0xff91c27d),
                    child: Icon(
                      devices[i].getIcon(),
                      size: 35.0,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
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
              // padding: EdgeInsets.only(top: 50),
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
                        // TODO: display actual network name
                        Text(version,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.grey)),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[200],
                          ),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(15, 5, 15, 16),
                          child: Text(fileName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff559364),
                              )),
                        )
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
}
