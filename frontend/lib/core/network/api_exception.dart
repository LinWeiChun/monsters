import 'api_error_type.dart';

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' statusCode: $statusCode,';
    return 'ApiException(type: $type,$status message: $message)';
  }
}
