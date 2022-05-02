import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snp_view/model/snp_service.dart';

enum ConnectionStatus { initial, loading, failed }

class HomePageState {
  final ConnectionStatus connectionStatus;
  final bool connected;
  final bool authenticated;
  final String? failure;

  const HomePageState.initial()
      : connectionStatus = ConnectionStatus.initial,
        authenticated = false,
        connected = false,
        failure = null;
  const HomePageState.connected()
      : connectionStatus = ConnectionStatus.initial,
        authenticated = false,
        connected = true,
        failure = null;
  const HomePageState.loading()
      : connectionStatus = ConnectionStatus.loading,
        authenticated = false,
        connected = false,
        failure = null;
  HomePageState.failed({required this.connected, required this.authenticated, required this.failure})
      : connectionStatus = ConnectionStatus.failed;
  const HomePageState.authenticated()
      : connectionStatus = ConnectionStatus.initial,
        authenticated = true,
        connected = true,
        failure = null;
}

class HomePageCubit extends Cubit<HomePageState> {
  final SnpService _service;
  HomePageCubit(this._service)
      : super(!_service.hasInitialized ? const HomePageState.initial() : const HomePageState.connected());

  Future connect() async {
    emit(const HomePageState.loading());
    final response = await _service.initialize();
    emit(response.isSuccessful
        ? const HomePageState.connected()
        : HomePageState.failed(connected: false, authenticated: false, failure: response.failure!));
  }

  Future authenticate() async {
    emit(const HomePageState.loading());
    final response = await _service.authenticate();
    emit(response.isSuccessful
        ? const HomePageState.authenticated()
        : HomePageState.failed(connected: false, authenticated: false, failure: response.failure!));
  }


  void reset() {
    emit(const HomePageState.initial());
  }
}
