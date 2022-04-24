import 'dart:convert';

import '../snp_shared.dart';

class SnpPacketHandler {
  static const int maxPacketSize = 1024;

  static List<SnpPacket> convertResponseToPackets(SnpResponse response) {
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

  static List<SnpPacket> convertRequestToPackets(SnpRequest request) {
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

  static List<int> getPayloadBytesFromPacketList(List<SnpPacket> packets) {
    final List<int> bytes = [];
    for (final packet in packets) {
      bytes.addAll(packet.payloadData);
    }
    return bytes;
  }

  static SnpPacket getPacketFromBytes(List<int> bytes) {
    final packet = SnpPacket.fromBytes(bytes);
    return packet;
  }

  static SnpResponse getResponseFromPacketList(List<SnpPacket> packets) {
    final List<int> listOfBytes = [];
    for (final packet in packets) {
      listOfBytes.addAll(packet.payloadData);
    }

    return SnpResponse.fromJson(json.decode(utf8.decode(listOfBytes)));
  }

  static SnpRequest getRequestFromPacketList(List<SnpPacket> packets) {
    final List<int> listOfBytes = [];
    for (final packet in packets) {
      listOfBytes.addAll(packet.payloadData);
    }

    return SnpRequest.fromJson(json.decode(utf8.decode(listOfBytes)));
  }
}
