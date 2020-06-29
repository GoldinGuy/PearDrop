// This page will contain all user settings necessary for app

import 'package:flutter/material.dart';

const TextStyle HEADER_TEXT_STYLE = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18,
  color: Color(0xff6b9080),
);

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff91c27d),
      appBar: AppBar(
        elevation: 0.0,
        title: Center(
          child:
              Text('Settings', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        leading: IconButton(
          tooltip: 'Profile',
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Settings',
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildCard(
            child: Text(
              'Require Password',
              style: HEADER_TEXT_STYLE,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/require_password');
            },
          ),
          _buildCard(
            child: Text(
              'Clear Cache',
              style: HEADER_TEXT_STYLE,
            ),
            onPressed: () {},
          ),
          _buildCard(
            child: Text(
              'Airdrop Animation',
              style: HEADER_TEXT_STYLE,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/circle');
            },
          ),
          _buildCard(
            child: Text(
              'Terms of Service',
              style: HEADER_TEXT_STYLE,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    @required Widget child,
    @required void Function() onPressed,
    Color accentColor = const Color(0xffffffff),
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: accentColor,
        child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 26, bottom: 26),
            child: SizedBox(
              width: double.infinity,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
