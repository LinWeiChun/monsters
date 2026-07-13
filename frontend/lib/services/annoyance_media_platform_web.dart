import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'annoyance_media_platform.dart';

AnnoyanceMediaPlatform createPlatform() => _WebMediaPlatform();

class _WebMediaPlatform implements AnnoyanceMediaPlatform {
  @override
  String createRecordingPath() => 'annoyance-recording.wav';

  @override
  Future<Duration?> loadAudio(AudioPlayer player, String path) {
    return player.setUrl(path);
  }

  @override
  VideoPlayerController createVideoController(String path) {
    return VideoPlayerController.networkUrl(Uri.parse(path));
  }
}
