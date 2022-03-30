import 'package:http/http.dart';
import 'package:snp_shared/responses/responses.dart';

class SnpSuccessPayload extends SnpResponsePayload {
  /// The http response that was received by the server after making the request
  /// on the users behalf.
  final Response response;

  /// The number of requests that the user has left.
  final int requests;

  SnpSuccessPayload._({
    required this.response,
    required this.requests,
  }) : super(content: {
          "response": response,
          "requests": requests,
        });

  static Future<SnpSuccessPayload> fromJson(Map<String, dynamic> json) async {
    return SnpSuccessPayload._(
        response: await Response.fromStream(StreamedResponse(Stream.value(json['response']), 200)),
        requests: json['requests']);
  }
}
