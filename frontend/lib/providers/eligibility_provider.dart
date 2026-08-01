import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/eligibility_repository.dart';
import 'api_client_provider.dart';

final eligibilityRepositoryProvider = Provider<EligibilityRepository>(
  (ref) => EligibilityRepository(ref.watch(apiClientProvider)),
);
