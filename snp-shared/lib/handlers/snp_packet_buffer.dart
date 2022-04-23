import 'dart:async';
import 'dart:io';

import 'snp_packet_handler.dart';
import 'package:logging/logging.dart';

class PacketBuffer {
  static final List<SnpPacket> _packets = [];
  static final Logger _logger = Logger('PacketBuffer');

  static late Timer _timer;
  static const int _packetBufferTime = 5000;

  final Future<void> Function(List<SnpPacket>? packets, Datagram datagram) _onReceivedLastPacket;

  PacketBuffer(this._onReceivedLastPacket);

  _handlePacket(SnpPacket packet, Datagram sender) {
    /// If this is the first packet then we need to start the timer.
    if (_packets.isEmpty) {
      // start the timer
      _timer = Timer(Duration(milliseconds: _packetBufferTime), () {
        _logger.info('Timeout has been reached. Sending the response back to the client');
        _onReceivedLastPacket(null, sender);
      });
    }

    _packets.add(packet);

    /// If we have received all of the packets then we need to stop listening
    if (_packets.length == packet.totalPackets) {
      _logger.info('Last packet received. Stopping listening for more packets');
      _timer.cancel();
      _packets.sort((a, b) => a.packetNumber.compareTo(b.packetNumber));
      _onReceivedLastPacket(_packets, sender);
      _packets.clear();
    }
  }

  handlePacket(SnpPacket packet, Datagram sender) {
    try {
      return _handlePacket(packet, sender);
    } catch (e) {
      _logger.info('Error handling packet: $e');
      _onReceivedLastPacket(null, sender);
    }
  }
}
