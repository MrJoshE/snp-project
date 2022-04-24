import 'package:snp_shared/responses/responses.dart';

class SnpSuccessPayload extends SnpResponsePayload {
  /// The http response that was received by the server after making the request
  /// on the users behalf.
  final Map<String, dynamic> response;

  /// The number of requests that the user has left.
  /// This will be null if the user has authenticated.
  final int? requests;

  SnpSuccessPayload({
    required this.response,
    this.requests,
  }) : super(content: {
          "response": response,
          "requests": requests,
        });

  static Future<SnpSuccessPayload> fromJson(Map<String, dynamic> json) async {
    return SnpSuccessPayload(response: json['response'], requests: json['requests']);
  }

  @override
  List<Object?> get props => [response, requests];
}
