import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/device_session.dart';
import '../repositories/session_management_repository.dart';
import 'api_client_provider.dart';
import 'auth_provider.dart';

final sessionManagementRepositoryProvider =
    Provider<SessionManagementRepository>(
      (ref) => SessionManagementRepository(
        ref.watch(apiClientProvider),
        sessionStore: ref.watch(sessionCredentialStoreProvider),
      ),
    );

final sessionManagementControllerProvider = StateNotifierProvider.autoDispose<
  SessionManagementController,
  SessionManagementState
>((ref) {
  return SessionManagementController(
    ref.watch(sessionManagementRepositoryProvider),
  );
});

class SessionManagementState {
  const SessionManagementState({
    this.page,
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.successMessage,
  });

  final DeviceSessionPage? page;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final String? successMessage;
}

class SessionManagementController
    extends StateNotifier<SessionManagementState> {
  SessionManagementController(this._repository)
    : super(const SessionManagementState());

  final SessionManagementRepository _repository;

  Future<void> load({int page = 0}) async {
    state = SessionManagementState(page: state.page, isLoading: true);
    try {
      state = SessionManagementState(page: await _repository.list(page: page));
    } on ApiException catch (error) {
      state = SessionManagementState(
        page: state.page,
        errorMessage: _message(error),
      );
    } on Object {
      state = SessionManagementState(
        page: state.page,
        errorMessage: '連線中斷，登入狀態已保留，請重試。',
      );
    }
  }

  Future<bool> revokeCurrent() {
    return _mutate(
      _repository.revokeCurrent,
      message: '已登出目前裝置',
      reload: false,
    );
  }

  Future<bool> revokeOne(String sessionId, String password) async {
    return _withReauthentication(
      password,
      (credential) =>
          _repository.revokeOne(sessionId: sessionId, credential: credential),
      message: '已登出所選裝置',
    );
  }

  Future<bool> revokeOthers(String password) async {
    return _withReauthentication(
      password,
      (credential) => _repository.revokeOthers(credential: credential),
      message: '已登出其他裝置',
    );
  }

  Future<bool> revokeAll(String password) async {
    return _withReauthentication(
      password,
      (credential) => _repository.revokeAll(credential: credential),
      message: '已登出所有裝置',
      reload: false,
    );
  }

  Future<bool> _withReauthentication(
    String password,
    Future<void> Function(String credential) command, {
    required String message,
    bool reload = true,
  }) async {
    return _mutate(
      () async {
        final proof = await _repository.reauthenticate(password: password);
        await command(proof.credential);
      },
      message: message,
      reload: reload,
    );
  }

  Future<bool> _mutate(
    Future<void> Function() action, {
    required String message,
    required bool reload,
  }) async {
    if (state.isMutating) {
      return false;
    }
    state = SessionManagementState(page: state.page, isMutating: true);
    try {
      await action();
      if (reload) {
        final currentPage = state.page?.page ?? 0;
        final refreshed = await _repository.list(page: currentPage);
        state = SessionManagementState(
          page: refreshed,
          successMessage: message,
        );
      } else {
        state = SessionManagementState(
          page: state.page,
          successMessage: message,
        );
      }
      return true;
    } on ApiException catch (error) {
      state = SessionManagementState(
        page: state.page,
        errorMessage: _message(error),
      );
      return false;
    } on Object {
      state = SessionManagementState(
        page: state.page,
        errorMessage: '連線中斷，尚未變更登入狀態，請重試。',
      );
      return false;
    }
  }

  String _message(ApiException error) {
    return switch (error.code) {
      'SESSION_REAUTHENTICATION_FAILED' => '密碼不正確，請重新輸入',
      'SESSION_REAUTHENTICATION_REQUIRED' => '驗證已逾時，請重新輸入密碼',
      'DEVICE_SESSION_NOT_FOUND' => '這個登入裝置已不存在',
      _ => error.message,
    };
  }
}
