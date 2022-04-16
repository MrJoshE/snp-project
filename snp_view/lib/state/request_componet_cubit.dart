import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snp_shared/snp_shared.dart';

import '../model/api_client.dart';
import '../model/snp_service.dart';

class RequestComponentState {
  final String? content;
  final bool isLoading;
  RequestComponentState.initial()
      : content = null,
        isLoading = false;
  RequestComponentState.success(this.content) : isLoading = false;
  RequestComponentState.loading()
      : isLoading = true,
        content = null;
}

class RequestComponentCubit extends Cubit<RequestComponentState> {
  final SnpService _snpService;
  RequestComponentCubit(this._snpService) : super(RequestComponentState.initial());

  Future<void> send({required String method, required String path}) async {
    try {
      emit(RequestComponentState.loading());
      final request = SnpHttpRequest(method: method, path: path);
      final response = await _snpService.send(request);
      if (response.isSuccessful == true) {
        emit(RequestComponentState.success(response.content!.payload.content['response'] as String));
      } else {
        emit(RequestComponentState.initial());
      }
    } catch (e) {
      emit(RequestComponentState.initial());
    }
  }
}
