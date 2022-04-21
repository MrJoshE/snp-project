import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_client/abstract/snp_client.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_shared/snp_shared.dart';

/// UDP implementation of the socket client.
/// This class is used to send and receive data from the server.
class SnpClientUdpImpl extends SnpClient {
  final Logger _logger = Logger('SnpClientUdpImpl');
  final SnpClientOptions _options;
  SnpClientUdpImpl(this._options);

  bool _hasInitialized = false;
  late final RawDatagramSocket _socket;
  late final StreamSubscription<RawSocketEvent> _socketSubscription;
  final StreamController<SnpResponse> _responseController = StreamController.broadcast();
  late StreamSubscription<SnpResponse> _responseSubscription;

  /// Initializes the client.
  /// This method must be called before any other method.
  ///
  /// The [options] parameter can be used to configure the client.
  ///
  /// This function must perform the following actions:
  ///
  /// 1. Listen to a port and address specified in the [options] parameter.
  /// 2. If the [options] parameter is null, then the default options will be used.
  @override
  Future<DataResponse> initialize() async {
    _logger.info('Initializing client');
    assert(_options.proxyServerAddress != null || _options.proxyServerAddress != '',
        'Please provide a proxy server address in the client options');

    try {
      InternetAddress host = InternetAddress(_options.proxyServerAddress!);
      _socket = await RawDatagramSocket.bind(host, 5000);
      _socketSubscription = _socket.listen(_onReceivedMessage);
      _hasInitialized = true;
      return DataResponse.success('Successfully initialized');
    } catch (e) {
      _logger.severe('Could not resolve host: $e');
      return DataResponse.failure('Could not bind to proxy server. Please check logs for error');
    }
  }

  @override
  Future<SnpResponse> authenticate() {
    if (!hasInitialized) {
      throw 'Client hasn\'t been initialized yet';
    }
    throw UnimplementedError();
  }

  @override
  bool get hasInitialized => _hasInitialized;

  @override
  Future<SnpResponse> send({required SnpHttpRequest request}) async {
    if (!hasInitialized) {
      throw 'Client hasn\'t been initialized yet';
    }

    final response = await _sendToServer(type: 'SEND', request: request);
    if (!response.isSuccessful) {
      _logger.info(response.failure);
      throw response.failure!;
    }

    return response.content!;
  }

  @override
  Stream<Uint8List>? get socketEventStream => throw UnimplementedError();

  Future<DataResponse<SnpResponse>> _sendToServer({
    required String type,
    Map<String, dynamic>? body,
    SnpHttpRequest? request,
  }) async {
    if (!hasInitialized) {
      return DataResponse.failure('cannot send request until initialized');
    }
    if (type == "SEND" && request == null) {
      return DataResponse.failure('A SEND command must also have a non-null request');
    } else if (type == "AUTH" && body == null) {
      return DataResponse.failure('An AUTH command must also have a non-null body');
    }

    SnpRequest snpRequest;

    /// Create the request from params.
    try {
      snpRequest = SnpRequest.create(type: type, request: request, body: body);
    } catch (e) {
      return DataResponse.failure('Unable to create the request');
    }

    /// Encode the request as json and send to server.
    _writeToSocket(snpRequest.toJson());

    /// Try in case the response handler throws an error.
    try {
      /// Wait for the response.
      ///
      /// There should be an ACK response then the actual response
      final List<SnpResponse> responses = [];
      final completer = Completer();

      _responseSubscription = _responseController.stream.listen((event) {
        responses.add(event);

        /// If we find an error then stop listening for new responses
        if (event.status > 400 && !completer.isCompleted) {
          completer.complete();
        }

        /// If the first response was not an ACK then there is a problem so stop listening
        if (responses.length == 1 && event.status != 201 && !completer.isCompleted) {
          completer.complete();
          _logger.severe('Received a response that was not an ACK before the actual response');
        }

        /// If we have receieved 2 responses then we are done
        /// (1 ACK and 1 actual response)
        if (responses.length == 2 && !completer.isCompleted) {
          completer.complete();
        }
      });

      // Wait until the ACK and the response has been received OR an error has been received.
      await completer.future;

      /// if there was only 1 response and that was not an ACK response then tell the user that this should not be the case.
      if (responses.length == 1 && responses[0].status != 201) {
        return DataResponse.failure('Received a response that was not an ACK before the actual response');
      }

      // Now we know that all of the responses that were received are successful.
      // Return the last one.
      return DataResponse.success(responses.last);
    } catch (e) {
      return DataResponse.failure(e.toString());
    }
  }

  _onReceivedMessage(RawSocketEvent message) {
    if (message == RawSocketEvent.read) {
      final datagram = _socket.receive();

      if (datagram == null) {
        _logger.info('Received null data');
        return;
      }

      try {
        final response = SnpResponseHandler.createResponse(datagram.data);
        _logger.info('Successfully received response from server $response');
        _responseController.add(response);
      } catch (e) {
        _logger.severe('Unable to create response from data: ${String.fromCharCodes(datagram.data)}. Error: $e');
      }
    }
  }

  void _writeToSocket(Map<String, dynamic> payload) {
    /// To write to the socket we need to know that the socket has binded to the address.
    /// And that the proxyServerAddress is not null.
    if (!_hasInitialized) return;

    _logger.info('The following payload is being sent to the server: $payload');

    // Encode the payload to write to the socket to List<int> then we send it over the socket.
    _socket.send(
      Uint8List.fromList(utf8.encode(json.encode(payload))),
      InternetAddress(_options.proxyServerAddress!),
      _options.port,
    );
  }

  void dispose() {
    _socketSubscription.cancel();
    _responseSubscription.cancel();
  }
}
