// class _SnpClientImpl {
//   final Logger _logger = Logger('SnpClient');
//   final SnpClientOptions? options;
//
//   _SnpClientImpl({this.options}) {
//     _logger.info('Client is initializing');
//   }
//
//   Future<SnpResponse> send(
//     Request httpRequest, {
//     SnpRequestOptions? requestOptions,
//   }) async {
//     final request = _createRequest(
//       httpRequest: httpRequest,
//       options: requestOptions,
//     );
//
//     try {
//       final response = await _sendRequest(request);
//       return response;
//     } catch (e) {
//       print('There was an error when making your request');
//       rethrow;
//     }
//   }
//
//   SnpRequest _createRequest({
//     required Request httpRequest,
//     SnpRequestOptions? options,
//   }) {
//     final request = SnpRequest(
//       request: httpRequest,
//       timeout: options?.timeout,
//       token: options?.token,
//     );
//
//     return request;
//   }
//
//   Future<SnpResponse> _sendRequest(SnpRequest request) async {
//     final counter =
//         Timer(Duration(milliseconds: request.timeout ?? options?.timeout ?? SnpDefaultConfig.defaultTimeout), () {
//       _logger.info('timeout complete');
//     });
//
//     Socket socket;
//
//     try {
//       /// Should only ever be up to 2 long
//       /// If success - ACK , Response
//       /// If failure - Response (Error)
//       final SnpResponseBuffer buffer = SnpResponseBuffer();
//
//       // 1. Create a socket connection with the sever.
//       socket = await Socket.connect(options?.proxyServerAddress, options?.port ?? SnpDefaultConfig.defaultPort);
//
//       // Write the request to the socket.
//       socket.write(request.toJson());
//       await for (final rawResponse in socket) {
//         final response = _onResponse(rawResponse);
//         if (response.isSuccessful) {
//           _logger.info('Following response has been received: $response');
//           buffer.add(response.content!);
//
//           /// If buffer contains an error
//           final hasError = buffer.hasReceivedError();
//
//           if (hasError || buffer.size == 2) socket.close();
//         } else {
//           _logger.severe(response.failure);
//         }
//       }
//
//       if (buffer.last == null) {
//         throw Exception('Exited loop when buffer was null');
//       }
//       return buffer.last!;
//     } catch (e) {
//       _logger.info('Could not connect to the proxy server. Following error was thrown $e');
//       return SnpConnectionRefused();
//     }
//   }
//
//   DataResponse<SnpResponse> _onResponse(dynamic rawResponse) {
//     try {
//       final response = SnpResponseHandler.createResponse(rawResponse);
//
//       return DataResponse.success(response);
//     } catch (e) {
//       return DataResponse.failure('Error parsing response');
//     }
//   }
// }
