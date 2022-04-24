import '../snp_shared.dart';

class SnpBadRequestError extends SnpResponse {
  static const String _error = 'CONNECTION_REFUSED';
  static const String _message = 'Could not connect to the server';
  SnpBadRequestError(String? id)
      : super(
          id: id ?? 'SNP_REQUEST_NO_ID',
          success: false,
          status: 400,
          payload: SnpError(error: _error, message: _message),
        );
}
