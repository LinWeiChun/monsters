import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/member_data_result.dart';
import '../models/member_profile.dart';
import 'auth_session_store.dart';

class MemberDataRepository {
  const MemberDataRepository(
    this._apiClient, {
    required SessionCredentialStore sessionStore,
  }) : _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final SessionCredentialStore _sessionStore;

  Future<MemberProfile> getProfile() async {
    final response = await _apiClient.get<MemberProfile>(
      '/v1/members/me',
      fromJsonT:
          (json) => MemberProfile.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<MemberProfile> updatePublicNickname({
    required String publicNickname,
    required int expectedVersion,
  }) async {
    final response = await _apiClient.put<MemberProfile>(
      '/v1/members/me/public-nickname',
      data: {
        'publicNickname': publicNickname,
        'confirmExistingCommunityUpdate': true,
        'expectedVersion': expectedVersion,
      },
      fromJsonT:
          (json) => MemberProfile.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<MemberReauthentication> reauthenticateWithPassword({
    required String password,
    required String purpose,
  }) async {
    final response = await _apiClient.post<MemberReauthentication>(
      '/v1/auth/reauthentications/password',
      data: {'password': password, 'purpose': purpose},
      options: _protectedOptions(),
      retryOnUnauthorized: false,
      fromJsonT:
          (json) =>
              MemberReauthentication.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<MemberReauthentication> reauthenticateWithGoogle({
    required String idToken,
    required String purpose,
  }) async {
    final response = await _apiClient.post<MemberReauthentication>(
      '/v1/auth/reauthentications/google',
      data: {'idToken': idToken, 'purpose': purpose},
      options: _protectedOptions(),
      retryOnUnauthorized: false,
      fromJsonT:
          (json) =>
              MemberReauthentication.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<void> requestEmailChange({
    required String newEmail,
    required int expectedVersion,
    required String reauthenticationCredential,
  }) async {
    final response = await _apiClient.post<void>(
      '/v1/members/me/email-change-requests',
      data: {'newEmail': newEmail, 'expectedVersion': expectedVersion},
      options: _protectedOptions(
        reauthenticationCredential: reauthenticationCredential,
      ),
      fromJsonT: (_) {},
      retryOnUnauthorized: false,
    );
    _requireSuccess(response.success, response.message, response.code);
  }

  Future<void> completeEmailChange({required String token}) async {
    final response = await _apiClient.post<void>(
      '/v1/auth/email-changes',
      data: {'token': token},
      fromJsonT: (_) {},
      retryOnUnauthorized: false,
    );
    _requireSuccess(response.success, response.message, response.code);
  }

  Future<BirthdayCorrectionResult> requestBirthdayCorrection({
    required String birthday,
    required String reason,
    required int expectedVersion,
    required String reauthenticationCredential,
  }) async {
    final response = await _apiClient.post<BirthdayCorrectionResult>(
      '/v1/members/me/birthday-correction-requests',
      data: {
        'birthday': birthday,
        'reason': reason,
        'expectedVersion': expectedVersion,
      },
      options: _protectedOptions(
        reauthenticationCredential: reauthenticationCredential,
      ),
      retryOnUnauthorized: false,
      fromJsonT:
          (json) =>
              BirthdayCorrectionResult.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<MemberStateResult> deactivate({required int expectedVersion}) async {
    final response = await _apiClient.post<MemberStateResult>(
      '/v1/members/me/deactivations',
      data: {'confirmed': true, 'expectedVersion': expectedVersion},
      options: _protectedOptions(),
      retryOnUnauthorized: false,
      fromJsonT:
          (json) => MemberStateResult.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Future<MemberStateResult> restore({
    required String continuationCredential,
  }) async {
    final response = await _apiClient.post<MemberStateResult>(
      '/v1/auth/member-restorations',
      data: const {'confirmed': true},
      options: _continuationOptions(continuationCredential),
      retryOnUnauthorized: false,
      fromJsonT:
          (json) => MemberStateResult.fromJson(json! as Map<String, dynamic>),
    );
    _requireSuccess(response.success, response.message, response.code);
    return response.data;
  }

  Options? _protectedOptions({String? reauthenticationCredential}) {
    final headers = <String, Object?>{};
    if (reauthenticationCredential != null) {
      headers['X-Reauthentication-Credential'] = reauthenticationCredential;
    }
    final extra = <String, Object?>{};
    if (_sessionStore.usesCookieTransport) {
      headers.addAll(const {
        'X-Session-Transport': 'COOKIE',
        'X-CSRF-Protection': '1',
      });
      extra['withCredentials'] = true;
    }
    return headers.isEmpty && extra.isEmpty
        ? null
        : Options(headers: headers, extra: extra);
  }

  Options _continuationOptions(String credential) {
    return Options(
      headers: {'Authorization': 'Continuation $credential'},
      extra:
          _sessionStore.usesCookieTransport
              ? const {'withCredentials': true}
              : const {},
    );
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
