import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../repositories/auth_repository.dart';
import 'auth_provider.dart';

final passwordResetControllerProvider =
    StateNotifierProvider<PasswordResetController, PasswordResetState>((ref) {
      return PasswordResetController(ref.watch(authRepositoryProvider));
    });

enum PasswordResetStage {
  request,
  accepted,
  completion,
  completed,
  invalid,
  expired,
  used,
}

class PasswordResetState {
  const PasswordResetState({
    this.stage = PasswordResetStage.request,
    this.isLoading = false,
    this.errorMessage,
    this.retryAfter,
  });

  final PasswordResetStage stage;
  final bool isLoading;
  final String? errorMessage;
  final int? retryAfter;
}

class PasswordResetController extends StateNotifier<PasswordResetState> {
  PasswordResetController(this._repository) : super(const PasswordResetState());

  final AuthRepository _repository;
  int _operation = 0;

  void beginRequest() {
    _operation++;
    state = const PasswordResetState();
  }

  void beginCompletion() {
    _operation++;
    state = const PasswordResetState(stage: PasswordResetStage.completion);
  }

  Future<bool> request({required String email}) async {
    final operation = ++_operation;
    state = const PasswordResetState(
      stage: PasswordResetStage.request,
      isLoading: true,
    );
    try {
      await _repository.requestPasswordReset(email: email.trim());
      if (!mounted || operation != _operation) return false;
      state = const PasswordResetState(stage: PasswordResetStage.accepted);
      return true;
    } on ApiException catch (error) {
      if (!mounted || operation != _operation) return false;
      state = PasswordResetState(
        errorMessage: _requestMessage(error),
        retryAfter: error.retryAfter,
      );
      return false;
    } on Object {
      if (!mounted || operation != _operation) return false;
      state = const PasswordResetState(errorMessage: '目前無法受理，請稍後再試');
      return false;
    }
  }

  Future<bool> complete({
    required String token,
    required String newPassword,
  }) async {
    final operation = ++_operation;
    state = const PasswordResetState(
      stage: PasswordResetStage.completion,
      isLoading: true,
    );
    try {
      await _repository.resetPassword(token: token, newPassword: newPassword);
      if (!mounted || operation != _operation) return false;
      state = const PasswordResetState(stage: PasswordResetStage.completed);
      return true;
    } on ApiException catch (error) {
      if (!mounted || operation != _operation) return false;
      state = switch (error.code) {
        'PASSWORD_RESET_TOKEN_EXPIRED' => const PasswordResetState(
          stage: PasswordResetStage.expired,
          errorMessage: '重設連結已過期，請重新申請',
        ),
        'PASSWORD_RESET_TOKEN_USED' => const PasswordResetState(
          stage: PasswordResetStage.used,
          errorMessage: '重設連結已使用，請重新申請',
        ),
        'PASSWORD_RESET_TOKEN_INVALID' => const PasswordResetState(
          stage: PasswordResetStage.invalid,
          errorMessage: '重設連結無效，請重新申請',
        ),
        _ => PasswordResetState(
          stage: PasswordResetStage.completion,
          errorMessage: _passwordMessage(error),
        ),
      };
      return false;
    } on Object {
      if (!mounted || operation != _operation) return false;
      state = const PasswordResetState(
        stage: PasswordResetStage.completion,
        errorMessage: '目前無法重設密碼，請稍後再試',
      );
      return false;
    }
  }

  String _requestMessage(ApiException error) {
    return switch (error.code) {
      'RATE_LIMITED' => '請稍候 ${error.retryAfter ?? 60} 秒後再試',
      'SERVICE_TEMPORARILY_UNAVAILABLE' => '密碼重設服務暫時無法使用，請稍後再試',
      _ => error.message,
    };
  }

  String _passwordMessage(ApiException error) {
    return switch (error.fieldErrors['password']) {
      'PASSWORD_REQUIRED' => '請輸入新密碼',
      'PASSWORD_TOO_SHORT' => '密碼至少需要 15 個字元',
      'PASSWORD_TOO_LONG' => '密碼最多可有 128 個字元',
      'PASSWORD_TOO_WEAK' => '這組密碼太常見，請改用較不容易猜到的密碼',
      _ => error.message,
    };
  }
}
