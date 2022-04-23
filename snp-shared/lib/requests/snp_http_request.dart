class SnpHttpRequest {
  final String method;
  final String path;
  final Map<String, dynamic> body;
  final Map<String, dynamic> headers;

  SnpHttpRequest({
    required this.method,
    required this.path,
    this.headers = const {},
    this.body = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      "method": method,
      "path": path,
      "headers": headers,
      "body": body,
    };
  }

  factory SnpHttpRequest.fromJson(Map<String, dynamic> json) => SnpHttpRequest(
        method: json['method'],
        path: json['path'],
        headers: json['headers'],
        body: json['body'],
      );
      

  @override
  String toString() {
    return 'SnpHttpRequest{method: $method, path: $path, body: $body, headers: $headers}';
  }
}
