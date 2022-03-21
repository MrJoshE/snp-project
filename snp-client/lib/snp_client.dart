
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:snp_client/snp_client_options.dart';
import 'package:snp_shared/snp_request_options.dart';
import 'package:snp_shared/snp_response.dart';
import 'package:snp_shared/snp_shared.dart';

class SnpClient {
  final Logger _logger = Logger('SnpClient');
  final SnpClientOptions? options;

  SnpClient({this.options}){
    _logger.info('Client is initializing');
  }

  Future<DataResponse<SnpResponse>> send(
    String path, 
    HttpRequest httpRequest,    
    {SnpRequestOptions? requestOptions}) async {
    if (options?.baseUrl != null) {
      path = '${options!.baseUrl}$path';
    }

    final request = _createRequest(
      path: path,
      httpRequest: httpRequest,
      options: requestOptions,
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
    SnpRequestOptions? options,
  }) {
    final request = SnpRequest(
      path: path,
      request: httpRequest,
      timeout: options?.timeout,
      token: options?.token,
    );

    return request;
  }

  Future<DataResponse<dynamic>> _sendRequest(SnpRequest request) async {
    // 1. Create a socket connection with the sever.
    final socket = await Socket.connect(options?.baseUrl ?? request.path, options?.port ?? SnpConfig.defaultPort);


    // 2. Write to the socket with request payload.
    socket.write(request.toJson());

   
   
    socket.listen(
      
      /// When socket data is received.
      /// rawResponse - List of integers.   
      (Uint8List rawResponse) {
      final response = _onResponse(rawResponse);

      // if the casting to a response object was a success
      if (response.isSuccessful){
        return response;
      }
      

     }, 
     onDone: () {
       _logger.info('Closing socket');
       socket.close();
     }, 
     onError: (e, st){
       _logger.severe('Error occured $e, $st');
       socket.close();
     }, 
     cancelOnError: true);

    
  } 

  DataResponse<SnpResponse> _onResponse(dynamic rawResponse){
    try{
      final response = SnpResponse.fromJson(rawResponse);

      return DataResponse.success(response);
    }
    catch(e){
      return DataResponse.failure('Error parsing response');
    }

  }

  // Future<EnetResponse> _sendRequest(EnetRequest request) async {
  //   /// 1. Create a socket connection with the sever.
  //   final socket = await Socket.connect(options?.baseUrl ?? request.path, options?.port ?? EnetConfig.DEFAULT_PORT);

  //   if (request.persist) {
  //     _persitedSockets[reqdatauest.socketId!] = socket;
  //   }

  //   /// 2. Make a request to the server
  //   socket.write(request.toPayload());

  //   /// 3. Wait for the response
  //   final response = EnetResponse.fromRafailure
  //   ///equest.persist) {
  //     _persitedSockets[reqdatauest.socketId!] = socket;
  //   }

  //   /// 2. Make a request to the server
  //   socket.write(request.toPayload());

  //   /// 3. Wait for the response
  //   final response = EnetResponse.fromRafailure
  //   ///
  //   if (!request.persist) {
  // Stream List<int> listen(String socketId) {}

}