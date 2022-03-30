import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:snp_shared/requests/requests.dart';
import 'package:snp_shared/responses/responses.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class SnpConnectedSocket {
  final Socket socket;
  static final _logger = Logger('SnpConnectedSocket $_uuid');
  static final _uuid = uuid.v1();

  SnpConnectedSocket({
    required this.socket,
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

  void onRequest(List<int> data) {
    final rawRequest = utf8.decode(data);
    _logger.info('received data: $rawRequest');

    final request = SnpRequest.fromJson(json.decode(rawRequest));
    socket.write(json.encode(
        SnpResponse(id: request.id, success: true, status: 201, payload: SnpResponsePayload(content: {})).toJson()));
  }
}
