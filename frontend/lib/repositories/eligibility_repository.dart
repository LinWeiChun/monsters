import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_error_type.dart';
import '../core/network/api_exception.dart';
import '../models/eligibility_policy.dart';

class EligibilityRepository {
  const EligibilityRepository(this._client);
  final ApiClient _client;
  Future<EligibilityPolicy> policy() async {
    final response = await _client.get<EligibilityPolicy>(
      '/v1/auth/eligibility-policy',
      fromJsonT:
          (json) => EligibilityPolicy.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    if (!response.success)
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    return response.data;
  }

  Future<EligibilityOutcome> complete({
    required String credential,
    required String region,
    required DateTime birthday,
    String? nickname,
    String? guardianEmail,
    required EligibilityPolicy policy,
    required bool confirmDisclosure,
  }) async {
    final response = await _client.post<EligibilityOutcome>(
      '/v1/auth/eligibility-completions',
      options: Options(headers: {'Authorization': 'Continuation $credential'}),
      data: {
        'serviceRegion': region,
        'birthday': birthday.toIso8601String().substring(0, 10),
        'publicNickname': nickname,
        'guardianEmail': guardianEmail,
        'acceptedMinorNoticeVersion':
            guardianEmail == null ? null : policy.minorNotice.version,
        'guardianConsentVersion':
            guardianEmail == null ? null : policy.guardianConsent.version,
        'confirmPublicNicknameDisclosure': confirmDisclosure,
        'publicNicknameDisclosureVersion':
            confirmDisclosure ? policy.publicNicknameDisclosure.version : null,
      },
      fromJsonT:
          (json) => EligibilityOutcome.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    if (!response.success)
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    return response.data;
  }

  Future<GuardianConsentAction> guardianAction(
    String token, {
    required bool submit,
  }) async {
    final path =
        submit
            ? '/v1/auth/guardian-consents'
            : '/v1/auth/guardian-consent-actions';
    final response = await _client.post<GuardianConsentAction>(
      path,
      data: {'token': token},
      fromJsonT:
          (json) =>
              GuardianConsentAction.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    if (!response.success)
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    return response.data;
  }

  Future<GuardianConsentAction> withdraw(String token) async {
    final response = await _client.post<GuardianConsentAction>(
      '/v1/auth/guardian-consent-withdrawals',
      data: {'token': token},
      fromJsonT:
          (json) =>
              GuardianConsentAction.fromJson(json! as Map<String, dynamic>),
      retryOnUnauthorized: false,
    );
    if (!response.success)
      throw ApiException(
        type: ApiErrorType.unknown,
        message: response.message,
        code: response.code,
      );
    return response.data;
  }

  Future<void> requestWithdrawal({
    required String reference,
    required String email,
  }) async {
    await _client.post<void>(
      '/v1/auth/guardian-consent-withdrawal-requests',
      data: {'consentReference': reference, 'guardianEmail': email},
      fromJsonT: (_) {},
      retryOnUnauthorized: false,
    );
  }
}
