import 'package:snp_shared/snp_shared.dart';

class SnpInternalError extends SnpResponse {
  static const _message = 'Internal error';
  static const _error = 'INTERNAL_ERROR';
  SnpInternalError(String? id)
      : super(id: id, success: false, status: 404, payload: SnpError(error: _error, message: _message));
}
