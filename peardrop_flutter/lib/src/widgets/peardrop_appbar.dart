import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PearDropAppBar {
  PearDropAppBar({this.title});

  final String title;

  getAppBar(String title) {
    return AppBar(
      title: Center(
        child: Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
              Color(0xff91c27d),
              Color(0xff559364),
            ])),
      ),
    );
  }
}
