import 'dart:convert';
import 'dart:typed_data';

import 'package:snp_shared/errors/snp_error.dart';
import 'package:snp_shared/responses/responses.dart';

class SnpResponseHandler {
  static bool isLogging = true;

  static log(dynamic context) {
    if (!isLogging) return;
    print(context);
  }

  static const List<int> _allowedStatusCodes = [
    200,
    201,
    401,
    403,
    405,
    406,
  ];

  static SnpResponse createResponse(Uint8List rawResponse) {
    /// Convert raw bytes to string to be parsed as a json object
    final stringResponse = utf8.decode(rawResponse);
    log('String response = $stringResponse');

    /// Parse the stringResponse as a json object
    final jsonResponse = json.decode(stringResponse);
    log('JSON response = $jsonResponse');

    // Validate the response
    final validation = _validateResponse(jsonResponse);

    /// If the validation fails then we want to return where the validation failed.
    if (!validation.success) {
      throw Exception(validation.error);
    }

    /// Now we know the validation is successful we can use the following properties
    /// success: bool
    /// status: int - [200, 201, 401, 403, 405, 406]
    /// payload: dynamic

    try {
      if (!jsonResponse['success']) {
        return SnpResponse(
            id: jsonResponse['id'],
            success: false,
            status: jsonResponse['status'],
            payload: SnpError(
              error: jsonResponse['payload']['error'],
              message: jsonResponse['payload']['message'],
            ));
      }
      return SnpResponse(
          id: jsonResponse['id'],
          success: true,
          status: jsonResponse['status'],
          payload: SnpResponsePayload(
            content: jsonResponse['payload'],
          ));
    } catch (e) {
      log('Unable to create response for status code: ${jsonResponse['status']}. $e');
      rethrow;
    }
  }

  static SnpResponseValidationResponse _validateResponse(Map<String, dynamic> json) {
    String stage = 'Null';
    // First a null check on the status of the success and status properties.
    if (json['success'] == null) {
      return SnpResponseValidationResponse.failure('success', stage);
    } else if (json['status'] == null) {
      return SnpResponseValidationResponse.failure('status', stage);
    } else if (json['payload'] == null) {
      return SnpResponseValidationResponse.failure('payload', stage);
    }

    // Check that the values are valid
    stage = 'Type';

    // Check that the properties are the correct type
    if (json['success'] is! bool) {
      return SnpResponseValidationResponse.failure('success', stage);
    } else if (json['status'] is! int) {
      return SnpResponseValidationResponse.failure('status', stage);
    }

    // Check that the status in the in the allowed values
    stage = 'Status code';
    if (!_allowedStatusCodes.contains(json['status'])) {
      return SnpResponseValidationResponse.failure('status', stage);
    }

    return SnpResponseValidationResponse.success();
  }
}
