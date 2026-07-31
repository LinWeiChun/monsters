import 'api_error_type.dart';

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.code,
    this.fieldErrors = const {},
    this.retryAfter,
    this.cause,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, String> fieldErrors;
  final int? retryAfter;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' statusCode: $statusCode,';
    return 'ApiException(type: $type,$status message: $message)';
  }
}
