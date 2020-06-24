import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:peardrop/src/senderpacket.dart';

void main() {
  test('read', () {
    String filename = "example.txt";
    String mimetype = "text/plain";
    int data_len = 278475344;
    int triple_byte = (filename.length << 12) | mimetype.length;
    List<int> data = [
      (triple_byte >> 16) & 0xff,
      (triple_byte >> 8) & 0xff,
      triple_byte & 0xff,
      ...utf8.encode(filename),
      ...utf8.encode(mimetype),
      0, /*exts_len*/
      (data_len >> 56) & 0xff,
      (data_len >> 48) & 0xff,
      (data_len >> 40) & 0xff,
      (data_len >> 32) & 0xff,
      (data_len >> 24) & 0xff,
      (data_len >> 16) & 0xff,
      (data_len >> 8) & 0xff,
      data_len & 0xff,
    ];
    SenderPacket packet = SenderPacket.read(data);
    assert(packet.filename == filename);
    assert(packet.mimetype == mimetype);
    assert(packet.data_len == data_len);
  });
  test('write', () {
    String filename = "example.txt";
    String mimetype = "text/plain";
    int data_len = 278475344;
    int triple_byte = (filename.length << 12) | mimetype.length;
    List<int> expected = [
      (triple_byte >> 16) & 0xff,
      (triple_byte >> 8) & 0xff,
      triple_byte & 0xff,
      ...utf8.encode(filename),
      ...utf8.encode(mimetype),
      0, /*exts_len*/
      (data_len >> 56) & 0xff,
      (data_len >> 48) & 0xff,
      (data_len >> 40) & 0xff,
      (data_len >> 32) & 0xff,
      (data_len >> 24) & 0xff,
      (data_len >> 16) & 0xff,
      (data_len >> 8) & 0xff,
      data_len & 0xff,
    ];
    SenderPacket packet = SenderPacket(filename, mimetype, data_len);
    List<int> out = packet.write();
    assert(listEquals(out, expected));
  });
}