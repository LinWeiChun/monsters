import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/login_result.dart';
import '../models/registration_policy.dart';
import 'auth_session_store.dart';

class AuthRepository {
  const AuthRepository(
    this._apiClient, {
    AuthSessionStore sessionStore = const AuthSessionStore(),
    void Function(bool isAuthenticated)? onAuthenticationChanged,
  }) : _sessionStore = sessionStore,
       _onAuthenticationChanged = onAuthenticationChanged;

  final ApiClient _apiClient;
  final AuthSessionStore _sessionStore;
  final void Function(bool isAuthenticated)? _onAuthenticationChanged;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<LoginResult>(
      '/auth/login',
      data: {'email': email, 'password': password},
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
    final loginResult = await _sessionStore.restoreValidSession(now: now);
    if (loginResult == null) {
      _apiClient.setAccessToken(null);
      return null;
    }

    return _exchangeRefreshToken(loginResult.refreshToken!);
  }

  Future<String?> refreshAccessToken() async {
    final loginResult = await _sessionStore.restoreValidSession();
    if (loginResult == null) {
      await _invalidateSession();
      return null;
    }

    try {
      final refreshed = await _exchangeRefreshToken(loginResult.refreshToken!);
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
      final loginResult = await _sessionStore.restoreValidSession();
      await _apiClient.post<void>(
        '/auth/logout',
        data:
            loginResult == null
                ? null
                : {'refreshToken': loginResult.refreshToken},
        fromJsonT: (_) {},
        retryOnUnauthorized: false,
      );
    } finally {
      await _invalidateSession();
    }
  }

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

  Future<LoginResult> _exchangeRefreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post<LoginResult>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
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
    await _sessionStore.clearSession();
    _onAuthenticationChanged?.call(false);
  }

  Future<void> _applyLoginResult(LoginResult result) async {
    if (!result.isAuthenticated) {
      await _invalidateSession();
      return;
    }

    _apiClient.setAccessToken(result.accessToken);
    await _sessionStore.saveSession(result);
    _onAuthenticationChanged?.call(true);
  }
}
