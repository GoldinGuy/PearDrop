// // this is the main page of the app (the first you see) and will show nearby devices that (when clicked on) will allow you to select file(s) to share

// import 'dart:io';

// import 'package:file_chooser/file_chooser.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';

// import 'package:peardrop/src/widgets/peardrop_appbar.dart';

// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'utilities/nearby_device.dart';

// class SelectFilePage extends StatefulWidget {
//   @override
//   _SelectFilePageState createState() => _SelectFilePageState();
// }

// enum PearPanel { sharing, receiving, accepting }
// typedef FileShareCallback(int index);
// typedef FileReceiveCallback();

// class _SelectFilePageState extends State<SelectFilePage> {
//   PanelController _pc = new PanelController();
//   List<Device> devices = [];
//   int peerIndex = 0;
//   String _path, _fileName, _extension;
//   InternetAddress deviceId = new InternetAddress('190.160.225.16');
//   Map<String, String> _paths;
//   bool _multiPick = false, _loadingPath = false;
//   FileType _pickingType = FileType.any;
//   TextEditingController _controller = new TextEditingController();
//   PearPanel pearPanel = PearPanel.sharing;

//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() => _extension = _controller.text);
//     // TODO: determine how best to use deviceInfo | deviceId = DeviceDetails().getDeviceDetails() as String;
//     // dummy data
//     devices.add(Device(Icons.phone_iphone, InternetAddress('140.70.235.92')));
//     devices.add(Device(Icons.laptop_windows, InternetAddress('3.219.241.180')));
//   }

//   // handles what happens after file is selected and device chosen
//   handleFileShare(int index) {
//     peerIndex = index;
//     _openFileExplorer();
//   }

//   // handles what happens after file is accepted
//   handleFileReceive() {
//     setState(() {
//       pearPanel = PearPanel.receiving;
//     });
//   }

//   // cancels file sharing
//   cancelShare() {
//     _pc.close();
//   }

//   // allows user to upload files
//   _openFileExplorer() async {
//     String initialDirectory;
//     if (Platform.isMacOS || Platform.isWindows) {
//       initialDirectory = (await getApplicationDocumentsDirectory()).path;
//       final result = await showOpenPanel(
//           allowsMultipleSelection: true, initialDirectory: initialDirectory);
//       _path = '${result.paths.join('\n')}';
//       setState(() {
//         pearPanel = PearPanel.sharing;
//         _loadingPath = false;
//         _fileName = _path != null
//             ? _path.split('/').last
//             : _paths != null ? _paths.keys.toString() : '...';
//       });
//       await Future.delayed(const Duration(milliseconds: 600), () {
//         if ('$_fileName' != null) {
//           _pc.open();
//         }
//       });
//     } else if (Platform.isIOS || Platform.isAndroid) {
//       setState(() => _loadingPath = true);
//       try {
//         if (_multiPick) {
//           _path = null;
//           _paths = await FilePicker.getMultiFilePath(
//               type: _pickingType,
//               allowedExtensions: (_extension?.isNotEmpty ?? false)
//                   ? _extension?.replaceAll(' ', '')?.split(',')
//                   : null);
//         } else {
//           _paths = null;
//           _path = await FilePicker.getFilePath(
//               type: _pickingType,
//               allowedExtensions: (_extension?.isNotEmpty ?? false)
//                   ? _extension?.replaceAll(' ', '')?.split(',')
//                   : null);
//         }
//       } on PlatformException catch (e) {
//         print("Unsupported operation" + e.toString());
//       }
//       if (!mounted) return;
//       setState(() {
//         pearPanel = PearPanel.sharing;
//         _loadingPath = false;
//         _fileName = _path != null
//             ? _path.split('/').last
//             : _paths != null ? _paths.keys.toString() : '...';
//       });
//       await Future.delayed(const Duration(milliseconds: 600), () {
//         if ('$_fileName' != null) {
//           _pc.open();
//         }
//       });
//     }
//   }

//   // main build function
//   @override
//   Widget build(BuildContext context) {}
// }
