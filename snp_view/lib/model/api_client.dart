import 'package:snp_client/abstract/snp_client.dart';
import 'package:snp_client/abstract/snp_client_options.dart';
import 'package:snp_client/snp_client_impl.dart';

import '../app_config.dart';

class ApiClient {
  final AppConfig _config;
  late final SnpClient client;

  ApiClient(this._config) {
    client = SnpClientImpl(SnpClientOptions(
      proxyServerAddress: _config.proxyServerAddress,
      token: _config.apiAuthToken,
    ));
  }
}
