import 'package:snp_server/abstract/snp_server_config.dart';

class SocketInformation {
  int totalRequests = 0;
  final SnpServerConfig serverConfig;
  SocketInformation(this.serverConfig);

  int get remainingRequests => serverConfig.maxSendRequestsPerSocket - totalRequests;

  incrementRequests() => totalRequests++;

  bool get hasRemainingSendRequests => !(totalRequests >= serverConfig.maxSendRequestsPerSocket);
}
