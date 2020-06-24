import 'package:flutter_test/flutter_test.dart';

import 'package:peardrop/src/acktype.dart';

void main() {
  test('data', () {
    AckType type = AckType.normal(AckTypeType.DATA_PACKET);
    assert(!type.isAccepted);
    assert(type.type == AckTypeType.DATA_PACKET);
    assert(type.raw == AckTypeType.DATA_PACKET);
  });

  test('sender_reject', () {
    int data = 0 << 3 | AckTypeType.SENDER_PACKET;
    AckType type = AckType.raw(data);
    assert(!type.isAccepted);
    assert(type.type == AckTypeType.SENDER_PACKET);
    assert(type.raw == data);
  });

  test('sender_accept', () {
    int data = 1 << 3 | AckTypeType.SENDER_PACKET;
    AckType type = AckType.raw(data);
    assert(type.isAccepted);
    assert(type.type == AckTypeType.SENDER_PACKET);
    assert(type.raw == data);
  });

  test('ad_reject', () {
    int data = 0 << 3 | AckTypeType.AD_PACKET;
    AckType type = AckType.raw(data);
    assert(!type.isAccepted);
    assert(type.type == AckTypeType.AD_PACKET);
    assert(type.raw == data);
  });

  test('ad_accept', () {
    int data = 1 << 3 | AckTypeType.AD_PACKET;
    AckType type = AckType.raw(data);
    assert(type.isAccepted);
    assert(type.type == AckTypeType.AD_PACKET);
    assert(type.raw == data);
  });
}