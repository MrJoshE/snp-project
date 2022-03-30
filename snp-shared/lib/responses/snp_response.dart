import '../snp_shared.dart';

class SnpResponse {
  final String id;

  final bool success;

  final int status;

  final SnpResponsePayload payload;

  const SnpResponse({required this.id, required this.success, required this.status, required this.payload});

  toJson() {
    return {
      "id": id,
      "success": success,
      "status": status,
      "payload": payload,
    };
  }
}
