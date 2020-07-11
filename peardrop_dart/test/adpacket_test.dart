import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:libpeardrop/src/adpacket.dart';

void main() {
  test('read', () {
    List<int> data = [
      0, /*ext_len*/
    ];
    AdPacket packet = AdPacket.read(data);
    assert(packet.tcpPort == null);
  });
  test('write', () {
    List<int> expected = [
      0, /*ext_len*/
    ];
    AdPacket packet = AdPacket();
    List<int> out = packet.write();
    assert(listEquals(out, expected));
  });
  test('tcp_read', () {
    int port = 14678;
    List<int> data = [
      1,
      /*ext_len*/
      0,
      /*TCP_EXTENSION_TYPE*/
      (port >> 8) & 0xff,
      port & 0xff,
    ];
    AdPacket packet = AdPacket.read(data);
    assert(packet.tcpPort == port);
  });
  test('tcp_write', () {
    int port = 14678;
    AdPacket packet = AdPacket();
    packet.tcpPort = port;
    List<int> expected = [
      1,
      /*ext_len*/
      0,
      /*TCP_EXTENSION_TYPE*/
      (port >> 8) & 0xff,
      port & 0xff,
    ];
    List<int> out = packet.write();
    assert(listEquals(out, expected));
  });
}
