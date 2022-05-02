import 'dart:convert';

import '../snp_shared.dart';

class SnpPacketHandler {
  static const int maxPacketSize = 1024;
  final bool useEncryption;

  const SnpPacketHandler({required this.useEncryption});

  List<SnpPacket> convertResponseToPackets(SnpResponse response) {
    final List<SnpPacket> packets = [];

    final responseBytes = utf8.encode(json.encode(response.toJson()));

    int packetCount = responseBytes.length ~/ SnpPacketHandler.maxPacketSize + 1;
    if (responseBytes.length % SnpPacketHandler.maxPacketSize == 0) {
      packetCount--;
    }

    for (int i = 0; i < packetCount; i++) {
      final start = i * SnpPacketHandler.maxPacketSize;
      int end = (i + 1) * SnpPacketHandler.maxPacketSize;
      if (end > responseBytes.length) {
        end = responseBytes.length;
      }
      final packetData = responseBytes.sublist(start, end);
      packets.add(SnpPacket(
        id: response.id,
        packetNumber: i + 1,
        totalPackets: packetCount,
        payloadData: packetData,
      ));
    }

    return packets;
  }

  List<SnpPacket> convertRequestToPackets(SnpRequest request) {
    final List<SnpPacket> packets = [];

    final requestBytes = utf8.encode(json.encode(request.toJson()));

    int packetCount = requestBytes.length ~/ SnpPacketHandler.maxPacketSize + 1;
    if (requestBytes.length % SnpPacketHandler.maxPacketSize == 0) {
      packetCount--;
    }

    for (int i = 0; i < packetCount; i++) {
      final start = i * SnpPacketHandler.maxPacketSize;
      int end = (i + 1) * SnpPacketHandler.maxPacketSize;
      if (end > requestBytes.length) {
        end = requestBytes.length;
      }
      final packetData = requestBytes.sublist(start, end);
      packets.add(SnpPacket(
        id: (request.id) + '_' + i.toString(),
        packetNumber: i + 1,
        totalPackets: packetCount,
        payloadData: packetData,
      ));
    }

    return packets;
  }

  List<int> getPayloadBytesFromPacketList(List<SnpPacket> packets) {
    final List<int> bytes = [];
    for (final packet in packets) {
      bytes.addAll(packet.payloadData);
    }
    return bytes;
  }

  SnpPacket getPacketFromBytes(List<int> bytes) {
    // Bytes are encrypted, so we need to decrypt them first
    // this happens in the snp packet from bytes function
    final packet = SnpPacket.fromBytes(bytes, useEncryption: useEncryption);
    return packet;
  }

  SnpResponse getResponseFromPacketList(List<SnpPacket> packets) {
    final List<int> listOfBytes = [];
    for (final packet in packets) {
      listOfBytes.addAll(packet.payloadData);
    }

    return SnpResponse.fromJson(json.decode(utf8.decode(listOfBytes)));
  }

  SnpRequest getRequestFromPacketList(List<SnpPacket> packets) {
    final List<int> listOfBytes = [];
    for (final packet in packets) {
      listOfBytes.addAll(packet.payloadData);
    }

    return SnpRequest.fromJson(json.decode(utf8.decode(listOfBytes)));
  }
}

/**
 * Flow
 * 
 * -------- Client --------
 * 1. Client has request and wants to send to server
 * 2. Packet handler turns the request into a list of packets
 * 3. Client sends back the utf8 encoded json string of the packet
 * 
 * -------- Server -------
 * 4. Server receives the utf8 encoded json string of the packets 
 * 5. Packet handler converts the packet payloads to request object using the utf8 encoded request 
 * in the packet payload.
 * 
 */
