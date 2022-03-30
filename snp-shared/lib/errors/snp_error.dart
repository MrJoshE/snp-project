import 'package:snp_shared/responses/responses.dart';

class SnpError extends SnpResponsePayload {
  /// String 'type' of error that has occurred.
  final String error;

  /// Human readable explanation of the error that has occurred.
  final String message;

  SnpError({
    required this.error,
    required this.message,
  }) : super(content: {
          "error": error,
          "message": message,
        });

  Map<String, dynamic> toJson() {
    return {
      "error": error,
      "message": message,
    };
  }
}
