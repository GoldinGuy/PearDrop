import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:peardrop/src/acktype.dart';
import 'package:peardrop/src/senderpacket.dart';
import 'package:udp/udp.dart';

import 'ackpacket.dart';
import 'adpacket.dart';

/// The main class for sending and receiving files.
abstract class Peardrop {
  /// Receives a file using the Peardrop protocol.
  /// Sends a file using the Peardrop protocol.
  Future<Stream<PeardropReceiver>> send(List<int> file, String filename, String mimetype) async {
    var selfPort = Random().nextInt(65535);
    var multicastEndpoint = Endpoint.multicast(InternetAddress('224.0.0.3'), port: Port(65535));
    var udpSocket = await UDP.bind(Endpoint.any());
    udpSocket.send((AdPacket()
        ..tcpPort = selfPort)
        .write(), multicastEndpoint);
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

/// An exception while attempting to send a file to a receiver.
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