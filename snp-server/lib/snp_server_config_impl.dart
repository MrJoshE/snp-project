import 'package:snp_shared/snp_shared.dart';

class SnpServerConfigImpl extends SnpServerConfig {
  const SnpServerConfigImpl();

  @override
  int get maxSendRequestsPerSocket => 2;

  @override
  bool get useEncryption => true;
}
