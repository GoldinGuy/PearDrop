import 'dart:io';

import 'package:libpeardrop/libpeardrop.dart';

void main(List<String> arguments) async {
  var filename = arguments.first;
  if (filename == null) {
    print('Need filename as first argument');
    exit(1);
  }
  List<int> file = await File(filename).readAsBytes();
  await for (var receiver
      in await Peardrop.send(file, filename, "text/plain")) {
    stdout.write(
        'Should we send to this receiver (addr=${receiver.ip.address})? [y/n]');
    await stdout.flush();
    var inp = stdin.readLineSync();
    if (inp == 'y') {
      print('Sending');
      await receiver.send();
      print('Send complete');
      break;
    } else {
      print('Continuing to next receiver');
    }
  }
  exit(0);
}
