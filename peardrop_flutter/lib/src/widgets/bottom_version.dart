import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomVersionBar extends StatelessWidget {
  BottomVersionBar({this.version, this.deviceName});

  final String version, deviceName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Padding(
        //   padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        //   child: Text(
        //     'Visible as ' + deviceName,
        //     style: TextStyle(
        //         fontWeight: FontWeight.w500, color: Colors.grey[500]),
        //   ),
        // )
        Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Text(
            version,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        )
      ],
    );
  }
}

// return Container(
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
//   ),
//   margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
//   child: Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Padding(
//           padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
//           child: Text(
//             'Your device is visible as ' + deviceName,
//             style: TextStyle(fontWeight: FontWeight.w500),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
//           child: Text(
//             version,
//             style: TextStyle(color: Colors.grey[500]),
//           ),
//         )
//       ],
//     ),
//   ),
// );
