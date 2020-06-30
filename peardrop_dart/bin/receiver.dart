import 'dart:io';

import 'package:libpeardrop/libpeardrop.dart';

void main() async {
  var file = await Peardrop.receive();
  print('Got file');
  stdout.write(
      'Should we receive from this sender (addr=${file.ip.address},filename=${file.filename},mimetype=${file.mimetype})? [y/n]');
  await stdout.flush();
  var inp = stdin.readLineSync().trim();
  if (inp == 'y') {
    var data = await file.accept();
    print('Accepted and received file');
    var f = new File(file.filename);
    await f.writeAsBytes(data, flush: true);
    print('Written to file');
  } else {
    await file.reject();
    print('Rejected send');
  }
  exit(0);
}
