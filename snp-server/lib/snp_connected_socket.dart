import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_shared/snp_shared.dart';
import 'package:uuid/uuid.dart';

import 'abstract/snp_server.dart';

const Uuid uuid = Uuid();

class SnpConnectedSocket {
  static final _logger = Logger('SnpConnectedSocket $_uuid');
  static final _uuid = uuid.v1();
  final Socket socket;
  bool isAuthenticated = false;

  SnpConnectedSocket({
    required this.socket,
  }) {
    _logger.info('Client connected ');
    // Listen for incoming data.
    socket.listen(
      onRequest,
      onDone: () {
        socket.close();
      },
      onError: (error) {
        _logger.severe('Client error $error');
      },
    );
  }

  void onRequest(Uint8List data) {
    late SnpRequest request;
    try {
      request = SnpRequestHandler.createRequest(data);
    } catch (e) {
      _logger.severe(e);
      return _handleRequestCastingFailure(data);
    }

    /// Now we have the request object we can handle the request as needed.
    if (request.path == 'AUTH') {
      return _handleAuthRequest(request);
    } else if (request.path == "SEND") {
      return _handleSendRequest(request);
    }
  }

  void _handleAuthRequest(SnpRequest request) {
    _logger.info('has made an AUTH request');

    /// Get the token from the request body.
    final token = request.body!['token'];

    /// Check that the auth token is valid
    final authorized = _authCheck(token);

    if (!authorized) {
      isAuthenticated = false;
      return _writeResponseToSocket(
          SnpResponse(id: request.id, success: false, status: 401, payload: SnpUnauthorizedError.token()));
    }

    isAuthenticated = true;
    return _writeResponseToSocket(SnpResponse(
        success: true, status: 201, payload: SnpResponsePayload(content: {'message': 'Authentication successful'})));
  }

  void _handleSendRequest(SnpRequest request) {
    _logger.info('has made a SEND request');
    return _writeResponseToSocket(SnpUnknownError(request.id, 'Not implemented yet'));
  }

  /// If there was an error when handling the incoming request.
  void _handleRequestCastingFailure(Uint8List data) {
    /// First lets make sure that the request was valid.
    final validationResponse = SnpRequestHandler.validateResponse(json.decode(utf8.decode(data)));

    /// If the request validation failed then ...
    if (!validationResponse.success) {
      /// We have access to the property, stage and error message.
      _writeResponseToSocket(SnpUnknownRequestError(validationResponse.error!));
      return;
    }
    final requestJson = json.decode(utf8.decode(data));
    _writeResponseToSocket(SnpUnknownError(requestJson['id'], ''));
    return;
  }

  bool _authCheck(String? token) {
    _logger.info('performing auth check on token $token');
    final success = token == null || SnpServer.validAuthTokens.contains(token);
    _logger.info(success ? 'token $token was valid - auth confirmed' : 'token: $token was an invalid auth token');
    return success;
  }

  void _writeResponseToSocket(SnpResponse response) => socket.write(json.encode(response));
}
