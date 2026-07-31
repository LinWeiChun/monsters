import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/login_result.dart';
import '../models/registration_policy.dart';
import '../repositories/auth_repository.dart';
import '../services/google_sign_in_service.dart';
import 'api_client_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final repository = AuthRepository(
    apiClient,
    onAuthenticationChanged: (isAuthenticated) {
      ref.read(authSessionExpiredProvider.notifier).state = !isAuthenticated;
    },
  );
  apiClient.setAccessTokenRefresher(repository.refreshAccessToken);
  ref.onDispose(() => apiClient.setAccessTokenRefresher(null));
  return repository;
});

final authSessionExpiredProvider = StateProvider<bool>((ref) => false);

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService(config: ref.watch(appConfigProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      ref.watch(authRepositoryProvider),
      ref.watch(googleSignInServiceProvider),
    );
  },
);

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.loginResult,
    this.registrationPolicy,
    this.registrationAccepted = false,
    this.verificationResult,
    this.retryAfter,
  });

  final bool isLoading;
  final String? errorMessage;
  final LoginResult? loginResult;
  final RegistrationPolicy? registrationPolicy;
  final bool registrationAccepted;
  final LoginResult? verificationResult;
  final int? retryAfter;

  String? get continuationMessage {
    if (loginResult?.requiresContinuation != true) {
      return null;
    }

    return switch (loginResult!.nextAction) {
      'VERIFY_EMAIL' => '請完成 Email 驗證後再繼續',
      'COMPLETE_ELIGIBILITY' => '請完成會員資格資料後再繼續',
      'REACTIVATE_ACCOUNT' => '請先恢復帳號後再繼續',
      'REVIEW_SUSPENSION' => '此帳號目前受到限制，請依指示處理',
      'REVIEW_DELETION' => '此帳號正在刪除流程中，請依指示處理',
      _ => '請完成必要步驟後再繼續',
    };
  }

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    LoginResult? loginResult,
    RegistrationPolicy? registrationPolicy,
    bool? registrationAccepted,
    LoginResult? verificationResult,
    int? retryAfter,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      loginResult: loginResult ?? this.loginResult,
      registrationPolicy: registrationPolicy ?? this.registrationPolicy,
      registrationAccepted: registrationAccepted ?? this.registrationAccepted,
      verificationResult: verificationResult ?? this.verificationResult,
      retryAfter: retryAfter ?? this.retryAfter,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._authRepository, this._googleSignInService)
    : super(const AuthState());

  final AuthRepository _authRepository;
  final GoogleSignInService _googleSignInService;
  StreamSubscription<String>? _googleIdTokenSubscription;

  Future<void> initializeGoogleSignIn() async {
    if (_googleIdTokenSubscription != null) {
      return;
    }

    try {
      await _googleSignInService.initialize();
      _googleIdTokenSubscription = _googleSignInService.idTokenEvents.listen(
        (idToken) => unawaited(_loginWithGoogleIdToken(idToken)),
        onError: (_) {
          state = const AuthState(errorMessage: 'Google 登入失敗，請稍後再試');
        },
      );
    } on Object {
      // The explicit Google sign-in action will surface the setup error.
    }
  }

  Future<bool> restoreSession({DateTime? now}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _authRepository.restoreSession(now: now);
      if (result == null) {
        state = const AuthState();
        return false;
      }

      state = AuthState(loginResult: result);
      return true;
    } on Object {
      state = const AuthState();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
      );
      state = AuthState(loginResult: result);
      return true;
    } on ApiException catch (error) {
      state = AuthState(errorMessage: error.message);
      return false;
    } on Object {
      state = const AuthState(errorMessage: '系統忙碌，請稍後再試');
      return false;
    }
  }

  Future<bool> googleLogin() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final idToken = await _googleSignInService.signInAndGetIdToken();
      return _loginWithGoogleIdToken(idToken);
    } on GoogleSignInUnsupportedException {
      state = const AuthState(errorMessage: '請使用 Google 官方登入按鈕');
      return false;
    } on GoogleIdTokenUnavailableException {
      state = const AuthState(errorMessage: '無法取得 Google 登入憑證，請重新嘗試');
      return false;
    } on ApiException catch (error) {
      state = AuthState(errorMessage: error.message);
      return false;
    } on Object {
      state = const AuthState(errorMessage: 'Google 登入失敗，請稍後再試');
      return false;
    }
  }

  Future<bool> _loginWithGoogleIdToken(String idToken) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _authRepository.googleLogin(idToken: idToken);
      state = AuthState(loginResult: result);
      return true;
    } on ApiException catch (error) {
      state = AuthState(errorMessage: error.message);
      return false;
    } on Object {
      state = const AuthState(errorMessage: 'Google 登入失敗，請稍後再試');
      return false;
    }
  }

  Future<bool> loadRegistrationPolicy() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final policy = await _authRepository.registrationPolicy();
      state = AuthState(registrationPolicy: policy);
      return true;
    } on ApiException catch (error) {
      state = AuthState(errorMessage: _registrationMessage(error));
      return false;
    } on Object {
      state = const AuthState(errorMessage: '目前無法載入註冊條款，請稍後再試');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
    required String acceptedPrivacyVersion,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await _authRepository.register(
        email: email.trim(),
        password: password,
        acceptedTermsVersion: acceptedTermsVersion,
        acceptedPrivacyVersion: acceptedPrivacyVersion,
      );
      state = AuthState(
        registrationPolicy: state.registrationPolicy,
        registrationAccepted: true,
      );
      return true;
    } on ApiException catch (error) {
      state = AuthState(
        registrationPolicy: state.registrationPolicy,
        errorMessage: _registrationMessage(error),
      );
      return false;
    } on Object {
      state = const AuthState(errorMessage: '系統忙碌，請稍後再試');
      return false;
    }
  }

  Future<bool> requestVerificationEmail({required String email}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await _authRepository.requestVerificationEmail(email: email.trim());
      state = const AuthState();
      return true;
    } on ApiException catch (error) {
      state = AuthState(
        errorMessage: _registrationMessage(error),
        retryAfter: error.retryAfter,
      );
      return false;
    } on Object {
      state = const AuthState(errorMessage: '目前無法重寄驗證信，請稍後再試');
      return false;
    }
  }

  Future<bool> verifyEmail({required String token}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final result = await _authRepository.verifyEmail(token: token);
      state = AuthState(verificationResult: result);
      return true;
    } on ApiException catch (error) {
      state = AuthState(errorMessage: _registrationMessage(error));
      return false;
    } on Object {
      state = const AuthState(errorMessage: '目前無法驗證 Email，請稍後再試');
      return false;
    }
  }

  String _registrationMessage(ApiException error) {
    final passwordError = error.fieldErrors['password'];
    if (passwordError != null) {
      return switch (passwordError) {
        'PASSWORD_REQUIRED' => '請輸入密碼',
        'PASSWORD_TOO_SHORT' => '密碼至少需要 15 個字元',
        'PASSWORD_TOO_LONG' => '密碼最多可有 128 個字元',
        'PASSWORD_TOO_WEAK' => '這組密碼太常見，請改用較不容易猜到的密碼',
        _ => '密碼不符合目前的安全規則',
      };
    }
    return switch (error.code) {
      'REGISTRATION_POLICY_OUTDATED' => '條款內容已更新，請重新確認後再送出',
      'EMAIL_VERIFICATION_TOKEN_EXPIRED' => '驗證連結已過期，請重新開始驗證流程',
      'EMAIL_VERIFICATION_TOKEN_INVALID' => '驗證連結無效或已使用',
      'RATE_LIMITED' => '請稍候 ${error.retryAfter ?? 60} 秒後再試',
      'SERVICE_TEMPORARILY_UNAVAILABLE' => '註冊服務暫時無法使用，請稍後再試',
      _ => error.message,
    };
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await _authRepository.logout();
    } finally {
      try {
        await _googleSignInService.signOut();
      } on Object {
        // Local logout must still complete even if Google SDK sign-out fails.
      }
      state = const AuthState();
    }
  }

  @override
  void dispose() {
    _googleIdTokenSubscription?.cancel();
    super.dispose();
  }
}
