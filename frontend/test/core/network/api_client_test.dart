import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';

const _authorizationHeader = 'Authorization';

void main() {
  group('ApiClient', () {
    test('sets base options from config', () {
      final dio = Dio();
      ApiClient(config: _config(), dio: dio);

      expect(dio.options.baseUrl, 'http://example.com/api');
      expect(dio.options.connectTimeout, const Duration(seconds: 1));
      expect(dio.options.receiveTimeout, const Duration(seconds: 2));
      expect(dio.options.sendTimeout, const Duration(seconds: 3));
    });

    test('adds and removes bearer token', () {
      final client = ApiClient(config: _config(), dio: Dio());

      client.setAccessToken('token');
      expect(client.dio.options.headers[_authorizationHeader], 'Bearer token');

      client.setAccessToken(null);
      expect(
        client.dio.options.headers.containsKey(_authorizationHeader),
        isFalse,
      );
    });

    test('parses standard api response', () async {
      final dio = Dio();
      dio.httpClientAdapter = _JsonAdapter({
        'success': true,
        'message': 'ok',
        'data': {'id': 1},
      });
      final client = ApiClient(config: _config(), dio: dio);

      final response = await client.get<Map<String, dynamic>>(
        '/users/me',
        fromJsonT: (json) => json! as Map<String, dynamic>,
      );

      expect(response.success, isTrue);
      expect(response.message, 'ok');
      expect(response.data['id'], 1);
    });

    test('throws api exception for invalid response format', () async {
      final dio = Dio();
      dio.httpClientAdapter = _RawAdapter('[]');
      final client = ApiClient(config: _config(), dio: dio);

      expect(
        client.get<void>('/users/me'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiErrorType.unknown)
              .having(
                (error) => error.message,
                'message',
                'Invalid API response format.',
              ),
        ),
      );
    });

    test('throws api exception for backend error response', () async {
      final dio = Dio();
      dio.httpClientAdapter = _JsonAdapter({
        'success': false,
        'message': 'Token expired.',
        'data': null,
      }, statusCode: 401);
      final client = ApiClient(config: _config(), dio: dio);

      expect(
        client.get<void>('/users/me'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiErrorType.unauthorized)
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'Token expired.'),
        ),
      );
    });

    test('refreshes once and retries an unauthorized request', () async {
      final dio = Dio();
      var requestCount = 0;
      var refreshCount = 0;
      final authorizationHeaders = <Object?>[];
      dio.httpClientAdapter = _CallbackAdapter((options) {
        requestCount++;
        authorizationHeaders.add(options.headers[_authorizationHeader]);
        if (requestCount == 1) {
          return _jsonResponse({
            'success': false,
            'message': 'Token expired',
            'data': null,
          }, statusCode: 401);
        }
        return _jsonResponse({
          'success': true,
          'message': 'ok',
          'data': {'id': 1},
        });
      });
      final client = ApiClient(config: _config(), dio: dio);
      client.setAccessToken('expired-token');
      client.setAccessTokenRefresher(() async {
        refreshCount++;
        client.setAccessToken('new-token');
        return 'new-token';
      });

      final response = await client.get<Map<String, dynamic>>(
        '/users/me',
        fromJsonT: (json) => json! as Map<String, dynamic>,
      );

      expect(response.data['id'], 1);
      expect(refreshCount, 1);
      expect(requestCount, 2);
      expect(authorizationHeaders, [
        'Bearer expired-token',
        'Bearer new-token',
      ]);
    });

    test('does not refresh when unauthorized retry is disabled', () async {
      final dio = Dio();
      var refreshCount = 0;
      dio.httpClientAdapter = _JsonAdapter({
        'success': false,
        'message': 'Invalid refresh token',
        'data': null,
      }, statusCode: 401);
      final client = ApiClient(config: _config(), dio: dio);
      client.setAccessTokenRefresher(() async {
        refreshCount++;
        return 'new-token';
      });

      await expectLater(
        client.post<void>('/auth/refresh', retryOnUnauthorized: false),
        throwsA(isA<ApiException>()),
      );
      expect(refreshCount, 0);
    });

    test('retries each unauthorized request at most once', () async {
      final dio = Dio();
      var requestCount = 0;
      var refreshCount = 0;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        requestCount++;
        return _jsonResponse({
          'success': false,
          'message': 'Session remains invalid',
          'data': null,
        }, statusCode: 401);
      });
      final client = ApiClient(config: _config(), dio: dio);
      client.setAccessTokenRefresher(() async {
        refreshCount++;
        return 'new-token';
      });

      await expectLater(
        client.get<void>('/users/me'),
        throwsA(isA<ApiException>()),
      );

      expect(refreshCount, 1);
      expect(requestCount, 2);
    });

    test(
      'shares one refresh request across concurrent 401 responses',
      () async {
        final dio = Dio();
        var requestCount = 0;
        var refreshCount = 0;
        final refreshCompleter = Completer<String?>();
        dio.httpClientAdapter = _CallbackAdapter((options) {
          requestCount++;
          if (requestCount <= 2) {
            return _jsonResponse({
              'success': false,
              'message': 'Token expired',
              'data': null,
            }, statusCode: 401);
          }
          return _jsonResponse({
            'success': true,
            'message': 'ok',
            'data': {'id': requestCount},
          });
        });
        final client = ApiClient(config: _config(), dio: dio);
        client.setAccessToken('expired-token');
        client.setAccessTokenRefresher(() {
          refreshCount++;
          return refreshCompleter.future;
        });

        final first = client.get<Map<String, dynamic>>(
          '/users/me',
          fromJsonT: (json) => json! as Map<String, dynamic>,
        );
        final second = client.get<Map<String, dynamic>>(
          '/users/me',
          fromJsonT: (json) => json! as Map<String, dynamic>,
        );
        while (requestCount < 2) {
          await Future<void>.delayed(Duration.zero);
        }
        await Future<void>.delayed(Duration.zero);
        expect(refreshCount, 1);
        client.setAccessToken('new-token');
        refreshCompleter.complete('new-token');

        final responses = await Future.wait([first, second]);

        expect(responses, hasLength(2));
        expect(refreshCount, 1);
        expect(requestCount, 4);
      },
    );
  });
}

AppConfig _config() {
  return const AppConfig(
    apiBaseUrl: 'http://example.com/api',
    connectTimeout: Duration(seconds: 1),
    receiveTimeout: Duration(seconds: 2),
    sendTimeout: Duration(seconds: 3),
  );
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.body, {this.statusCode = 200});

  final Map<String, Object?> body;
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _RawAdapter implements HttpClientAdapter {
  _RawAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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
