import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

final _encrypter = Encrypter(AES(Key.fromUtf8('snppacketencrypt')));
final _iv = IV.fromUtf8('super secret iv');

class SnpPacket {
  final String id;
  final int packetNumber;
  final int totalPackets;
  final List<int> payloadData;

  SnpPacket({
    required this.id,
    required this.packetNumber,
    required this.totalPackets,
    required this.payloadData,
  });

  List<int> packetData({required bool useEncryption}) => toBytes(useEncryption);

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

  factory SnpPacket.fromBytes(List<int> bytes, {required bool useEncryption}) {
    if (useEncryption) {
      final _encryptedBytes = Encrypted(Uint8List.fromList(bytes));

      final decryptedPackets = _encrypter.decryptBytes(_encryptedBytes, iv: _iv);
      final packet = json.decode(utf8.decode(decryptedPackets));
      return SnpPacket.fromJson(packet);
    }

    final packet = json.decode(utf8.decode(bytes));
    return SnpPacket.fromJson(packet);
  }

  List<int> toBytes([bool useEncryption = false]) {
    if (useEncryption) {
      final bytes = utf8.encode(json.encode(toJson()));
      final encryptedBytes = _encrypter.encryptBytes(bytes, iv: _iv);
      return encryptedBytes.bytes;
    }
    return utf8.encode(json.encode(toJson()));
  }

  @override
  String toString() {
    return 'SnpPacket - ${toJson()}';
  }
}
