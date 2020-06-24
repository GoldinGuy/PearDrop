import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:peardrop/src/acktype.dart';
import 'package:peardrop/src/ackpacket.dart';

void main() {
  test('write', () {
    AckType type = AckType.normal(AckTypeType.DATA_PACKET);
    List<int> expected = [
      type.raw << 4 | 0,
    ];
    AckPacket packet = AckPacket(type);
    List<int> out = packet.write();
    assert(listEquals(out, expected));
  });
  test('tcp_read', () {
    AckType type = AckType.accept(AckTypeType.AD_PACKET);
    int port = 14678;
    List<int> data = [
      type.raw << 4 | 1, /*ext_len*/
      0, /* ACK_TCP_EXTENSION_TYPE */
      (port >> 8) & 0xff,
      port & 0xff,
    ];
    AckPacket packet = AckPacket.read(data);
    assert(packet.tcpPort == port);
  });
  test('tcp_write', () {
    AckType type = AckType.accept(AckTypeType.AD_PACKET);
    int port = 14678;
    List<int> expected = [
      type.raw << 4 | 1, /*ext_len*/
      0, /*ACK_TCP_EXTENSION_TYPE*/
      (port >> 8) & 0xff,
      port & 0xff,
    ];
    AckPacket packet = AckPacket(type);
    packet.tcpPort = port;
    List<int> out = packet.write();
    assert(listEquals(out, expected));
  });
}