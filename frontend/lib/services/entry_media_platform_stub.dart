import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'entry_media_platform.dart';

EntryMediaPlatform createPlatform() => _UnsupportedEntryMediaPlatform();

class _UnsupportedEntryMediaPlatform implements EntryMediaPlatform {
  @override
  String createRecordingPath(String filePrefix) => '$filePrefix-recording.wav';

  @override
  Future<Duration?> loadAudio(AudioPlayer player, String path) {
    throw UnsupportedError('Audio preview is unavailable on this platform');
  }

  @override
  VideoPlayerController createVideoController(String path) {
    throw UnsupportedError('Video preview is unavailable on this platform');
  }
}
