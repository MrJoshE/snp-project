import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_server/abstract/snp_server_config.dart';
import 'package:snp_shared/handlers/snp_packet_handler.dart';
import 'package:snp_shared/snp_shared.dart';

import 'abstract/snp_server.dart';
import 'abstract/snp_server_args.dart';

class SnpRequestQueueItem {
  final SnpRequest request;
  final Datagram owner;
  // final Completer<SnpResponse> completer;

  SnpRequestQueueItem(this.request, this.owner);
}

class DatagramInformation {
  /// Whether the datagram at the Internet address has been authenticated.
  bool authenticated = false;
  int requestsMade = 0;

  @override
  String toString() {
    return 'DatagramInformation{authenticated: $authenticated, requestsMade: $requestsMade}';
  }
}

class SnpServerUdpImpl {
  static final Logger _logger = Logger('SnpServerUdpImpl');
  late RawDatagramSocket _serverSocket;
  late StreamSubscription _streamSubscription;

  final SnpServerConfig config;
  final Map<InternetAddress, DatagramInformation> _clients = {};
  late final PacketBuffer _packetBuffer = PacketBuffer(
    (packets, datagram) => onLastPacketReceivedCallback(packets, datagram),
  );

  /// Valid auth tokens that a client has to use to authenticate.
  final List<String> _authTokens = [
    'josh',
    'toni',
    'og',
    'david',
  ];

  final List<SnpRequestQueueItem> _requestQueue = [];

  /// This is publically visible for testing purposes.
  bool hasInitialized = false;

  /// This is publically visible for testing purposes.
  bool isDisposed = false;

  SnpServerUdpImpl(this.config);

