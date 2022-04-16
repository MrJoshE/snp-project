import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_client/abstract/snp_client.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_shared/snp_shared.dart';

class SnpClientImpl extends SnpClient {
  /// Logger that will provide the client with the ability to log events to the console.
  final Logger _logger = Logger('SnpClientImpl');

  /// Options that will allow the developer to pass in configuration properties such as
  /// proxyServerAddress and timeout etc.
  final SnpClientOptions _options;

  Socket? _socket;

  @override
  Stream<Uint8List>? socketEventStream;

  @override
  bool hasInitialized = false;

  SnpClientImpl(this._options);

  @override
  Future<DataResponse> initialize() async {
    _logger.info('has started initializing');
    late SnpResponse response;
    try {
      _logger.info('trying to connect to SnpServer at the address ${_options.proxyServerAddress}:${_options.port}');

      /// Make a request to the server to create a socket connection
      response = await _sendConnectionRequest();
    } catch (e) {
      return DataResponse.failure(
          'Failed to connect to SnpServer at the address ${_options.proxyServerAddress}:${_options.port}');
    }

    /// If connection to server was successful but the response was sent back
    if (!response.success) {
      return DataResponse.failure(response.payload.content['message']);
    }

    hasInitialized = true;
    _logger
        .info('has successfully connected to SnpServer at the address ${_options.proxyServerAddress}:${_options.port}');
    return DataResponse.success(null);
  }

  Future<SnpResponse> _sendConnectionRequest() async {
    try {
      /// Make the connection request to the [SnpServer]
      _socket = await Socket.connect(_options.proxyServerAddress, _options.port);

      /// If the socket connection remains null then there was no socket connection established.
      if (_socket == null) {
        throw '404 Server not found.';
      }
      socketEventStream = _socket!.asBroadcastStream();
      final rawResponse = await socketEventStream!.elementAt(0);

      final response = SnpResponseHandler.createResponse(rawResponse);
      return response;
    } catch (e) {
      _socket = null;
      final errorMessage =
          'Could not find the SnpServer at the address ${_options.proxyServerAddress}:${_options.port}';
      _logger.severe(errorMessage);
      throw errorMessage;
    }
  }

  @override
  Future<SnpResponse> authenticate() async {
    if (_options.token == null) {
      _logger.info('Cannot authenticate with a null token');
      throw 'Cannot authenticate with a null token';
    }

    final response = await _sendToServer(path: 'AUTH', body: {"token": _options.token});
    _logger.info('received auth response $response');
    if (!response.isSuccessful) {
      _logger.info(response.failure);
      throw response.failure!;
    }
    return response.content!;
  }

  @override
  Future<SnpResponse> send({required SnpHttpRequest request}) async {
    final response = await _sendToServer(path: 'SEND', request: request);
    if (!response.isSuccessful) {
      _logger.info(response.failure);
      throw response.failure!;
    }

    return response.content!;
  }

  Future<DataResponse<SnpResponse>> _sendToServer({
    required String path,
    Map<String, dynamic>? body,
    SnpHttpRequest? request,
  }) async {
    if (!hasInitialized) {
      return DataResponse.failure('cannot send request until initialized');
    }
    if (path == "SEND" && request == null) {
      return DataResponse.failure('A SEND command must also have a non-null request');
    } else if (path == "AUTH" && body == null) {
      return DataResponse.failure('An AUTH command must also have a non-null body');
    }

    SnpRequest snpRequest;

    /// Create the request from params.
    try {
      snpRequest = SnpRequest.create(path: path, request: request, body: body);
    } catch (e) {
      return DataResponse.failure('Unable to create the request');
    }

    /// Encode the request as json and send to server.
    _socket!.write(json.encode(snpRequest.toJson()));

    /// Try in case the response handler throws an error.
    try {
      /// Wait until we receive a response with the same id as the request we sent
      /// or we receive an error
      final rawResponse = await socketEventStream!.firstWhere((element) {
        final response = SnpResponseHandler.createResponse(element);
        return response.id == snpRequest.id || response.status >= 400;
      });

      final response = SnpResponseHandler.createResponse(rawResponse);
      return DataResponse.success(response);
    } catch (e) {
      return DataResponse.failure(e.toString());
    }
  }
}
