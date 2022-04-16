enum SnpConnectionTimeoutType { client, server }

class SnpConnectionTimeout {
  final SnpConnectionTimeoutType type;

  SnpConnectionTimeout.client() : type = SnpConnectionTimeoutType.client;

  SnpConnectionTimeout.server() : type = SnpConnectionTimeoutType.server;
}
