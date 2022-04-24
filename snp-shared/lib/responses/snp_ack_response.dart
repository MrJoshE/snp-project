import 'package:equatable/equatable.dart';

import '../snp_shared.dart';

class SnpAckResponse extends SnpResponse with EquatableMixin {
  static const _message = "What the ACK ;-)";

  /// [id] is the id of the request.
  /// [queue] is the position the request is in the queue.
  SnpAckResponse(String id, int queue)
      : super(
          id: id,
          status: 201,
          success: true,
          payload: SnpResponsePayload(
            content: {
              "message": _message,
              "queue": queue,
            },
          ),
        );

  @override
  List<Object?> get props => [id, status, success, payload];
}
