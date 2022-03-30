import 'package:snp_shared/errors/snp_error.dart';

class SnpUnauthorizedError extends SnpError {
  SnpUnauthorizedError._({required String error, required String message}) : super(error: error, message: message);

  factory SnpUnauthorizedError.token() => SnpUnauthorizedError._(
        error: 'UNAUTHORIZED_TOKEN',
        message: 'The token that you have used is either invalid or has expired.',
      );
  factory SnpUnauthorizedError.request() => SnpUnauthorizedError._(
        error: 'UNAUTHORIZED_REQUEST',
        message: 'You have exceeded your request limit for the day.',
      );
}
