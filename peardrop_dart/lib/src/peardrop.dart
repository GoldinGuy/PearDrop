import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:multicast_lock/multicast_lock.dart';
import 'package:udp/udp.dart';

import 'ackpacket.dart';
import 'acktype.dart';
import 'adpacket.dart';
import 'senderpacket.dart';

Endpoint _multicastEndpoint =
    Endpoint.multicast(InternetAddress('224.0.0.3'), port: Port(65535));

/// The main class for sending and receiving files.
abstract class Peardrop {
  /// Receives a file using the Peardrop protocol.
  static Future<PeardropFile> receive() async {
    var selfPort = Random().nextInt(65535);
    if (selfPort <= 1024) selfPort += 1024;
    MulticastLock lock;
    if (Platform.isAndroid) {
      lock = MulticastLock();
      await lock.acquire();
    }
    var udpSocket = await UDP.bind(_multicastEndpoint);
    Datagram data;
    await for (var event in udpSocket.socket) {
      if (event == RawSocketEvent.read) {
        data = udpSocket.socket.receive();
        break;
      }
    }
    udpSocket.close();
    if (Platform.isAndroid) {
      await lock.release();
    }
    var packet = AdPacket.read(data.data);
    if (packet.tcpPort == null) {
      throw PeardropException._("AdPacket doesn't contain TCP extension");
    }
    var otherPort = packet.tcpPort;
    var tcpSocket = await Socket.connect(data.address, otherPort);
    var apacket = AckPacket(AckType.accept(AckTypeType.AD_PACKET));
    apacket.tcpPort = selfPort;
    tcpSocket.add(apacket.write());
    await tcpSocket.flush();
    await tcpSocket.close();
    var server = await ServerSocket.bind(InternetAddress.anyIPv4, selfPort);
    var queue = StreamQueue(server);
    // closed in file
    // ignore: close_sinks
    var socket = await queue.next;
    var squeue = StreamQueue(socket);
    await server.close();
    var data2 = await squeue.next;
    var spacket = SenderPacket.read(data2);
    return PeardropFile._(squeue, socket, data.address, spacket.filename,
        spacket.mimetype, spacket.data_len);
  }

  /// Sends a file using the Peardrop protocol.
  static Future<Stream<PeardropReceiver>> send(
      List<int> file, String filename, String mimetype) async {
    var selfPort = Random().nextInt(65535);
    if (selfPort <= 1024) selfPort += 1024;
    var udpSocket = await UDP.bind(Endpoint.any());
    udpSocket.send(
        (AdPacket()..tcpPort = selfPort).write(), _multicastEndpoint);
    // ignore: close_sinks
    var sc = StreamController<PeardropReceiver>();
    var tcpSocket = await ServerSocket.bind(InternetAddress.anyIPv4, selfPort);
    tcpSocket.listen((socket) async {
      var queue = StreamQueue(socket);
      var data = await queue.next;
      var packet = AckPacket.read(data);
      if (!packet.type.isAccepted) return;
      sc.add(PeardropReceiver._(
          socket.remoteAddress, packet.tcpPort, file, filename, mimetype));
    });
    return sc.stream;
  }
}

/// A file being received.
class PeardropFile {
  /// IP of the sender.
  final InternetAddress ip;
  final StreamQueue _queue;
  final Socket _socket;

  /// Filename of the file being received.
  final String filename;

  /// MIME type of the file being received.
  final String mimetype;

  /// Size of the file being received, in bytes.
  final int data_len;

  PeardropFile._(this._queue, this._socket, this.ip, this.filename,
      this.mimetype, this.data_len);

  /// Accept the file and receive it.
  Future<List<int>> accept() async {
    var packet = AckPacket(AckType.accept(AckTypeType.SENDER_PACKET));
    _socket.add(packet.write());
    await _socket.flush();
    // Receive data
    var bb = BytesBuilder();
    var remaining = data_len;
    await for (var chunk in _queue.rest) {
      if (chunk.length <= remaining) {
        bb.add(chunk);
        remaining -= chunk.length;
      } else {
        bb.add(chunk.sublist(0, chunk.length - remaining));
        remaining = 0;
      }
      if (remaining <= 0) break;
    }
    var out = bb.toBytes();
    packet = AckPacket(AckType.normal(AckTypeType.DATA_PACKET));
    _socket.add(packet.write());
    await _socket.flush();
    await _socket.close();
    return out;
  }

  /// Reject the transfer of this file.
  Future<void> reject() async {
    var packet = AckPacket(AckType.reject(AckTypeType.SENDER_PACKET));
    _socket.add(packet.write());
    await _socket.flush();
    await _socket.close();
  }
}

/// An exception while attempting to send a file to a receiver, or receive a file.
class PeardropException implements Exception {
  final String cause;
  PeardropException._(this.cause);
}

/// A receiver of a file.
class PeardropReceiver {
  /// IP of the sender.
  final InternetAddress ip;
  final int _port;
  final List<int> _file;
  final String _filename;
  final String _mimetype;

  PeardropReceiver._(
      this.ip, this._port, this._file, this._filename, this._mimetype);

  /// Send to this receiver.
  Future<void> send() async {
    var _socket = await Socket.connect(ip.address, _port);
    var _queue = StreamQueue(_socket);
    SenderPacket spacket = SenderPacket(_filename, _mimetype, _file.length);
    _socket.add(spacket.write());
    await _socket.flush();
    var data = await _queue.next;
    AckPacket packet = AckPacket.read(data);
    if (!packet.type.isAccepted) {
      throw PeardropException._("Receiver rejected send");
    }
    _socket.add(_file);
    await _socket.flush();
    data = await _queue.next;
    packet = AckPacket.read(data);
    if (packet.type.type != AckTypeType.DATA_PACKET) {
      throw PeardropException._("Malformed packet from receiver");
    }
    await _socket.close();
    // Transfer complete!
  }
}
