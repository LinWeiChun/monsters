import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/login_result.dart';
import '../models/registration_policy.dart';
import 'auth_session_store.dart';

class AuthRepository {
  AuthRepository(
    this._apiClient, {
    required SessionCredentialStore sessionStore,
    void Function(bool isAuthenticated)? onAuthenticationChanged,
  }) : _sessionStore = sessionStore,
       _onAuthenticationChanged = onAuthenticationChanged;

  final ApiClient _apiClient;
  final SessionCredentialStore _sessionStore;
  final void Function(bool isAuthenticated)? _onAuthenticationChanged;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<LoginResult>(
      '/v1/auth/login',
      data: {'email': email, 'password': password},
      options: _loginOptions,
      fromJsonT: (json) => LoginResult.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    await _applyLoginResult(response.data);
    return response.data;
  }

  Future<LoginResult> googleLogin({required String idToken}) async {
    final response = await _apiClient.post<LoginResult>(
      '/auth/google-login',
      data: {'idToken': idToken},
      fromJsonT: (json) => LoginResult.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    await _applyLoginResult(response.data);
    return response.data;
  }

  Future<LoginResult?> restoreSession({DateTime? now}) async {
    final refreshCredential = await _sessionStore.readRefreshCredential();
    if (!_sessionStore.usesCookieTransport && refreshCredential == null) {
      _apiClient.setAccessToken(null);
      return null;
    }

    return _exchangeRefreshToken(refreshCredential);
  }

  Future<String?> refreshAccessToken() async {
    final refreshCredential = await _sessionStore.readRefreshCredential();
    if (!_sessionStore.usesCookieTransport && refreshCredential == null) {
      await _invalidateSession();
      return null;
    }

    try {
      final refreshed = await _exchangeRefreshToken(refreshCredential);
      return refreshed.accessToken;
    } on ApiException catch (error) {
      if (error.type == ApiErrorType.unauthorized) {
        await _invalidateSession();
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>(
        '/v1/auth/logout',
        options: _sessionTransportOptions,
        fromJsonT: (_) {},
        retryOnUnauthorized: false,
      );
    } finally {
      await _invalidateSession();
    }
  }

  Future<void> clearLocalSession() => _invalidateSession();

  Future<RegistrationPolicy> registrationPolicy() async {
    final response = await _apiClient.get<RegistrationPolicy>(
      '/v1/auth/registration-policy',
      fromJsonT:
          (json) => RegistrationPolicy.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    if (!response.success) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    }
    return response.data;
  }

  Future<void> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
    required String acceptedPrivacyVersion,
  }) async {
    final response = await _apiClient.post<void>(
      '/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'acceptedTermsVersion': acceptedTermsVersion,
        'acceptedPrivacyVersion': acceptedPrivacyVersion,
      },
      fromJsonT: (_) {},
      retryOnUnauthorized: false,
    );

    if (!response.success) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    }
  }

  Future<void> requestVerificationEmail({required String email}) async {
    final response = await _apiClient.post<void>(
      '/v1/auth/email-verification-requests',
      data: {'email': email},
      fromJsonT: (_) {},
      retryOnUnauthorized: false,
    );
    if (!response.success) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    }
  }

  Future<LoginResult> verifyEmail({required String token}) async {
    final response = await _apiClient.post<LoginResult>(
      '/v1/auth/email-verifications',
      data: {'token': token},
      fromJsonT: (json) => LoginResult.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    if (!response.success) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    }
    return response.data;
  }

  Future<LoginResult> _exchangeRefreshToken(String? refreshCredential) async {
    try {
      final response = await _apiClient.post<LoginResult>(
        '/v1/auth/session-refreshes',
        data:
            _sessionStore.usesCookieTransport
                ? null
                : {'refreshCredential': refreshCredential},
        options: _sessionTransportOptions,
        fromJsonT:
            (json) => LoginResult.fromJson(json! as Map<String, dynamic>),
        retryOnUnauthorized: false,
      );

      if (!response.success) {
        throw ApiException(
          type: ApiErrorType.unknown,
          message: response.message,
        );
      }

      if (!response.data.isAuthenticated) {
        await _invalidateSession();
        throw const ApiException(
          type: ApiErrorType.unauthorized,
          message: 'Session refresh did not return an authenticated session',
        );
      }
      await _applyLoginResult(response.data);
      return response.data;
    } on ApiException catch (error) {
      if (error.type == ApiErrorType.unauthorized) {
        await _invalidateSession();
      }
      rethrow;
    }
  }

  Future<void> _invalidateSession() async {
    _apiClient.setAccessToken(null);
    await _sessionStore.clearRefreshCredential();
    _onAuthenticationChanged?.call(false);
  }

  Future<void> _applyLoginResult(LoginResult result) async {
    if (!result.isAuthenticated) {
      await _invalidateSession();
      return;
    }

    if (!_sessionStore.usesCookieTransport) {
      final refreshCredential = result.refreshToken;
      if (refreshCredential == null || refreshCredential.isEmpty) {
        await _invalidateSession();
        throw const ApiException(
          type: ApiErrorType.unauthorized,
          message: 'Authenticated app response omitted refresh credential',
        );
      }
      await _sessionStore.saveRefreshCredential(refreshCredential);
    }
    _apiClient.setAccessToken(result.accessToken);
    _onAuthenticationChanged?.call(true);
  }

  Options? get _sessionTransportOptions {
    if (!_sessionStore.usesCookieTransport) {
      return null;
    }
    return Options(
      headers: const {
        'X-Session-Transport': 'COOKIE',
        'X-CSRF-Protection': '1',
      },
      extra: const {'withCredentials': true},
    );
  }

  Options get _loginOptions {
    final platform =
        kIsWeb
            ? 'WEB'
            : switch (defaultTargetPlatform) {
              TargetPlatform.android => 'ANDROID',
              TargetPlatform.iOS => 'IOS',
              _ => 'UNKNOWN',
            };
    final headers = <String, Object?>{'X-Client-Platform': platform};
    final extra = <String, Object?>{};
    if (_sessionStore.usesCookieTransport) {
      headers.addAll(const {
        'X-Session-Transport': 'COOKIE',
        'X-CSRF-Protection': '1',
      });
      extra['withCredentials'] = true;
    }
    return Options(headers: headers, extra: extra);
  }
}
