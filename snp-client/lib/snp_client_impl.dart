import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_client/abstract/snp_client.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_shared/requests/snp_http_request.dart';
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
  Future initialize() async {
    _logger.info('has started initializing');
    try {
      /// Make a request to the server to create a socket connection
      final response = await _sendConnectionRequest();

      /// If connection to server was successful but the response was sent back
      if (!response.success) {
        throw response.payload.content['message'];
      }
      hasInitialized = true;
      _logger.info('has successfully connected to proxy server ${_options.proxyServerAddress}:${_options.port}');
    } catch (e) {
      _logger.info('failed to initialize');
      rethrow;
    }
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
    } catch (e, st) {
      _socket = null;
      _logger.severe(e);
      _logger.severe(st);
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
    try {
      final snpRequest = SnpRequest.create(path: path, request: request, body: body);
      _socket!.write(json.encode(snpRequest.toJson()));
      final rawResponse = await socketEventStream!.firstWhere((element) {
        final response = SnpResponseHandler.createResponse(element);
        return response.id == snpRequest.id;
      });
      return DataResponse.success(SnpResponseHandler.createResponse(rawResponse));
    } catch (e, st) {
      _logger.severe(e);
      _logger.severe(st);
      return DataResponse.failure('Unable to send request to the server. Error $e');
    }
  }
}
