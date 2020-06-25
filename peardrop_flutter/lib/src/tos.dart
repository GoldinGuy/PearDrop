import 'package:flutter/material.dart';
import 'package:peardrop/src/utilities/tos_const.dart';

class TermsDisplayScreen extends StatefulWidget {
  @override
  _TermsDisplayScreenState createState() => _TermsDisplayScreenState();
}

class _TermsDisplayScreenState extends State<TermsDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff559364),
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0.0,
        backgroundColor: Color(0xff559364),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Expanded(
                    flex: 1,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
