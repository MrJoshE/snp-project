import '../snp_shared.dart';

class SnpTimeoutError extends SnpResponse {
  static const String _error = 'TIMEOUT';

  SnpTimeoutError(String id, String message)
      : super(id: id, success: false, status: 408, payload: SnpError(error: _error, message: message));
}
