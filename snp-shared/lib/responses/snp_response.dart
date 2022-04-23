import 'package:equatable/equatable.dart';

import '../snp_shared.dart';

class SnpResponse extends Equatable {
  final String? id;

  final bool success;

  final int status;

  final SnpResponsePayload payload;

  const SnpResponse({this.id, required this.success, required this.status, required this.payload});

  toJson() {
    return {
      "id": id,
      "success": success,
      "status": status,
      "payload": payload.content,
    };
  }

  factory SnpResponse.fromJson(Map<String, dynamic> json) {
    return SnpResponse(
      success: json['success'],
      status: json['status'],
      payload: SnpResponsePayload.fromJson(json['payload']),
    );
  }

  @override
  String toString() {
    return 'SnpResponse - ${toJson()}';
  }

  @override
  List<Object?> get props => [success, id, status];
}
