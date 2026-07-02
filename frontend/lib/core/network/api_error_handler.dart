import 'package:dio/dio.dart';

import 'api_error_type.dart';
import 'api_exception.dart';

class ApiErrorHandler {
  const ApiErrorHandler();

  ApiException handle(Object error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      return fromDioException(error);
    }

    if (error is FormatException) {
      return ApiException(
        type: ApiErrorType.unknown,
        message: 'Invalid API response format.',
        cause: error,
      );
    }

    return ApiException(
      type: ApiErrorType.unknown,
      message: 'Unexpected error.',
      cause: error,
    );
  }

  ApiException fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          type: ApiErrorType.timeout,
          message: 'Request timed out.',
          cause: exception,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          type: ApiErrorType.network,
          message: 'Network connection failed.',
          cause: exception,
        );
      case DioExceptionType.cancel:
        return ApiException(
          type: ApiErrorType.cancelled,
          message: 'Request was cancelled.',
          cause: exception,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(exception);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          type: ApiErrorType.unknown,
          message:
              _messageFromResponse(exception.response) ?? 'Unexpected error.',
          statusCode: exception.response?.statusCode,
          cause: exception,
        );
    }
  }

  ApiException _fromResponse(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final type = _typeFromStatusCode(statusCode);

    return ApiException(
      type: type,
      message: _messageFromResponse(response) ?? _defaultMessage(type),
      statusCode: statusCode,
      cause: exception,
    );
  }

  ApiErrorType _typeFromStatusCode(int? statusCode) {
    if (statusCode == null) {
      return ApiErrorType.unknown;
    }

    if (statusCode >= 500) {
      return ApiErrorType.server;
    }

    return switch (statusCode) {
      400 => ApiErrorType.validation,
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      409 => ApiErrorType.conflict,
      _ => ApiErrorType.unknown,
    };
  }

  String? _messageFromResponse(Response<Object?>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return null;
  }

  String _defaultMessage(ApiErrorType type) {
    return switch (type) {
      ApiErrorType.network => 'Network connection failed.',
      ApiErrorType.timeout => 'Request timed out.',
      ApiErrorType.unauthorized => 'Authentication is required.',
      ApiErrorType.forbidden => 'Permission denied.',
      ApiErrorType.notFound => 'Resource not found.',
      ApiErrorType.conflict => 'Resource conflict.',
      ApiErrorType.validation => 'Invalid request.',
      ApiErrorType.server => 'Server error.',
      ApiErrorType.cancelled => 'Request was cancelled.',
      ApiErrorType.unknown => 'Unexpected error.',
    };
  }
}
