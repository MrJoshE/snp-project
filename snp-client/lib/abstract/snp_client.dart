import 'dart:async';
import 'dart:typed_data';

import 'package:snp_shared/snp_shared.dart';

/// Definition of the [SnpClient] that will be used for sending proxied requests to an [SnpServer]
///
/// An implementation of [SnpClient] is expected to:
///   1. Establish connection and session with an [SnpServer] (authenticated or not)
///   2. Allow client to send requests to the [SnpServer]
///

abstract class SnpClient {
  /// Implementation of [initialize] method is expected to:
  ///   1. Send request to [SnpServer] during initialization to open a socket connection
  ///   2. Start timeout timer to make sure that the response is within the specified timeout time.
  ///   3. Await ACK response
  ///   4. Handle not being able to connect to the server (timeout and not found)
  ///   5. Handle any failure responses (authentication failed)
  ///   6. Handle on disconnect from server
  ///   7. Handle receiving successful ACK response.
  ///   8. dispose of timer.
  Future<DataResponse> initialize();

  /// Implementation of [send] method is expected to:
  ///   1. Check that there is a valid connection to the [SnpServer] (internally)
  ///   2. Send request to [SnpServer] using existing socket connection
  ///   3. Start timeout timer to make sure that the request is within the specified timeout time.
  ///   4. await response for request
  ///   5. Handle any authorization failures (no more available requests)
  Future<SnpResponse> send({
    required SnpHttpRequest request,
  });

  /// Implementation of the [authenticate] method is expected to:
  ///   1. Check that the authentication token in the client options is not null
  ///   2. Send a request with the path 'authenticate' to the proxy server
  ///   3. Start the timeout timer to make sure that the request is within the specified timeout time.
  ///   4. Await the response
  ///   5. Handle the authentication failure (the API token is incorrect)
  ///   6. Handle receiving correct response.
  Future<SnpResponse> authenticate();

  /// Boolean getter that represents whether the SnpClient successfully connected to the
  /// proxy server or not.
  bool get hasInitialized;

  Stream<Uint8List>? get socketEventStream;
}
