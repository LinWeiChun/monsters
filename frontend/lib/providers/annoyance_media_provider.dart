import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/entry_media_service.dart';

final annoyanceMediaServiceProvider = Provider.autoDispose<EntryMediaService>((
  ref,
) {
  final service = DefaultEntryMediaService(recordingFilePrefix: 'annoyance');
  ref.onDispose(service.dispose);
  return service;
});
