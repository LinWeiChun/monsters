import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/core/network/api_error_handler.dart';
import 'package:monsters/core/network/api_error_type.dart';

void main() {
  group('ApiErrorHandler', () {
    const handler = ApiErrorHandler();

    test('maps backend error response message', () {
      final requestOptions = RequestOptions(path: '/users/me');
      final exception = DioException(
        requestOptions: requestOptions,
        response: Response<Object?>(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'success': false, 'message': 'Token expired.', 'data': null},
        ),
        type: DioExceptionType.badResponse,
      );

      final error = handler.fromDioException(exception);

      expect(error.type, ApiErrorType.unauthorized);
      expect(error.statusCode, 401);
      expect(error.message, 'Token expired.');
    });

    test('maps timeout exception', () {
      final error = handler.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/users/me'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(error.type, ApiErrorType.timeout);
      expect(error.statusCode, isNull);
    });

    test('maps network exception', () {
      final error = handler.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/users/me'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(error.type, ApiErrorType.network);
      expect(error.statusCode, isNull);
    });

    test('maps format exception', () {
      final error = handler.handle(
        const FormatException('Invalid API response format.'),
      );

      expect(error.type, ApiErrorType.unknown);
      expect(error.message, 'Invalid API response format.');
    });
  });
}
