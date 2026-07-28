import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/entry_media_service.dart';

final diaryMediaServiceProvider = Provider.autoDispose<EntryMediaService>((
  ref,
) {
  final service = DefaultEntryMediaService(recordingFilePrefix: 'diary');
  ref.onDispose(service.dispose);
  return service;
});
