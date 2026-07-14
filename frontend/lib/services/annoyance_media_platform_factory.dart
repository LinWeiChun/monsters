import 'annoyance_media_platform.dart';
import 'annoyance_media_platform_stub.dart'
    if (dart.library.io) 'annoyance_media_platform_io.dart'
    if (dart.library.html) 'annoyance_media_platform_web.dart';

AnnoyanceMediaPlatform createAnnoyanceMediaPlatform() {
  return createPlatform();
}
