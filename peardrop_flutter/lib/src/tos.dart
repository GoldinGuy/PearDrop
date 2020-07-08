import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/tos_const.dart';

class TermsDisplayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      backgroundColor: Color(0xff91c27d),
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Text(
            TOS_STRING,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ));
  }
}
