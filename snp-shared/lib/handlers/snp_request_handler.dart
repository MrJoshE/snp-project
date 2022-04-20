import 'dart:convert';
import 'dart:typed_data';

import '../snp_shared.dart';

class SnpRequestHandler {
  static bool isLogging = false;

  static log(dynamic context) {
    if (!isLogging) return;
    print(context);
  }

  static List<String> allowedPaths = [
    'AUTH',
    'SEND',
  ];

  static SnpRequest createRequest(Uint8List rawResponse) {
    /// Convert raw bytes to string to be parsed as a json object
    final stringResponse = utf8.decode(rawResponse);
    log('String response = $stringResponse');

    /// Parse the stringResponse as a json object
    final jsonResponse = json.decode(stringResponse);
    log('JSON response = $jsonResponse');

    final validationResponse = validateResponse(jsonResponse);

    if (!validationResponse.success) {
      throw Exception(validationResponse.error);
    }

    try {
      return SnpRequest.fromJson(jsonResponse);
    } catch (e) {
      log('Unable to create request for id: ${jsonResponse['id']}. $e');
      rethrow;
    }
  }

  static SnpHandlerValidationResponse validateResponse(Map<String, dynamic> json) {
    String stage = 'Null';
    // First a null check on the status of the success and status properties.
    if (json['id'] == null) {
      return SnpHandlerValidationResponse.failure('id', stage);
    } else if (json['path'] == null) {
      return SnpHandlerValidationResponse.failure('path', stage);
    } else if (json['path'] == null) {
      return SnpHandlerValidationResponse.failure('path', stage);
    }

    // Check that the values are valid
    stage = 'Type';

    // Check that the properties are the correct type
    if (json['id'] is! String) {
      return SnpHandlerValidationResponse.failure('success', stage);
    } else if (json['path'] is! String) {
      return SnpHandlerValidationResponse.failure('status', stage);
    }

    stage = 'Allowed Path';
    if (!allowedPaths.contains(json['path'])) {
      return SnpHandlerValidationResponse.failure('path', stage);
    }

    return SnpHandlerValidationResponse.success();
  }
}