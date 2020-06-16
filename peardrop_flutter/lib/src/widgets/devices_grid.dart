import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';

typedef FileShareCallback(int index);

class DevicesGrid extends StatelessWidget {
  DevicesGrid({this.devices, this.func});

  final List<Device> devices;
  final FileShareCallback func;

  @override
  Widget build(BuildContext context) {
    var columns = min(devices.length, 2);
    if (columns <= 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Text(
            'Install PearDrop on nearby devices to send files',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Open Sans'),
          ),
        ),
      );
    } else {
      return ListView(
        children: <Widget>[
          SizedBox(
            height: 60.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: columns,
                  children: List.generate(devices.length, (index) {
                    return Column(
                      children: [
                        RawMaterialButton(
                          onPressed: () => func(index),
                          elevation: 0.0,
                          fillColor: Color(0xff91c27d),
                          child: Icon(
                            devices[index].getIcon(),
                            size: 35.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                          child: Text(
                            devices[index].getName(),
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Open Sans',
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                          child: Text(
                            devices[index].getIP(),
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Open Sans',
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 60,
          ),
        ],
      );
    }
  }
}
