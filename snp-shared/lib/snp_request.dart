import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class SnpRequest {

  /// Authorization token that will be used to identify the 
  /// sender of the request
  final String? token;

  /// Path to the proxy sever
  final String path;

  /// Request that the client wants the user to make.
  final HttpRequest request;

  /// Number of milliseconds the client will wait for the ACK from the 
  /// server.
  final int? timeout;

  const SnpRequest({
    required this.path,
    required this.request,
    this.token,
    this.timeout,
  });

  Map<String, dynamic> toJson(){
    return {
      "token": token,
      "request": request,
      "timeout": timeout,
    };
  }
  
}