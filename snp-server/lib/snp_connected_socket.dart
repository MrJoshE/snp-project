import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_shared/snp_shared.dart';
import 'package:uuid/uuid.dart';

import 'abstract/snp_server.dart';
import 'abstract/socket_information.dart';

const Uuid uuid = Uuid();

class SnpConnectedSocket {
  /// Logger that allows the server to output events of the connected socket for logging purposes.
  static final _logger = Logger('SnpConnectedSocket $_uuid');

  /// UUID of the socket to make sure that the ids for the sockets are unique.
  static final _uuid = uuid.v1();

  /// The socket that is used to communicate between client and server.
  final Socket socket;

  /// Possible information that is made about the client that is injected
  /// by the server is any data is available.
  final SocketInformation socketInformation;

  /// Variable to keep track of whether the socket connection has been authenticated
  /// or not.
  bool isAuthenticated = false;

  SnpConnectedSocket({
    required this.socket,
    required this.socketInformation,
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

  /// Handles the socket receiving data from the client in Uint8List form.
  /// This function will create the request creation and pass the formed request
  /// to the appropriate handler.
  ///
  /// We are also catching an error if one is thrown due to bad data being received.
  ///
  /// [data] is the data that is received from the client.
  Future<void> onRequest(Uint8List data) async {
    late SnpRequest request;

    try {
      request = SnpRequestHandler.createRequest(data);
    } catch (e) {
      _logger.severe(e);
      return _handleRequestCastingFailure(data);
    }

    /// Now we have the request object we can handle the request as needed.
    if (request.type == 'AUTH') {
      return _handleAuthRequest(request);
    } else if (request.type == "SEND") {
      return await _handleSendRequest(request);
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
      _logger.info('writing a failed AUTH response back to the client');
      return _writeResponseToSocket(
          SnpResponse(id: request.id, success: false, status: 401, payload: SnpUnauthorizedError.token()));
    }

    isAuthenticated = true;
    _logger.info('writing a successful AUTH response back to the client');
    return _writeResponseToSocket(SnpResponse(
        id: request.id,
        success: true,
        status: 200,
        payload: SnpResponsePayload(content: {'message': 'Authentication successful'})));
  }

  Future<void> _handleSendRequest(SnpRequest request) async {
    _logger.info('has made a SEND request');

    try {
      /// Check that the user has remaining allowed send requests.
      if (!isAuthenticated && !socketInformation.hasRemainingSendRequests) {
        /// Tell the client that they have no requests left.
        return _writeResponseToSocket(
            SnpResponse(id: request.id, success: false, status: 403, payload: SnpUnauthorizedError.request()));
      }

      /// Check what the request looks like
      _logger.info(request.request!);

      if (request.request == null) {
        return _writeResponseToSocket(SnpUnknownRequestError(id: request.id, failure: 'Request is null'));
      }

      /// make http request with request (we know that its not null)
      final response = await SnpServer.makeHttpRequest(request.request!);
      if (!response.isSuccessful) {
        return _writeResponseToSocket(SnpUnknownRequestError(id: request.id, failure: response.failure!));
      }

      /// Now the user has made the request we need to add to their total requests.
      socketInformation.incrementRequests();

      _logger.info('Response received from server: ${response.content}');

      final snpResponse = SnpResponse(
        id: request.id,
        success: true,
        status: 200,
        payload: SnpSuccessPayload(
          requests: socketInformation.remainingRequests,
          response: response.content!.data,
        ),
      );
      _logger.info('cast response');
      return _writeResponseToSocket(snpResponse);
    } catch (e, st) {
      _logger.severe(e, e, st);
      return _writeResponseToSocket(
          SnpUnknownError(request.id, 'An unknown error occurred while handling the request'));
    }
  }

  /// If there was an error when handling the incoming request.
  void _handleRequestCastingFailure(Uint8List data) {
    final requestJson = json.decode(utf8.decode(data));

    /// First lets make sure that the request was valid.
    final validationResponse = SnpRequestHandler.validateResponse(requestJson);

    /// If the request validation failed then ...
    if (!validationResponse.success) {
      /// We have access to the property, stage and error message.
      _writeResponseToSocket(SnpUnknownRequestError(failure: validationResponse.error!));
      return;
    }

    _logger.severe('_handleRequestCastingFailure: cannot cast error');
    _writeResponseToSocket(SnpUnknownError(requestJson['id'], 'Internal server casting error. See logs'));
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
