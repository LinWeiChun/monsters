import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/login_result.dart';
import '../models/register_result.dart';
import 'auth_session_store.dart';

class AuthRepository {
  const AuthRepository(
    this._apiClient, {
    AuthSessionStore sessionStore = const AuthSessionStore(),
  }) : _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final AuthSessionStore _sessionStore;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<LoginResult>(
      '/auth/login',
      data: {'email': email, 'password': password},
      fromJsonT: (json) => LoginResult.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    _apiClient.setAccessToken(response.data.accessToken);
    await _sessionStore.saveSession(response.data);
    return response.data;
  }

  Future<LoginResult?> restoreSession({DateTime? now}) async {
    final loginResult = await _sessionStore.restoreValidSession(now: now);
    if (loginResult == null) {
      _apiClient.setAccessToken(null);
      return null;
    }

    _apiClient.setAccessToken(loginResult.accessToken);
    return loginResult;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<void>('/auth/logout', fromJsonT: (_) {});
    } finally {
      _apiClient.setAccessToken(null);
      await _sessionStore.clearSession();
    }
  }

  Future<RegisterResult> register({
    required String email,
    required String password,
    required String userName,
  }) async {
    final response = await _apiClient.post<RegisterResult>(
      '/auth/register',
      data: {'email': email, 'password': password, 'userName': userName},
      fromJsonT:
          (json) => RegisterResult.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }
}
