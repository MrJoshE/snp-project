import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:snp_server/abstract/snp_server_config.dart';
import 'package:snp_shared/snp_shared.dart';

import 'abstract/snp_server.dart';
import 'abstract/snp_server_args.dart';

class SnpServerUdpImpl {
  static final Logger _logger = SnpServer.logger;
  late RawDatagramSocket _serverSocket;
  late StreamSubscription _streamSubscription;

  final SnpServerConfig config;
  SnpServerUdpImpl(this.config);

  Future initialize({SnpServerArgs? args}) async {
    _logger.info('is initializing');
    try {
      _serverSocket =
          await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, args?.port ?? SnpDefaultConfig.defaultPort);
      _logger.shout('Listening on ${InternetAddress.loopbackIPv4.address}:${_serverSocket.port}');

      _streamSubscription = _serverSocket.listen(onMessage);
      _logger.info('has finished initializing successfully. Now listening for incoming messages');

      return;
    } catch (e) {
      _logger.info('could not initialize. Error message: $e');
    }
  }

  void onMessage(RawSocketEvent socket) {
    if (socket == RawSocketEvent.read) {
      Datagram? datagram = _serverSocket.receive();
      if (datagram == null) return;
      final String message = String.fromCharCodes(datagram.data);
      _logger.info('Server has received the following raw data. Converting to a response object now...');

      /// Lets cast this string message to a JSON object then to a request object
      /// If we are successful then we need to send back and ACK for the client
      try {
        /// Get the request object back from the JSON
        final request = SnpRequestHandler.createRequest(datagram.data);

        /// Make an ACK resposne
        final ackResponse = SnpAckResponse(request.id);

        /// Send the JSON ack back to the client
        _sendToClient(payload: ackResponse.toJson(), datagram: datagram);

        /// Log on the server that the request has been recieved and an ACK has been sent back.
        _logger.info('Received request $request and responded with ACK');

        try {
          handleRequest(request, datagram);
        } catch (e) {
          _logger.info('Could not handle request. Error message: $e');
          final internalError = SnpInternalError(request.id);
          _sendToClient(payload: internalError.toJson(), datagram: datagram);
        }
      } catch (e) {
        /// There has been an error so log it
        _logger.severe('Could not convert the following data to a request object: $message. Error: $e');

        /// We want to make a bad request response but we dont know whether we can use the id of the request
        /// to we will try and use it but wont if we can't.
        SnpBadRequestError badRequestErrorResponse;
        try {
          /// Decode the message to a JSON object
          final jsonMessage = json.decode(message);

          /// Use the ID property of the JSON object to create a bad request response
          badRequestErrorResponse = SnpBadRequestError(jsonMessage['id']);
        } catch (e) {
          /// We could not decode the message to a JSON object so we will just create a bad request response
          badRequestErrorResponse = SnpBadRequestError(null);
        }

        /// Send the bad request response back to the client
        _sendToClient(payload: badRequestErrorResponse.toJson(), datagram: datagram);
      }
    }
  }

  void _sendToClient({
    required Map<String, dynamic> payload,
    required Datagram datagram,
  }) {
    _serverSocket.send(utf8.encode(json.encode(payload)), datagram.address, datagram.port);
  }

  void onClose() {}
  void onError() {}
  void dispose() {
    _streamSubscription.cancel();
  }

  handleRequest(SnpRequest request, Datagram datagram) {
    _logger.info('Handling request $request');

    if (request.type == "SEND") {
    } else if (request.type == "AUTH") {
    } else {
      // Return to the client with bad request response as there the path has not been specified.
      final badRequestResponse = SnpBadRequestError(request.id);
      _sendToClient(payload: badRequestResponse.toJson(), datagram: datagram);
      return;
    }

    final error = SnpResponse(
      id: request.id,
      status: 405,
      success: false,
      payload: SnpError(message: 'Not implemented', error: 'NOT_IMPLEMENTED'),
    );
    _sendToClient(payload: error.toJson(), datagram: datagram);
  }
}
