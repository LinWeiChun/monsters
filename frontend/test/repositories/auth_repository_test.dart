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
    'password reset request uses formal resource endpoint without token data',
    () async {
      final dio = Dio();
      RequestOptions? request;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        request = options;
        return _jsonResponse({
          'success': true,
          'code': 'PASSWORD_RESET_REQUEST_ACCEPTED',
          'message': 'Password reset request accepted',
          'data': null,
        }, statusCode: 202);
      });
      final repository = AuthRepository(
        ApiClient(config: _config, dio: dio),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

      await repository.requestPasswordReset(email: 'member@example.test');

      expect(request?.uri.path, '/api/v1/auth/password-reset-requests');
      expect(request?.data, {'email': 'member@example.test'});
    },
  );

  test('password reset completion clears current local session', () async {
    final store = _MemorySessionCredentialStore('old-refresh-token');
    final dio = Dio();
    RequestOptions? request;
    dio.httpClientAdapter = _CallbackAdapter((options) {
      request = options;
      return _jsonResponse({
        'success': true,
        'code': 'PASSWORD_RESET_COMPLETED',
        'message': 'Password reset completed',
        'data': null,
      });
    });
    final client = ApiClient(config: _config, dio: dio);
    client.setAccessToken('old-access-token');
    final authStates = <bool>[];
    final repository = AuthRepository(
      client,
      sessionStore: store,
      onAuthenticationChanged: authStates.add,
    );

    await repository.resetPassword(
      token: 'synthetic-token',
      newPassword: 'correct horse battery staple',
    );

    expect(request?.uri.path, '/api/v1/auth/password-resets');
    expect(request?.data, {
      'token': 'synthetic-token',
      'newPassword': 'correct horse battery staple',
    });
    expect(await store.readRefreshCredential(), isNull);
    expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
    expect(authStates, [false]);
  });

  test(
    'restore session rotates saved refresh token before returning',
    () async {
      final store = _MemorySessionCredentialStore('old-refresh-token');
      final dio = Dio();
      RequestOptions? refreshRequest;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        refreshRequest = options;
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

      expect(refreshRequest?.uri.path, '/api/v1/auth/session-refreshes');
      expect(refreshRequest?.data, {'refreshCredential': 'old-refresh-token'});
      expect(restored?.accessToken, 'new-access-token');
      expect(
        client.dio.options.headers['Authorization'],
        'Bearer new-access-token',
      );
      expect(authStates, [true]);
      expect(await store.readRefreshCredential(), 'new-refresh-token');
    },
  );

  test('invalid refresh token clears session and reports expiration', () async {
    final store = _MemorySessionCredentialStore('old-refresh-token');
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
    expect(await store.readRefreshCredential(), isNull);
    expect(authStates, contains(false));
  });

  test('temporary refresh failure keeps the local session', () async {
    final store = _MemorySessionCredentialStore('old-refresh-token');
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

    expect(await store.readRefreshCredential(), 'old-refresh-token');
    expect(authStates, isEmpty);
  });

  test(
    'app login does not expose access token when secure storage write fails',
    () async {
      final dio = Dio();
      dio.httpClientAdapter = _CallbackAdapter(
        (_) => _jsonResponse({
          'success': true,
          'code': 'AUTHENTICATED',
          'message': 'Authentication success',
          'data': _newLoginResult.toJson(),
        }),
      );
      final client = ApiClient(config: _config, dio: dio);
      final authStates = <bool>[];
      final repository = AuthRepository(
        client,
        sessionStore: _FailingWriteSessionCredentialStore(),
        onAuthenticationChanged: authStates.add,
      );

      await expectLater(
        repository.login(
          email: 'member@example.test',
          password: 'synthetic-password',
        ),
        throwsA(isA<StateError>()),
      );

      expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
      expect(authStates, isEmpty);
    },
  );

  test(
    'web auth uses cookie transport headers and never sends refresh body',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio();
      dio.httpClientAdapter = _CallbackAdapter((options) {
        requests.add(options);
        return _jsonResponse({
          'success': true,
          'code': 'AUTHENTICATED',
          'message': 'Authentication success',
          'data': {
            'accessToken': 'web-access-token-${requests.length}',
            'tokenType': 'Bearer',
            'expiresIn': 600,
            'user': {
              'publicId': '00000000-0000-0000-0000-000000000001',
              'email': 'web.member@example.test',
              'userName': 'Web Member',
            },
          },
        });
      });
      final client = ApiClient(config: _config, dio: dio);
      final repository = AuthRepository(
        client,
        sessionStore: const WebCookieSessionCredentialStore(),
      );

      final loginResult = await repository.login(
        email: 'web.member@example.test',
        password: 'synthetic-password',
      );
      final restored = await repository.restoreSession();

      expect(loginResult.isAuthenticated, isTrue);
      expect(restored?.isAuthenticated, isTrue);
      expect(requests.map((request) => request.uri.path), [
        '/api/v1/auth/login',
        '/api/v1/auth/session-refreshes',
      ]);
      for (final request in requests) {
        expect(request.headers['X-Session-Transport'], 'COOKIE');
        expect(request.headers['X-CSRF-Protection'], '1');
        expect(request.extra['withCredentials'], isTrue);
      }
      expect(requests[1].data, isNull);
    },
  );

  test(
    'continuation response does not create an authenticated session',
    () async {
      const continuationCredential = 'synthetic-continuation-credential';
      final store = _MemorySessionCredentialStore();
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
      expect(await store.readRefreshCredential(), isNull);
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

  test('email login uses only the v1 verified email contract', () async {
    RequestOptions? request;
    final dio = Dio();
    dio.httpClientAdapter = _CallbackAdapter((options) {
      request = options;
      return _jsonResponse({
        'success': true,
        'code': 'AUTHENTICATED',
        'message': 'Login success',
        'data': {
          'accessToken': 'access-token',
          'refreshToken': 'refresh-token',
          'tokenType': 'Bearer',
          'expiresIn': 3600,
          'user': {
            'publicId': '00000000-0000-0000-0000-000000000001',
            'email': 'member@example.test',
            'userName': 'Member',
          },
        },
      });
    });
    final repository = AuthRepository(
      ApiClient(config: _config, dio: dio),
      sessionStore: _MemorySessionCredentialStore(),
    );

    final result = await repository.login(
      email: 'member@example.test',
      password: 'synthetic-password',
    );

    expect(request?.uri.path, '/api/v1/auth/login');
    expect(result.user?.publicId, '00000000-0000-0000-0000-000000000001');
    expect(result.user?.userId, isNull);
    expect(request?.data, {
      'email': 'member@example.test',
      'password': 'synthetic-password',
    });
    expect(
      (request?.data as Map<String, Object?>).containsKey('account'),
      false,
    );
  });

  test('Google linking uses v1 endpoints and a purpose-bound proof', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    dio.httpClientAdapter = _CallbackAdapter((options) {
      requests.add(options);
      return switch (options.uri.path) {
        '/api/v1/auth/google-logins' => _jsonResponse({
          'success': true,
          'code': 'GOOGLE_ACCOUNT_LINK_REQUIRED',
          'message': 'Explicit link required',
          'data': {'nextAction': 'LINK_GOOGLE_ACCOUNT', 'expiresIn': 0},
        }),
        '/api/v1/auth/reauthentications/password' => _jsonResponse({
          'success': true,
          'code': 'SESSION_REAUTHENTICATED',
          'message': 'Reauthentication success',
          'data': {
            'credential': 'synthetic-link-proof',
            'purpose': 'LOGIN_METHOD_LINK',
            'expiresIn': 300,
          },
        }),
        '/api/v1/auth/google-account-links' => _jsonResponse({
          'success': true,
          'code': 'GOOGLE_ACCOUNT_LINKED',
          'message': 'Google account linked',
          'data': {
            'linked': true,
            'currentSessionPreserved': true,
            'otherSessionsRevoked': true,
          },
        }),
        _ => throw StateError('Unexpected request: ${options.uri.path}'),
      };
    });
    final client = ApiClient(config: _config, dio: dio);
    client.setAccessToken('current-access-token');
    final repository = AuthRepository(
      client,
      sessionStore: const WebCookieSessionCredentialStore(),
    );

    final login = await repository.googleLogin(
      idToken: 'initial-google-id-token',
    );
    client.setAccessToken('current-access-token');
    final proof = await repository.reauthenticateForGoogleLink(
      password: 'synthetic-password',
    );
    await repository.linkGoogleAccount(
      idToken: 'fresh-google-id-token',
      reauthenticationCredential: proof.credential,
    );

    expect(login.requiresGoogleAccountLink, isTrue);
    expect(requests.map((request) => request.uri.path), [
      '/api/v1/auth/google-logins',
      '/api/v1/auth/reauthentications/password',
      '/api/v1/auth/google-account-links',
    ]);
    expect(requests[0].data, {'idToken': 'initial-google-id-token'});
    expect(requests[1].data, {
      'password': 'synthetic-password',
      'purpose': 'LOGIN_METHOD_LINK',
    });
    expect(requests[2].data, {
      'idToken': 'fresh-google-id-token',
      'confirmed': true,
    });
    expect(
      requests[2].headers['X-Reauthentication-Credential'],
      'synthetic-link-proof',
    );
    for (final request in requests) {
      expect(request.headers['X-Session-Transport'], 'COOKIE');
      expect(request.headers['X-CSRF-Protection'], '1');
      expect(request.extra['withCredentials'], isTrue);
    }
  });

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
      final repository = AuthRepository(
        ApiClient(config: _config, dio: dio),
        sessionStore: _MemorySessionCredentialStore(),
      );

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

const _newLoginResult = LoginResult(
  accessToken: 'new-access-token',
  refreshToken: 'new-refresh-token',
  tokenType: 'Bearer',
  expiresIn: 3600,
  user: _user,
);

const _user = AuthUser(
  publicId: '00000000-0000-0000-0000-000000000001',
  userId: 1,
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

class _MemorySessionCredentialStore implements SessionCredentialStore {
  _MemorySessionCredentialStore([this.refreshCredential]);

  String? refreshCredential;

  @override
  bool get usesCookieTransport => false;

  @override
  Future<void> saveRefreshCredential(String refreshCredential) async {
    this.refreshCredential = refreshCredential;
  }

  @override
  Future<String?> readRefreshCredential() async => refreshCredential;

  @override
  Future<void> clearRefreshCredential() async {
    refreshCredential = null;
  }
}

class _FailingWriteSessionCredentialStore
    extends _MemorySessionCredentialStore {
  @override
  Future<void> saveRefreshCredential(String refreshCredential) {
    throw StateError('Secure storage is unavailable');
  }
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
