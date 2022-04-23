import 'abstract/snp_server_config.dart';

class SnpServerConfigImpl extends SnpServerConfig {
  const SnpServerConfigImpl();

  @override
  int get maxSendRequestsPerSocket => 2;
}