  Future initialize({SnpServerArgs? args}) async {
    _logger.info('is initializing');
    try {
      _serverSocket =
          await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, args?.port ?? SnpDefaultConfig.defaultPort);
      _logger.shout('Listening on ${InternetAddress.loopbackIPv4.address}:${_serverSocket.port}');

      hasInitialized = true;
      _streamSubscription = _serverSocket.listen(handleIncomingPacket);
      _logger.info('has finished initializing successfully. Now listening for incoming messages');

      return;
    } catch (e) {
      _logger.info('could not initialize. Error message: $e');
    }
  }

  Future<void> handleIncomingPacket(RawSocketEvent event) async {
    if (event != RawSocketEvent.read) return;

    Datagram? datagram = _serverSocket.receive();
    if (datagram == null) return;
    _logger.info('Server has received the following raw data. Converting to a packet now...');

    try {
      final packetBytes = datagram.data;
      final packet = SnpPacketHandler.getPacketFromBytes(packetBytes);
      _logger.info('Server has received the following packet: $packet');
      _packetBuffer.handlePacket(packet, datagram);
    } catch (e) {
      /// Could not convert the datagram to a list of packets
      ///
      _logger.severe(e);
    }
  }

  Future<void> onLastPacketReceivedCallback(List<SnpPacket>? packets, Datagram datagram) async {
    if (packets == null) {
      _logger.severe('Receiving packets timed out.');
      final timeoutErrorResponse = SnpTimeoutError('Receiving packets timed out.');
      _sendToClient(response: timeoutErrorResponse, datagram: datagram);
      return;
    }

    /// Get the request payload bytes from the finalized list of packets.
    final requestBytes = SnpPacketHandler.getPayloadBytesFromPacketList(packets);

    /// Send the full list of request bytes the next function.
    await handleFormedRequestBytes(requestBytes, datagram);
  }

  Future<void> handleFormedRequestBytes(List<int> bytes, Datagram datagram) async {
    final message = utf8.decode(bytes);

    /// Lets cast this string message to a JSON object then to a request object
    /// If we are successful then we need to send back and ACK for the client
    try {
      /// Get the request object back from the JSON

      final request = SnpRequestHandler.createRequest(Uint8List.fromList(bytes));
      _requestQueue.add(SnpRequestQueueItem(request, datagram));
      final position = _requestQueue.length;

      /// Make an ACK resposne
      final ackResponse = SnpAckResponse(request.id, position);

      /// Send the JSON ack back to the client
      _sendToClient(response: ackResponse, datagram: datagram);

      /// Log on the server that the request has been recieved and an ACK has been sent back.
      _logger.info('Received request $request and responded with ACK');

      try {
        await handleRequest(request, datagram);
      } catch (e) {
        _logger.info('Could not handle request. Error message: $e');
        final internalError = SnpInternalError(request.id);
        _sendToClient(response: internalError, datagram: datagram);
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
      _sendToClient(response: badRequestErrorResponse, datagram: datagram);
    }
  }

  void _sendToClient({
    required SnpResponse response,
    required Datagram datagram,
  }) {
    /// Conver the response into packets and send back to client
    final packets = SnpPacketHandler.convertResponseToPackets(response);
    _logger.info('Sending the following packets to the client: $packets');
    for (final packet in packets) {
      _serverSocket.send(packet.packetData, datagram.address, datagram.port);
    }
  }

  void dispose() {
    if (isDisposed) {
      _logger.severe('Cannot dispose server that is already disposesd.');
      return;
    }

    /// Stop listening to new requests and close the server socket
    _streamSubscription.cancel();
    _serverSocket.close();
  }

  /// Method to check if the internet address of the datagram (client) exists
  /// in the clients map. If it does not exist then we will add it to the map
  /// and set the authenticated property to false, and return true.
  ///
  /// If the client exists then we will need to check if they are authenticated or not
  /// and whether they have enough requests that they are allowed to make is greater than 0.
  /// If they are authenticated then they will be able to make as many requests as they want.
  _canMakeRequest(Datagram datagram) {
    _logger.info('Checking if client ${datagram.address} can make a request. $_clients');
    if (_clients.containsKey(datagram.address)) {
      final datagramInformation = _clients[datagram.address];

      if (datagramInformation!.authenticated || datagramInformation.requestsMade < config.maxSendRequestsPerSocket) {
        return true;
      }
      return false;
    } else {
      _clients[datagram.address] = DatagramInformation();
      return true;
    }
  }

  Future<void> handleRequest(SnpRequest request, Datagram datagram) async {
    _logger.info('Handling request $request');

    if (request.type == "SEND") {
      /// Lets check that there is a request to be sent on the request object.
      if (request.request == null) {
        _logger.info('Request does not contain a request object. Sending a bad request response');
        final badRequestErrorResponse = SnpBadRequestError(request.id);
        _sendToClient(response: badRequestErrorResponse, datagram: datagram);
        return;
      }

      /// Perform check that the client should be able to make the request or not
      final canMakeRequest = _canMakeRequest(datagram);

      /// If we the client cannot make the request then they will be sent an unauthorized response.
      if (!canMakeRequest) {
        _logger.info('Client is not authenticated or has reached the maximum number of requests they can make');
        final unauthorizedResponse = SnpResponse(success: false, status: 403, payload: SnpUnauthorizedError.request());
        _sendToClient(response: unauthorizedResponse, datagram: datagram);
        return;
      }

      /// Now we know that there is a request that can be sent and the client has the permissions to make it, lets try and make the request.
      final response = await SnpServer.makeHttpRequest(request.request!);

      /// Remove the request from the queue as its now been executed
      /// this is regardless of whether it was a success or not as its still been executed
      _requestQueue.removeWhere((element) => element.request.id == request.id);

      /// If there was a problem making the request then we need to tell the client that there
      /// was an internal error whilst making the request.
      if (!response.isSuccessful) {
        _logger.info('There was an error making the request. Sending an internal error response');
        final internalErrorResponse = SnpInternalError(request.id);
        _sendToClient(response: internalErrorResponse, datagram: datagram);
        return;
      }

      /// Incremeent the requests made by the client
      final client = _clients[datagram.address]!;
      client.requestsMade++;

      // Calculate the number of requests that the client has left to make.

      final requestsLeft = client.authenticated ? null : config.maxSendRequestsPerSocket - client.requestsMade;

      /// If the request was successful then we need to send the response back to the client.
      _logger.info('The request was made successfully. Sending the response back to the client');
      final clientResponse = SnpResponse(
          success: true,
          status: 200,
          payload: SnpSuccessPayload(response: response.content!.data, requests: requestsLeft));
      _sendToClient(response: clientResponse, datagram: datagram);

      _logger.info(
          'Response was sent back to the client. Speaking of ... here is a list of clients that have made requests\n$_clients');
    } else if (request.type == "AUTH") {
      /// Lets check that there is a request to be sent on the request object.
      if (request.body == null || request.body!['token'] == null) {
        _logger.info('Request does not contain a request body with the token property. Sending a bad request response');
        final badRequestErrorResponse = SnpBadRequestError(request.id);
        _sendToClient(response: badRequestErrorResponse, datagram: datagram);
        return;
      }

      /// Now we know there is an int token property now we can use that to authenticate the client.
      final token = request.body!['token'] as String;
      if (!_authTokens.contains(token)) {
        _logger.info(
            'Client ${datagram.address} has used an invalid token to authenticate. Sending an unauthorized response');
        final unauthorizedResponse = SnpResponse(success: false, status: 401, payload: SnpUnauthorizedError.token());
        _sendToClient(response: unauthorizedResponse, datagram: datagram);
        return;
      }

      /// If the client hasn't been stored in the clients map then we will add them to the map.
      if (!_clients.containsKey(datagram.address)) {
        _clients[datagram.address] = DatagramInformation();
      }

      /// Set authenticated to true.
      _clients[datagram.address]!.authenticated = true;

      /// Remove the request from the queue as its now been executed
      _requestQueue.removeWhere((element) => element.request.id == request.id);

      /// Send the success response back to the client.
      final successResponse = SnpResponse(
          success: true, status: 200, payload: SnpResponsePayload(content: {"message": "You have been authenticated"}));
      _sendToClient(response: successResponse, datagram: datagram);
    } else {
      // Return to the client with bad request response as there the path has not been specified.
      final badRequestResponse = SnpBadRequestError(request.id);
      _sendToClient(response: badRequestResponse, datagram: datagram);
      return;
    }
  }
}
