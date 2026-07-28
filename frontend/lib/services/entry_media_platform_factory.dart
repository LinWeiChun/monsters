import 'entry_media_platform.dart';
import 'entry_media_platform_stub.dart'
    if (dart.library.io) 'entry_media_platform_io.dart'
    if (dart.library.html) 'entry_media_platform_web.dart';

EntryMediaPlatform createEntryMediaPlatform() {
  return createPlatform();
}
