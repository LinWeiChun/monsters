import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'annoyance_media_platform.dart';

AnnoyanceMediaPlatform createPlatform() => _UnsupportedMediaPlatform();

class _UnsupportedMediaPlatform implements AnnoyanceMediaPlatform {
  @override
  String createRecordingPath() => 'annoyance-recording.wav';

  @override
  Future<Duration?> loadAudio(AudioPlayer player, String path) {
    throw UnsupportedError('Audio preview is unavailable on this platform');
  }

  @override
  VideoPlayerController createVideoController(String path) {
    throw UnsupportedError('Video preview is unavailable on this platform');
  }
}
