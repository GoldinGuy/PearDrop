import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:peardrop/peardrop.dart';
import 'package:peardrop/src/acktype.dart';
import 'package:peardrop/src/senderpacket.dart';
import 'package:udp/udp.dart';

import 'ackpacket.dart';
import 'adpacket.dart';

Endpoint _multicastEndpoint = Endpoint.multicast(InternetAddress('224.0.0.3'), port: Port(65535));

/// The main class for sending and receiving files.
abstract class Peardrop {
  /// Receives a file using the Peardrop protocol.
  Future<PeardropFile> receive() async {
    var selfPort = Random().nextInt(65535);
    if (selfPort <= 1024) selfPort += 1024;
    var udpSocket = await UDP.bind(_multicastEndpoint);
    var data = udpSocket.socket.receive();
    var packet = AdPacket.read(data.data);
    if (packet.tcpPort == null) {
      throw PeardropException._("AdPacket doesn't contain TCP extension");
    }
    var otherPort = packet.tcpPort;
    // ignore: close_sinks
    var tcpSocket = await Socket.connect(data.address, otherPort);
    tcpSocket.add(AckPacket(AckType.accept(AckTypeType.AD_PACKET)).write());
    var data2 = await tcpSocket.take(1).single;
    var spacket = SenderPacket.read(data2);
    return PeardropFile._(tcpSocket, spacket.filename, spacket.mimetype, spacket.data_len);
  }
  /// Sends a file using the Peardrop protocol.
  Future<Stream<PeardropReceiver>> send(List<int> file, String filename, String mimetype) async {
    var selfPort = Random().nextInt(65535);
    if (selfPort <= 1024) selfPort += 1024;
    var udpSocket = await UDP.bind(Endpoint.any());
    udpSocket.send((AdPacket()
        ..tcpPort = selfPort)
        .write(), _multicastEndpoint);
    // ignore: close_sinks
    var sc = StreamController();
    var tcpSocket = await ServerSocket.bind(InternetAddress.anyIPv4, selfPort);
    tcpSocket.listen((socket) async {
      var data = await socket.take(1).single;
      var packet = AckPacket.read(data);
      if (!packet.type.isAccepted) return;
      sc.add(PeardropReceiver._(socket, file, filename, mimetype));
    });
    return sc.stream;
  }
}

/// A file being received.
class PeardropFile {
  final Socket _socket;
  final String filename;
  final String mimetype;
  final int data_len;

  PeardropFile._(this._socket, this.filename, this.mimetype, this.data_len);

  /// Accept the file and receive it.
  Future<List<int>> accept() async {
    var packet = AckPacket(AckType.accept(AckTypeType.SENDER_PACKET));
    _socket.add(packet.write());
    // Receive data
    var bb = BytesBuilder();
    var remaining = data_len;
    await for (var chunk in _socket) {
      if (chunk.length <= remaining) {
        bb.add(chunk);
        remaining -= chunk.length;
      } else {
        bb.add(chunk.sublist(0, chunk.length-remaining));
        remaining = 0;
      }
      if (remaining == 0) break;
    }
    var out = bb.toBytes();
    packet = AckPacket(AckType.normal(AckTypeType.DATA_PACKET));
    _socket.add(packet.write());
    return out;
  }
  /// Reject the transfer of this file.
  void reject() async {
    var packet = AckPacket(AckType.reject(AckTypeType.SENDER_PACKET));
    _socket.add(packet.write());
  }
}

/// An exception while attempting to send a file to a receiver, or receive a file.
class PeardropException implements Exception {
  final String cause;
  PeardropException._(this.cause);
}

/// A receiver of a file.
class PeardropReceiver {
  final Socket _socket;
  final List<int> _file;
  final String _filename;
  final String _mimetype;

  PeardropReceiver._(this._socket, this._file, this._filename, this._mimetype);

  /// Send to this receiver.
  Future<void> send() async {
    SenderPacket spacket = SenderPacket(_filename, _mimetype, _file.length);
    _socket.add(spacket.write());
    var data = await _socket.take(1).single;
    AckPacket packet = AckPacket.read(data);
    if (!packet.type.isAccepted) {
      throw PeardropException._("Receiver rejected send");
    }
    _socket.add(_file);
    data = await _socket.take(1).single;
    packet = AckPacket.read(data);
    if (packet.type.type != AckTypeType.DATA_PACKET) {
      throw PeardropException._("Malformed packet from receiver");
    }
    // Transfer complete!
  }
}