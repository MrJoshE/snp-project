import 'package:snp_shared/config.dart';

class SnpClientOptions {
  final String? token;
  final String? proxyServerAddress;
  final int port;
  final int timeout;
  final bool useEncryption;

  const SnpClientOptions({
    this.proxyServerAddress,
    this.token,
    this.port = SnpDefaultConfig.defaultPort,
    this.timeout = SnpDefaultConfig.defaultTimeout,
    required this.useEncryption,
  });
}
