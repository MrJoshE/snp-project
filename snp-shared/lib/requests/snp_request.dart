import 'package:snp_shared/requests/snp_http_request.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class SnpRequest {
  /// Id for the request so that the client can identify when they get the response.
  final String id;

  /// Send or authenticate (depending on what the operation is)
  final String type;

  /// A body for the request
  ///
  /// For example: when the authenticate command is given the server will check the 'authToken' key for the authentication token.
  /// When the send command is given the server will check the body for the http request that the client wants to send.
  final Map<String, dynamic>? body;

  /// Request that the client wants the user to make.
  final SnpHttpRequest? request;

  /// Number of milliseconds the client will wait for the ACK from the
  /// server.
  final int? timeout;

  const SnpRequest({
    required this.id,
    required this.type,
    this.request,
    this.body = const {},
    this.timeout,
  });

  factory SnpRequest.create({
    required String type,
    SnpHttpRequest? request,
    Map<String, dynamic>? body,
    int? timeout,
  }) =>
      SnpRequest(
        id: uuid.v1(),
        type: type,
        request: request,
        body: body,
        timeout: timeout,
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "body": body ?? request?.toJson(),
      "timeout": timeout,
    };
  }

  factory SnpRequest.fromJson(Map<String, dynamic> json) {
    return SnpRequest(
      id: json['id'],
      type: json['type'],
      body: json['body'],
      request: json['type'] == 'SEND' ? SnpHttpRequest.fromJson(json['body']) : null,
      timeout: json['timeout'],
    );
  }

  @override
  String toString() {
    return 'SnpRequest{id: $id, type: $type, body: $body, request: $request, timeout: $timeout}';
  }
}
