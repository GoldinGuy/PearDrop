import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:file_picker/file_picker.dart';

Future<String> selectFile(
    {FileType type = FileType.any, List<String> allowedExtensions}) async {
  String path;
  if (Platform.isIOS || Platform.isAndroid) {
    path = await FilePicker.getFilePath(
      type: type,
      allowedExtensions: allowedExtensions,
    );
  } else {
    //String initialDirectory = (await getApplicationDocumentsDirectory()).path;
    final result = await showOpenPanel(); //initialDirectory: initialDirectory);
    path = result.paths.isEmpty ? null : result.paths.first;
  }
  // XXX: Not sure about the ...
  if (path == null || path.isEmpty || path == '...') {
    return null;
  } else {
    return path;
  }
}
