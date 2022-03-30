import '../snp_shared.dart';

class SnpUnknownError extends SnpResponse {
  static const String _error = 'UNKNOWN_ERROR';

  SnpUnknownError(String id, String failure)
      : super(
          id: id,
          success: false,
          status: 400,
          payload: SnpError(error: _error, message: failure),
        );
}
