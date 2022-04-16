import 'dart:async';

import 'package:snp_shared/snp_shared.dart';
import 'package:snp_view/abstract/snp_server_status.dart';
import 'package:snp_view/model/api_client.dart';

class OnSnpServerStatusChange {
  final SnpServerStatus status;
  OnSnpServerStatusChange(this.status);
}

class SnpService {
  final ApiClient _client;
  final StreamController<OnSnpServerStatusChange> _clientController = StreamController.broadcast();

  Stream<OnSnpServerStatusChange> get clientChangesStream => _clientController.stream;

  bool get hasInitialized => _client.client.hasInitialized;

  SnpService(this._client);

  Future<DataResponse<SnpServerStatus>> initialize() async {
    try {
      final response = await _client.client.initialize();
      if (!response.isSuccessful) {
        return DataResponse.failure(response.failure!);
      }
      return DataResponse.success(const SnpServerStatus(authenticated: false, connected: true));
    } catch (e) {
      return DataResponse.failure(e.toString());
    }
  }

  Future<DataResponse<SnpServerStatus>> authenticate() async {
    try {
      await _client.client.authenticate();
      return DataResponse.success(const SnpServerStatus(authenticated: true, connected: true));
    } catch (e) {
      return DataResponse.failure(e.toString());
    }
  }

  Future<DataResponse<SnpResponse>> send(SnpHttpRequest request) async {
    try {
      final response = await _client.client.send(request: request);
      return DataResponse.success(response);
    } catch (e) {
      return DataResponse.failure(e.toString());
    }
  }
}
