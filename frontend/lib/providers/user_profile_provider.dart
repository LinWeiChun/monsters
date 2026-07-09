import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';
import 'api_client_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, UserProfileState>((ref) {
      return UserProfileController(ref.watch(userRepositoryProvider));
    });

class UserProfileState {
  const UserProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.profile,
    this.updateSucceeded = false,
  });

  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final UserProfile? profile;
  final bool updateSucceeded;

  UserProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
    UserProfile? profile,
    bool? updateSucceeded,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
      updateSucceeded: updateSucceeded ?? this.updateSucceeded,
    );
  }
}

class UserProfileController extends StateNotifier<UserProfileState> {
  UserProfileController(this._userRepository) : super(const UserProfileState());

  final UserRepository _userRepository;

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      updateSucceeded: false,
    );

    try {
      final profile = await _userRepository.getProfile();
      state = UserProfileState(profile: profile);
    } on ApiException catch (error) {
      state = UserProfileState(errorMessage: error.message);
    } on Object {
      state = const UserProfileState(errorMessage: '系統忙碌，請稍後再試');
    }
  }

  Future<bool> updateProfile({
    required String userName,
    required String? birthday,
  }) async {
    final normalizedBirthday = birthday?.trim();

    state = state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      updateSucceeded: false,
    );

    try {
      final profile = await _userRepository.updateProfile(
        userName: userName.trim(),
        birthday:
            normalizedBirthday == null || normalizedBirthday.isEmpty
                ? null
                : normalizedBirthday,
      );
      state = UserProfileState(profile: profile, updateSucceeded: true);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.message,
        updateSucceeded: false,
      );
      return false;
    } on Object {
      state = state.copyWith(
        isSaving: false,
        errorMessage: '系統忙碌，請稍後再試',
        updateSucceeded: false,
      );
      return false;
    }
  }
}
