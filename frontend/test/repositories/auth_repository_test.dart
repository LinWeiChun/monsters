import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/auth_user.dart';
import 'package:monsters/models/login_result.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'restore session rotates saved refresh token before returning',
    () async {
      const store = AuthSessionStore();
      await store.saveSession(_oldLoginResult);
      final dio = Dio();
      Object? requestData;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        requestData = options.data;
        return _jsonResponse({
          'success': true,
          'message': 'Token refresh success',
          'data': _newLoginResult.toJson(),
        });
      });
      final client = ApiClient(config: _config, dio: dio);
      final authStates = <bool>[];
      final repository = AuthRepository(
        client,
        sessionStore: store,
        onAuthenticationChanged: authStates.add,
      );

      final restored = await repository.restoreSession();

      expect(requestData, {'refreshToken': 'old-refresh-token'});
      expect(restored?.accessToken, 'new-access-token');
      expect(
        client.dio.options.headers['Authorization'],
        'Bearer new-access-token',
      );
      expect(authStates, [true]);
      final saved = await store.restoreValidSession();
      expect(saved?.refreshToken, 'new-refresh-token');
    },
  );

  test('invalid refresh token clears session and reports expiration', () async {
    const store = AuthSessionStore();
    await store.saveSession(_oldLoginResult);
    final dio = Dio();
    dio.httpClientAdapter = _CallbackAdapter(
      (_) => _jsonResponse({
        'success': false,
        'message': '尚未登入或 Token 無效',
        'data': null,
      }, statusCode: 401),
    );
    final client = ApiClient(config: _config, dio: dio);
    client.setAccessToken('expired-access-token');
    final authStates = <bool>[];
    final repository = AuthRepository(
      client,
      sessionStore: store,
      onAuthenticationChanged: authStates.add,
    );

    await expectLater(
      repository.restoreSession(),
      throwsA(isA<ApiException>()),
    );

    expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
    expect(await store.restoreValidSession(), isNull);
    expect(authStates, contains(false));
  });

  test('temporary refresh failure keeps the local session', () async {
    const store = AuthSessionStore();
    await store.saveSession(_oldLoginResult);
    final dio = Dio();
    dio.httpClientAdapter = _CallbackAdapter(
      (_) => _jsonResponse({
        'success': false,
        'message': 'Service unavailable',
        'data': null,
      }, statusCode: 503),
    );
    final client = ApiClient(config: _config, dio: dio);
    final authStates = <bool>[];
    final repository = AuthRepository(
      client,
      sessionStore: store,
      onAuthenticationChanged: authStates.add,
    );

    await expectLater(
      repository.restoreSession(),
      throwsA(isA<ApiException>()),
    );

    expect(
      (await store.restoreValidSession())?.refreshToken,
      'old-refresh-token',
    );
    expect(authStates, isEmpty);
  });

  test(
    'continuation response does not create an authenticated session',
    () async {
      const continuationCredential = 'synthetic-continuation-credential';
      const store = AuthSessionStore();
      final dio = Dio();
      dio.httpClientAdapter = _CallbackAdapter(
        (_) => _jsonResponse({
          'success': true,
          'code': 'AUTH_CONTINUATION_REQUIRED',
          'message': 'Additional step required',
          'data': {
            'nextAction': 'COMPLETE_ELIGIBILITY',
            'continuationCredential': continuationCredential,
            'expiresIn': 600,
          },
        }),
      );
      final client = ApiClient(config: _config, dio: dio);
      final authStates = <bool>[];
      final repository = AuthRepository(
        client,
        sessionStore: store,
        onAuthenticationChanged: authStates.add,
      );

      final result = await repository.login(
        email: 'pending.member@example.test',
        password: 'synthetic-password',
      );

      expect(result.requiresContinuation, isTrue);
      expect(result.nextAction, 'COMPLETE_ELIGIBILITY');
      expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
      expect(await store.restoreValidSession(), isNull);
      final preferences = await SharedPreferences.getInstance();
      for (final key in preferences.getKeys()) {
        expect(
          preferences.get(key).toString(),
          isNot(contains(continuationCredential)),
        );
      }
      expect(authStates, [false]);
    },
  );

  test(
    'registration lifecycle uses only the v1 email verification contract',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio();
      dio.httpClientAdapter = _CallbackAdapter((options) {
        requests.add(options);
      return switch ((options.method, options.uri.path)) {
          ('GET', '/api/v1/auth/registration-policy') => _jsonResponse({
            'success': true,
            'code': 'REGISTRATION_POLICY_AVAILABLE',
            'message': 'Registration policy available',
            'data': {
              'termsVersion': 'terms-v1',
              'termsUrl': 'https://example.test/terms',
              'privacyVersion': 'privacy-v1',
              'privacyUrl': 'https://example.test/privacy',
            },
          }),
          ('POST', '/api/v1/auth/register') => _jsonResponse({
            'success': true,
            'code': 'REGISTRATION_ACCEPTED',
            'message': 'Registration request accepted',
            'data': null,
          }, statusCode: 202),
          ('POST', '/api/v1/auth/email-verification-requests') =>
            _jsonResponse({
              'success': true,
              'code': 'EMAIL_VERIFICATION_REQUEST_ACCEPTED',
              'message': 'Email verification request accepted',
              'data': null,
            }, statusCode: 202),
          ('POST', '/api/v1/auth/email-verifications') => _jsonResponse({
            'success': true,
            'code': 'EMAIL_VERIFIED',
            'message': 'Email verified',
            'data': {
              'nextAction': 'COMPLETE_ELIGIBILITY',
              'continuationCredential': 'synthetic-continuation',
              'expiresIn': 600,
            },
          }),
          _ =>
            throw StateError(
          'Unexpected request: ${options.method} ${options.uri.path}',
            ),
        };
      });
      final repository = AuthRepository(ApiClient(config: _config, dio: dio));

      final policy = await repository.registrationPolicy();
      await repository.register(
        email: 'member@example.test',
        password: 'synthetic-password',
        acceptedTermsVersion: policy.termsVersion,
        acceptedPrivacyVersion: policy.privacyVersion,
      );
      await repository.requestVerificationEmail(email: 'member@example.test');
      final verification = await repository.verifyEmail(
        token: 'synthetic-token',
      );

      expect(policy.termsUrl, 'https://example.test/terms');
      expect(policy.privacyUrl, 'https://example.test/privacy');
      expect(verification.nextAction, 'COMPLETE_ELIGIBILITY');
      expect(verification.continuationCredential, 'synthetic-continuation');
    expect(requests.map((request) => request.uri.path), [
        '/api/v1/auth/registration-policy',
        '/api/v1/auth/register',
        '/api/v1/auth/email-verification-requests',
        '/api/v1/auth/email-verifications',
      ]);
      expect(requests[1].data, {
        'email': 'member@example.test',
        'password': 'synthetic-password',
        'acceptedTermsVersion': 'terms-v1',
        'acceptedPrivacyVersion': 'privacy-v1',
      });
      expect(
        (requests[1].data as Map<String, Object?>).containsKey('account'),
        isFalse,
      );
      expect(
        (requests[1].data as Map<String, Object?>).containsKey('userName'),
        isFalse,
      );
    },
  );
}

const _config = AppConfig(
  apiBaseUrl: 'http://example.com/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

const _oldLoginResult = LoginResult(
  accessToken: 'old-access-token',
  refreshToken: 'old-refresh-token',
  tokenType: 'Bearer',
  expiresIn: 3600,
  user: _user,
);

const _newLoginResult = LoginResult(
  accessToken: 'new-access-token',
  refreshToken: 'new-refresh-token',
  tokenType: 'Bearer',
  expiresIn: 3600,
  user: _user,
);

const _user = AuthUser(
  userId: 1,
  account: 'wei_account',
  email: 'user@example.com',
  userName: 'Wei',
  avatarUrl: null,
);

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.callback);

  final ResponseBody Function(RequestOptions options) callback;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return callback(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, Object?> body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
