import 'dart:convert';

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
