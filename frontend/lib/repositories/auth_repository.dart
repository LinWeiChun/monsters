import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/login_result.dart';

class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

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
    return response.data;
  }
}
