
import 'dart:io';

import 'package:snp_shared/snp_shared.dart';



class SnpRequestOptions {
  final String? baseUrl;
  final int? port;

  const SnpRequestOptions({this.baseUrl, this.port});
}

class SnpClient {
  final SnpRequestOptions? options;

  SnpClient({this.options});

  Future<DataResponse<SnpRequest>> send(
    String path, {
    required HttpRequest httpRequest,
  }) async {
    if (options?.baseUrl != null) {
      path = '${options!.baseUrl}$path';
    }

    final request = _createRequest(
      path: path,
      httpRequest: httpRequest,

    );

    try{
      final response = await _sendRequest(request);
      if (response.isSuccessful){
        return response.content;
      }else {
        print('Response was not succesful');
        throw Exception('Request was not successful: ${response.failure}');
      }
    }
    catch(e){
      print('There was an error when making your request');
      rethrow;
    }
  }

  SnpRequest _createRequest({
    required String path,
    required HttpRequest httpRequest,
  }) {
    final request = SnpRequest(
      path: path,
      request: httpRequest,
    );

    return request;
  }

  Future<DataResponse<dynamic>> _sendRequest(SnpRequest request) async {
    // 1. Create a socket connection with the sever.
    final socket = await Socket.connect(options?.baseUrl ?? request.path, options?.port ?? SnpConfig.defaultPort);


    // 2. Write to the socket with request payload.

    // TODO: Convert request to bytes.
    socket.write(request);

    return DataResponse.failure('Not implemeted yet');
  } 

  // Future<EnetResponse> _sendRequest(EnetRequest request) async {
  //   /// 1. Create a socket connection with the sever.
  //   final socket = await Socket.connect(options?.baseUrl ?? request.path, options?.port ?? EnetConfig.DEFAULT_PORT);

  //   if (request.persist) {
  //     _persitedSockets[request.socketId!] = socket;
  //   }

  //   /// 2. Make a request to the server
  //   socket.write(request.toPayload());

  //   /// 3. Wait for the response
  //   final response = EnetResponse.fromRafailure
  //   ///
  //   if (!request.persist) {
  //     await socket.close();
  //   }

  //   return response;
  // }

  // Stream List<int> listen(String socketId) {}

}