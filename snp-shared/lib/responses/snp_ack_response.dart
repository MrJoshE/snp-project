import '../snp_shared.dart';

class SnpAckResponse extends SnpResponse {
  static const _message = "What the ACK ;-)";
  SnpAckResponse(String? id)
      : super(id: id, status: 201, success: true, payload: SnpResponsePayload(content: {"message": _message}));
}
