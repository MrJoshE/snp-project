import 'dart:convert';
import 'package:logging/logging.dart';
import '../snp_shared.dart';

class SnpPacket {
  final String id;
  final int packetNumber;
  final int totalPackets;
  final List<int> payloadData;

  SnpPacket({required this.id, required this.packetNumber, required this.totalPackets, required this.payloadData});

  List<int> get packetData {
    return utf8.encode(json.encode(toJson()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packetNumber': packetNumber,
      'totalPackets': totalPackets,
      'payloadData': payloadData,
      'isLast': packetNumber == totalPackets,
    };
  }

  factory SnpPacket.fromJson(Map<String, dynamic> json) {
    return SnpPacket(
      id: json['id'],
      packetNumber: json['packetNumber'],
      payloadData: json['payloadData'].cast<int>(),
      totalPackets: json['totalPackets'],
    );
  }

  factory SnpPacket.fromBytes(List<int> bytes) {
    final packet = json.decode(utf8.decode(bytes));
    return SnpPacket.fromJson(packet);
  }

  @override
  String toString() {
    return 'SnpPacket - ${toJson()}';
  }
}

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
        id: (response.id ?? 'snp_packet') + '_' + i.toString(),
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
