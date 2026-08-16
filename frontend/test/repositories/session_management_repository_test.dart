import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:monsters/repositories/session_management_repository.dart';

void main() {
  test('lists only safe paged device metadata', () async {
    RequestOptions? captured;
    final dio = Dio();
    dio.httpClientAdapter = _CallbackAdapter((request) {
      captured = request;
      return _success({
        'items': [
          {
            'sessionId': 'session-current',
            'deviceType': 'ANDROID',
            'deviceSummary': 'Android App',
            'lastActivityAt': '2026-08-16T10:00:00',
            'current': true,
          },
        ],
        'page': 0,
        'size': 3,
        'totalItems': 1,
        'totalPages': 1,
      });
    });
    final repository = SessionManagementRepository(
      ApiClient(config: _config, dio: dio),
      sessionStore: _MemoryStore(),
    );

    final page = await repository.list(page: 0);

    expect(captured?.uri.path, '/api/v1/auth/sessions');
    expect(captured?.queryParameters, {'page': 0, 'size': 3});
    expect(page.items.single.current, isTrue);
    expect(page.items.single.deviceSummary, 'Android App');
  });

  test(
    'reauthenticates then revokes others without any refresh token',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio();
      dio.httpClientAdapter = _CallbackAdapter((request) {
        requests.add(request);
        if (request.uri.path.endsWith('/reauthentications/password')) {
          return _success({
            'credential': 'short-lived-credential',
            'purpose': 'SESSION_MANAGEMENT',
            'expiresIn': 300,
          });
        }
        return _success(null, code: 'OTHER_SESSIONS_REVOKED');
      });
      final repository = SessionManagementRepository(
        ApiClient(config: _config, dio: dio),
        sessionStore: _MemoryStore('must-not-be-sent'),
      );

      final credential = await repository.reauthenticate(
        password: 'synthetic-password',
      );
      await repository.revokeOthers(credential: credential.credential);

      expect(requests[0].data, {'password': 'synthetic-password'});
      expect(
        requests[1].headers['X-Reauthentication-Credential'],
        'short-lived-credential',
      );
      expect(requests[1].data, isNull);
      expect(requests.toString(), isNot(contains('must-not-be-sent')));
    },
  );

  test('web mutation uses cookie transport and CSRF proof', () async {
    RequestOptions? captured;
    final dio = Dio();
    dio.httpClientAdapter = _CallbackAdapter((request) {
      captured = request;
      return _success(null, code: 'CURRENT_SESSION_REVOKED');
    });
    final repository = SessionManagementRepository(
      ApiClient(config: _config, dio: dio),
      sessionStore: const WebCookieSessionCredentialStore(),
    );

    await repository.revokeCurrent();

    expect(captured?.headers['X-Session-Transport'], 'COOKIE');
    expect(captured?.headers['X-CSRF-Protection'], '1');
    expect(captured?.extra['withCredentials'], isTrue);
  });
}

const _config = AppConfig(
  apiBaseUrl: 'http://example.com/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

class _MemoryStore implements SessionCredentialStore {
  _MemoryStore([this.value]);

  String? value;

  @override
  bool get usesCookieTransport => false;

  @override
  Future<void> clearRefreshCredential() async => value = null;

  @override
  Future<String?> readRefreshCredential() async => value;

  @override
  Future<void> saveRefreshCredential(String refreshCredential) async {
    value = refreshCredential;
  }
}

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.callback);

  final ResponseBody Function(RequestOptions request) callback;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => callback(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _success(
  Object? data, {
  String code = 'DEVICE_SESSIONS_RETRIEVED',
}) {
  return ResponseBody.fromString(
    jsonEncode({'success': true, 'code': code, 'message': 'ok', 'data': data}),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
