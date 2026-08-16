import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/device_session.dart';
import 'auth_session_store.dart';

class SessionManagementRepository {
  SessionManagementRepository(
    this._apiClient, {
    required SessionCredentialStore sessionStore,
  }) : _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final SessionCredentialStore _sessionStore;

  Future<DeviceSessionPage> list({required int page}) async {
    final response = await _apiClient.get<DeviceSessionPage>(
      '/v1/auth/sessions',
      queryParameters: {'page': page, 'size': 3},
      fromJsonT:
          (json) => DeviceSessionPage.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<SessionReauthentication> reauthenticate({
    required String password,
  }) async {
    final response = await _apiClient.post<SessionReauthentication>(
      '/v1/auth/reauthentications/password',
      data: {'password': password},
      options: _sessionOptions(),
      fromJsonT:
          (json) =>
              SessionReauthentication.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<void> revokeCurrent() async {
    await _command('/v1/auth/logout');
  }

  Future<void> revokeOne({
    required String sessionId,
    required String credential,
  }) async {
    await _command(
      '/v1/auth/sessions/$sessionId/revocations',
      credential: credential,
    );
  }

  Future<void> revokeOthers({required String credential}) async {
    await _command(
      '/v1/auth/session-revocations/others',
      credential: credential,
    );
  }

  Future<void> revokeAll({required String credential}) async {
    await _command('/v1/auth/session-revocations/all', credential: credential);
  }

  Future<void> _command(String path, {String? credential}) async {
    final response = await _apiClient.post<void>(
      path,
      options: _sessionOptions(credential: credential),
      fromJsonT: (_) {},
      retryOnUnauthorized: false,
    );
    _requireSuccess(response.success, response.message, response.code);
  }

  Options? _sessionOptions({String? credential}) {
    final headers = <String, Object?>{};
    final extra = <String, Object?>{};
    if (_sessionStore.usesCookieTransport) {
      headers.addAll(const {
        'X-Session-Transport': 'COOKIE',
        'X-CSRF-Protection': '1',
      });
      extra['withCredentials'] = true;
    }
    if (credential != null) {
      headers['X-Reauthentication-Credential'] = credential;
    }
    if (headers.isEmpty && extra.isEmpty) {
      return null;
    }
    return Options(headers: headers, extra: extra);
  }

  void _requireSuccess(bool success, String message, String code) {
    if (!success) {
      throw ApiException(
        type: ApiErrorType.unknown,
        message: message,
        code: code,
      );
    }
  }
}
