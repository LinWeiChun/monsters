import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/member_data_result.dart';
import '../models/member_profile.dart';
import '../repositories/member_data_repository.dart';
import '../services/google_sign_in_service.dart';
import 'api_client_provider.dart';
import 'auth_provider.dart';

final memberDataRepositoryProvider = Provider<MemberDataRepository>((ref) {
  return MemberDataRepository(
    ref.watch(apiClientProvider),
    sessionStore: ref.watch(sessionCredentialStoreProvider),
  );
});

final memberDataControllerProvider =
    StateNotifierProvider<MemberDataController, MemberDataState>((ref) {
      return MemberDataController(
        ref.watch(memberDataRepositoryProvider),
        ref.watch(googleSignInServiceProvider),
      );
    });

class MemberDataState {
  const MemberDataState({
    this.isLoading = false,
    this.isSaving = false,
    this.profile,
    this.errorMessage,
    this.errorCode,
    this.lastBirthdayResult,
    this.deactivated = false,
  });

  final bool isLoading;
  final bool isSaving;
  final MemberProfile? profile;
  final String? errorMessage;
  final String? errorCode;
  final BirthdayCorrectionResult? lastBirthdayResult;
  final bool deactivated;

  MemberDataState copyWith({
    bool? isLoading,
    bool? isSaving,
    MemberProfile? profile,
    String? errorMessage,
    String? errorCode,
    bool clearError = false,
    BirthdayCorrectionResult? lastBirthdayResult,
    bool? deactivated,
  }) {
    return MemberDataState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      lastBirthdayResult: lastBirthdayResult ?? this.lastBirthdayResult,
      deactivated: deactivated ?? this.deactivated,
    );
  }
}

class MemberDataController extends StateNotifier<MemberDataState> {
  MemberDataController(this._repository, this._googleSignInService)
    : super(const MemberDataState());

  final MemberDataRepository _repository;
  final GoogleSignInService _googleSignInService;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.getProfile();
      state = MemberDataState(profile: profile);
    } on ApiException catch (error) {
      state = MemberDataState(
        errorMessage: _message(error),
        errorCode: error.code,
      );
    } on Object {
      state = const MemberDataState(errorMessage: '系統忙碌，請稍後再試');
    }
  }

  Future<bool> updatePublicNickname({required String publicNickname}) async {
    final profile = state.profile;
    if (profile == null) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await _repository.updatePublicNickname(
        publicNickname: publicNickname.trim(),
        expectedVersion: profile.version,
      );
      state = MemberDataState(profile: updated);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _message(error),
        errorCode: error.code,
      );
      return false;
    } on Object {
      state = state.copyWith(isSaving: false, errorMessage: '系統忙碌，請稍後再試');
      return false;
    }
  }

  Future<bool> requestEmailChange({
    required String newEmail,
    required String password,
    required bool useGoogle,
    MemberReauthentication? reauthentication,
  }) async {
    final profile = state.profile;
    if (profile == null) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final proof =
          reauthentication ??
          await _reauthenticate(
            purpose: 'EMAIL_CHANGE',
            password: password,
            useGoogle: useGoogle,
          );
      await _repository.requestEmailChange(
        newEmail: newEmail.trim(),
        expectedVersion: profile.version,
        reauthenticationCredential: proof.credential,
      );
      final refreshed = await _repository.getProfile();
      state = MemberDataState(profile: refreshed);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _message(error),
        errorCode: error.code,
      );
      return false;
    } on Object {
      state = state.copyWith(isSaving: false, errorMessage: '重新驗證失敗，請稍後再試');
      return false;
    }
  }

  Future<BirthdayCorrectionResult?> requestBirthdayCorrection({
    required String birthday,
    required String reason,
    required String password,
    required bool useGoogle,
    MemberReauthentication? reauthentication,
  }) async {
    final profile = state.profile;
    if (profile == null) return null;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final proof =
          reauthentication ??
          await _reauthenticate(
            purpose: 'BIRTHDAY_CORRECTION',
            password: password,
            useGoogle: useGoogle,
          );
      final result = await _repository.requestBirthdayCorrection(
        birthday: birthday,
        reason: reason,
        expectedVersion: profile.version,
        reauthenticationCredential: proof.credential,
      );
      if (result.restricted) {
        state = MemberDataState(profile: profile, lastBirthdayResult: result);
      } else {
        final refreshed = await _repository.getProfile();
        state = MemberDataState(profile: refreshed, lastBirthdayResult: result);
      }
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _message(error),
        errorCode: error.code,
      );
      return null;
    } on Object {
      state = state.copyWith(isSaving: false, errorMessage: '生日更正申請失敗，請稍後再試');
      return null;
    }
  }

  Future<bool> deactivate() async {
    final profile = state.profile;
    if (profile == null) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.deactivate(expectedVersion: profile.version);
      state = state.copyWith(isSaving: false, deactivated: true);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _message(error),
        errorCode: error.code,
      );
      return false;
    } on Object {
      state = state.copyWith(isSaving: false, errorMessage: '帳號停用失敗，請稍後再試');
      return false;
    }
  }

  Future<MemberReauthentication> _reauthenticate({
    required String purpose,
    required String password,
    required bool useGoogle,
  }) async {
    if (!useGoogle) {
      return _repository.reauthenticateWithPassword(
        password: password,
        purpose: purpose,
      );
    }
    final idToken = await _googleSignInService.signInAndGetIdToken();
    return _repository.reauthenticateWithGoogle(
      idToken: idToken,
      purpose: purpose,
    );
  }

  String _message(ApiException error) {
    return switch (error.code) {
      'VERSION_CONFLICT' => '資料已在其他裝置更新，請重新載入後再試',
      'SESSION_REAUTHENTICATION_REQUIRED' => '重新驗證已逾時，請再驗證一次',
      'SESSION_REAUTHENTICATION_FAILED' => '目前密碼不正確',
      'EMAIL_CHANGE_CONFLICT' => '這個 Email 無法使用，沒有變更任何資料',
      'BIRTHDAY_CORRECTION_ALREADY_PENDING' => '已有一筆生日更正正在處理',
      _ => error.message,
    };
  }
}
