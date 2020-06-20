import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:peardrop/src/home.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';
import 'package:peardrop/src/widgets/sliding_panel.dart';

typedef void DeviceSelectCallback(int index);
typedef void SetPanelCallback(bool panelOpen, PearPanel panel);
typedef void ResetCallBack();

class DeviceSelectBody extends StatelessWidget {
  DeviceSelectBody(
      {this.devices,
      this.fileShare,
      // this.fileName,
      this.setPanel,
      this.deviceName,
      this.reset});

  final List<Device> devices;
  final DeviceSelectCallback fileShare;
  final ResetCallBack reset;
  final SetPanelCallback setPanel;
  final String deviceName;

  Widget build(BuildContext context) {
    if (devices.length <= 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Text(
            'Install PearDrop on nearby devices to send files',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
    } else {
      var topHeight = 20.0, deviceHeight = 0.0;
      topHeight = max((70 ~/ devices.length), 20).toDouble();
      if (Platform.isAndroid || Platform.isIOS) {
        deviceHeight = 25;
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
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      reset();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.topRight,
              //   child: Padding(
              //     padding: EdgeInsets.all(10),
              //     child: Text(
              //       fileName,
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(
            height: topHeight,
          ),
          Center(
            child: Container(
              height: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('PearDrop',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 23,
                          color: Colors.white)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
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
                              text: '. \nSelect a nearby device to share with',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ]),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, i) {
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: FadeInAnimation(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 88.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 40.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                offset: const Offset(0.0, 4.0),
                              ),
                            ],
                          ),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setPanel(true, PearPanel.sharing);
                                fileShare(i);
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      devices[i].getIcon(),
                                      size: 40.0,
                                      color: Colors.black,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(18, 22, 15, 22),
                                      child: Column(
                                        children: [
                                          Text(
                                            devices[i].getName(),
                                            style: TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                          Text(
                                            devices[i]
                                                .getIP()
                                                .address
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      );
    }
  }
}
