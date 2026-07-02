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
