import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/login_result.dart';
import '../models/register_result.dart';
import '../repositories/auth_repository.dart';
import 'api_client_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authRepositoryProvider));
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
  AuthController(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

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

  Future<bool> register({
    required String email,
    required String password,
    required String userName,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final result = await _authRepository.register(
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
      state = const AuthState();
    }
  }
}
