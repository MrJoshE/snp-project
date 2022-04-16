import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:snp_server/abstract/snp_server.dart';
import 'package:snp_server/abstract/snp_server_args.dart';
import 'package:snp_server/abstract/snp_server_config.dart';
import 'package:snp_shared/snp_shared.dart';

import 'abstract/socket_information.dart';
import 'snp_connected_socket.dart';

class SnpServerImpl extends SnpServer {
  ServerSocket? _serverSocket;
  late final StreamSubscription _streamSubscription;

  static final Logger _logger = SnpServer.logger;

  /// Map from IP address to ConnectedClient, keeping this for stateful sockets.
  final Map<InternetAddress, SnpConnectedSocket> _connectedSockets = {};

  final Map<InternetAddress, SocketInformation> _socketInformation = {};

  /// When requests come in we will put them in the buffer so that if we want to add a processing
  /// timeout to stop the server from being overwhelmed we can do so.
  // final List<dynamic> _requestBuffer = [];

  // final List<dynamic> _responseBuffer = [];

  final SnpServerConfig _config;

  bool _isDisposed = false;

  SnpServerImpl(this._config);

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
    _logger.info('has closed.');
  }

  @override
  void onConnect(Socket socket) {
    if (!_socketInformation.containsKey(socket.address)) {
      _socketInformation[socket.address] = SocketInformation(_config);
    }
    _connectedSockets[socket.address] =
        SnpConnectedSocket(socket: socket, socketInformation: _socketInformation[socket.address]!);

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
    _logger.info('has received an error please check the logs.');
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
