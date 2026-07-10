import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../repositories/user_repository.dart';
import 'user_profile_provider.dart';

final passwordLockControllerProvider =
    StateNotifierProvider<PasswordLockController, PasswordLockState>((ref) {
      return PasswordLockController(ref.watch(userRepositoryProvider));
    });

class PasswordLockState {
  const PasswordLockState({
    this.isLoading = false,
    this.errorMessage,
    this.setSucceeded = false,
    this.verified,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool setSucceeded;
  final bool? verified;

  PasswordLockState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? setSucceeded,
    bool clearVerified = false,
    bool? verified,
  }) {
    return PasswordLockState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      setSucceeded: setSucceeded ?? this.setSucceeded,
      verified: clearVerified ? null : verified ?? this.verified,
    );
  }
}

class PasswordLockController extends StateNotifier<PasswordLockState> {
  PasswordLockController(this._userRepository)
    : super(const PasswordLockState());

  final UserRepository _userRepository;

  Future<bool> setPasswordLock(String lockPassword) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      setSucceeded: false,
      clearVerified: true,
    );

    try {
      final status = await _userRepository.setPasswordLock(
        lockPassword: lockPassword,
      );
      state = PasswordLockState(setSucceeded: status.enabled);
      return status.enabled;
    } on ApiException catch (error) {
      state = PasswordLockState(errorMessage: error.message);
      return false;
    } on Object {
      state = const PasswordLockState(errorMessage: '系統忙碌，請稍後再試');
      return false;
    }
  }

  Future<bool> verifyPasswordLock(String lockPassword) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      setSucceeded: false,
      clearVerified: true,
    );

    try {
      final result = await _userRepository.verifyPasswordLock(
        lockPassword: lockPassword,
      );
      state = PasswordLockState(verified: result.verified);
      return result.verified;
    } on ApiException catch (error) {
      state = PasswordLockState(errorMessage: error.message);
      return false;
    } on Object {
      state = const PasswordLockState(errorMessage: '系統忙碌，請稍後再試');
      return false;
    }
  }
}
