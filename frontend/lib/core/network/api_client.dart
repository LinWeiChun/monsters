import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import 'api_response.dart';

const _authorizationHeader = 'Authorization';

class ApiClient {
  ApiClient({
    required AppConfig config,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      responseType: ResponseType.json,
      headers: const {
        Headers.acceptHeader: Headers.jsonContentType,
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    );
  }

  final Dio _dio;

  Dio get dio => _dio;

  void setAccessToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove(_authorizationHeader);
      return;
    }

    _dio.options.headers[_authorizationHeader] = 'Bearer $token';
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJsonT,
    Options? options,
  }) {
    return _request<T>(
      () => _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJsonT,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJsonT,
    Options? options,
  }) {
    return _request<T>(
      () => _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJsonT,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJsonT,
    Options? options,
  }) {
    return _request<T>(
      () => _dio.put<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJsonT,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJsonT,
    Options? options,
  }) {
    return _request<T>(
      () => _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJsonT,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJsonT,
    Options? options,
  }) {
    return _request<T>(
      () => _dio.delete<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJsonT,
    );
  }

  Future<ApiResponse<T>> _request<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object? json)? fromJsonT,
  ) async {
    final response = await request();
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw const FormatException('Invalid API response format.');
    }

    return ApiResponse<T>.fromJson(body, fromJsonT);
  }
}
