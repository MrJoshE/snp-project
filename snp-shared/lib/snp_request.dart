import 'dart:io';

class SnpRequest {

  /// Authorization token that will be used to identify the 
  /// sender of the request
  final String? token;

  /// Path to the proxy sever
  final String path;

  /// Request that the client wants the user to make.
  final HttpRequest request;

  const SnpRequest({
    required this.path,
    required this.request,
    this.token,
  });
  
}