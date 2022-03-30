class SnpResponsePayload {
  final Map<String, dynamic> content;

  const SnpResponsePayload({required this.content});

  toJson() => {"content": content};
}
