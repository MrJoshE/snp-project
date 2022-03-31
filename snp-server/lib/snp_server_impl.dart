import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:snp_server/abstract/snp_server.dart';
import 'package:snp_server/abstract/snp_server_args.dart';
import 'package:snp_shared/snp_shared.dart';

import 'snp_connected_socket.dart';

class SnpServerImpl extends SnpServer {
  ServerSocket? _serverSocket;
  late final StreamSubscription _streamSubscription;

  static final Logger _logger = Logger('SnpServerImpl');

  /// Map from IP address to ConnectedClient, keeping this for stateful sockets.
  final Map<InternetAddress, SnpConnectedSocket> _connectedSockets = {};

  /// When requests come in we will put them in the buffer so that if we want to add a processing
  /// timeout to stop the server from being overwhelmed we can do so.
  // final List<dynamic> _requestBuffer = [];

  // final List<dynamic> _responseBuffer = [];

  bool _isDisposed = false;

  @override
  Future initialize({SnpServerArgs? args}) async {
    _logger.info('is initializing');
    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, args?.port ?? SnpDefaultConfig.defaultPort);
      _logger.shout('Listening on ${InternetAddress.loopbackIPv4.address}:${_serverSocket!.port}');

      _streamSubscription = _serverSocket!.listen(onConnect);
      _logger.info('has finished initializing');
      return;
    } catch (e) {
      _logger.info('could not initialize. Error message: $e');
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
  }

  @override
  void onConnect(Socket socket) {
    _connectedSockets[socket.address] = SnpConnectedSocket(socket: socket);

    print(_connectedSockets);

    socket.write(json.encode(SnpResponse(
      id: 'ack',
      success: true,
      status: 200,
      payload: SnpResponsePayload(content: {'message': 'Successfully connected to server'}),
    ).toJson()));
  }

  @override
  void onError() {
    // TODO: implement onError
  }

  @override
  void dispose() {
    if (_isDisposed || _serverSocket == null) {
      return;
    }

    _serverSocket!.close();
    _streamSubscription.cancel();
    _isDisposed = true;
  }
}
