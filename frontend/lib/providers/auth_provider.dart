import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/login_result.dart';
import '../models/register_result.dart';
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
    this.registerResult,
  });

  final bool isLoading;
  final String? errorMessage;
  final LoginResult? loginResult;
  final RegisterResult? registerResult;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    LoginResult? loginResult,
    RegisterResult? registerResult,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      loginResult: loginResult ?? this.loginResult,
      registerResult: registerResult ?? this.registerResult,
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

  Future<bool> register({
    required String account,
    required String email,
    required String password,
    required String userName,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _authRepository.register(
        account: account.trim().toLowerCase(),
        email: email.trim(),
        password: password,
        userName: userName.trim(),
      );
      state = AuthState(registerResult: result);
      return true;
    } on ApiException catch (error) {
      state = AuthState(errorMessage: error.message);
      return false;
    } on Object {
      state = const AuthState(errorMessage: '系統忙碌，請稍後再試');
      return false;
    }
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
