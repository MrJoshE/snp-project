import '../snp_shared.dart';

class SnpConnectionRefused extends SnpResponse {
  static const String _error = 'CONNECTION_REFUSED';
  static const String _message = 'Could not connect to the server';
  SnpConnectionRefused(String id)
      : super(id: id, success: false, status: 404, payload: SnpError(error: _error, message: _message));
}
