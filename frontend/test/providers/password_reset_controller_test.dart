import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/providers/password_reset_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/repositories/auth_session_store.dart';

void main() {
  test('late request response cannot replace a new completion flow', () async {
    final repository = _ControlledRepository();
    final controller = PasswordResetController(repository);
    addTearDown(controller.dispose);
    final pending = controller.request(email: ' example@example.test ');
    controller.beginCompletion();
    repository.pending.complete();
    expect(await pending, isFalse);
    expect(controller.state.stage, PasswordResetStage.completion);
  });

  test('late completion error cannot replace another token flow', () async {
    final repository = _ControlledRepository();
    final controller = PasswordResetController(repository);
    addTearDown(controller.dispose);
    final pending = controller.complete(token: 'old', newPassword: 'password');
    controller.beginCompletion();
    repository.pending.completeError(
      const ApiException(
        type: ApiErrorType.validation,
        message: 'expired',
        code: 'PASSWORD_RESET_TOKEN_EXPIRED',
      ),
    );
    expect(await pending, isFalse);
    expect(controller.state.stage, PasswordResetStage.completion);
    expect(controller.state.errorMessage, isNull);
  });

  test('disposed controller ignores a pending result', () async {
    final repository = _ControlledRepository();
    final controller = PasswordResetController(repository);
    final pending = controller.request(email: 'example@example.test');
    controller.dispose();
    repository.pending.complete();
    expect(await pending, isFalse);
  });

  test(
    'rate limiting preserves retry time and allows another request',
    () async {
      final repository = _ControlledRepository();
      final controller = PasswordResetController(repository);
      addTearDown(controller.dispose);
      final pending = controller.request(email: 'example@example.test');
      repository.pending.completeError(
        const ApiException(
          type: ApiErrorType.validation,
          message: 'rate limited',
          code: 'RATE_LIMITED',
          retryAfter: 75,
        ),
      );
      expect(await pending, isFalse);
      expect(controller.state.retryAfter, 75);
      expect(controller.state.errorMessage, '請稍候 75 秒後再試');
      controller.beginRequest();
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.isLoading, isFalse);
    },
  );

  for (final entry
      in {
        'PASSWORD_RESET_TOKEN_INVALID': PasswordResetStage.invalid,
        'PASSWORD_RESET_TOKEN_EXPIRED': PasswordResetStage.expired,
        'PASSWORD_RESET_TOKEN_USED': PasswordResetStage.used,
      }.entries) {
    test('${entry.key} maps to its recovery state', () async {
      final repository = _ControlledRepository();
      final controller = PasswordResetController(repository);
      addTearDown(controller.dispose);
      final pending = controller.complete(
        token: 'test',
        newPassword: 'password',
      );
      repository.pending.completeError(
        ApiException(
          type: ApiErrorType.validation,
          message: 'failed',
          code: entry.key,
        ),
      );
      expect(await pending, isFalse);
      expect(controller.state.stage, entry.value);
      expect(controller.state.isLoading, isFalse);
    });
  }
}

class _ControlledRepository extends AuthRepository {
  _ControlledRepository()
    : super(
        ApiClient(
          config: const AppConfig(
            apiBaseUrl: 'https://api.example.test/api',
            connectTimeout: Duration(seconds: 1),
            receiveTimeout: Duration(seconds: 1),
            sendTimeout: Duration(seconds: 1),
          ),
          dio: Dio(),
        ),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

  final pending = Completer<void>();

  @override
  Future<void> requestPasswordReset({required String email}) => pending.future;

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) => pending.future;
}
