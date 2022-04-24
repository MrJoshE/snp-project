import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:snp_shared/snp_shared.dart';

abstract class SnpServer {
  static final httpClient = Dio();
  static List<String> validAuthTokens = [
    'josh',
  ];

  static final Logger logger = Logger('SnpServer');

  /// Method will be used to start the socket server and start listening for clients.
  Future initialize();

  /// Method will be used to handle the connection of a new socket client.
  void onConnect(Socket socket);

  /// Method will handle the socket server closing.
  void onClose();

  /// Method will any errors on the server.
  void onError();

  /// Method will handling disposing of the sever.
  void dispose();

  /// Return the response
  static Future<DataResponse<Response>> makeHttpRequest(SnpHttpRequest request) async {
    final method = request.method.toUpperCase();

    try {
      if (method == 'GET') {
        return DataResponse.success(await httpClient.get(request.path, queryParameters: request.queryParameters));
      } else if (method == 'POST') {
        return DataResponse.success(await httpClient.post(request.path, data: request.body));
      } else {
        return DataResponse.failure('Invalid method: ${request.method}');
      }
    } catch (e) {
      logger.warning('Failed to make a request to path: ${request.path}. Error: $e');
      return DataResponse.failure(e.toString());
    }
  }
}
