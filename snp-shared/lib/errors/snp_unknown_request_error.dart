import '../snp_shared.dart';

class SnpUnknownRequestError extends SnpResponse {
  static const String _error = 'UNKNOWN_REQUEST';
  SnpUnknownRequestError(String failure)
      : super(success: false, status: 404, payload: SnpError(error: _error, message: failure));
}
