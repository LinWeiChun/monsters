import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/annoyance_media_service.dart';

final annoyanceMediaServiceProvider =
    Provider.autoDispose<AnnoyanceMediaService>((ref) {
      final service = DefaultAnnoyanceMediaService();
      ref.onDispose(service.dispose);
      return service;
    });
