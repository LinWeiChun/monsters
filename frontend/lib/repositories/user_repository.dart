import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/password_lock_status.dart';
import '../models/password_lock_verification.dart';
import '../models/user_profile.dart';

class UserRepository {
  const UserRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get<UserProfile>(
      '/users/me',
      fromJsonT: (json) => UserProfile.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }

  Future<UserProfile> updateProfile({
    required String userName,
    required String? birthday,
  }) async {
    final response = await _apiClient.put<UserProfile>(
      '/users/me',
      data: {'userName': userName, 'birthday': birthday},
      fromJsonT: (json) => UserProfile.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }

  Future<PasswordLockStatus> setPasswordLock({
    required String lockPassword,
  }) async {
    final response = await _apiClient.put<PasswordLockStatus>(
      '/users/me/password-lock',
      data: {'lockPassword': lockPassword},
      fromJsonT:
          (json) => PasswordLockStatus.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }

  Future<PasswordLockVerification> verifyPasswordLock({
    required String lockPassword,
  }) async {
    final response = await _apiClient.post<PasswordLockVerification>(
      '/users/me/password-lock/verify',
      data: {'lockPassword': lockPassword},
      fromJsonT:
          (json) =>
              PasswordLockVerification.fromJson(json! as Map<String, dynamic>),
    );

    if (!response.success) {
      throw ApiException(type: ApiErrorType.unknown, message: response.message);
    }

    return response.data;
  }
}
