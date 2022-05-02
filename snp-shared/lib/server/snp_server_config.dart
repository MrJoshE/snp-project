abstract class SnpServerConfig {
  const SnpServerConfig();

  /// The number of send requests an unauthenticated client can make.
  int get maxSendRequestsPerSocket;

  bool get useEncryption;
}
