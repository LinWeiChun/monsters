class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: fromJsonT == null ? json['data'] as T : fromJsonT(json['data']),
    );
  }

  final bool success;
  final String message;
  final T data;
}
