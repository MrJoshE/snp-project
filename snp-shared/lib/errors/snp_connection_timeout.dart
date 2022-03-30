enum SnpConnectionTimeoutType { client, server }

class SnpConnectionTimeout {
  final SnpConnectionTimeoutType type;

  SnpConnectionTimeout._({
    required this.type,
  });

  factory SnpConnectionTimeout.client() {
    return SnpConnectionTimeout._(type: SnpConnectionTimeoutType.client);
  }

  factory SnpConnectionTimeout.server() {
    return SnpConnectionTimeout._(type: SnpConnectionTimeoutType.server);
  }
}
