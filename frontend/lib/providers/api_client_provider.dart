import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_error_handler.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(appConfigProvider),
    errorHandler: ref.watch(apiErrorHandlerProvider),
  );
});

final apiErrorHandlerProvider = Provider<ApiErrorHandler>((ref) {
  return const ApiErrorHandler();
});
