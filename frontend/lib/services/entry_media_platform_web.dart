import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'entry_media_platform.dart';

EntryMediaPlatform createPlatform() => _WebEntryMediaPlatform();

class _WebEntryMediaPlatform implements EntryMediaPlatform {
  @override
  String createRecordingPath(String filePrefix) => '$filePrefix-recording.wav';

  @override
  Future<Duration?> loadAudio(AudioPlayer player, String path) {
    return player.setUrl(path);
  }

  @override
  VideoPlayerController createVideoController(String path) {
    return VideoPlayerController.networkUrl(Uri.parse(path));
  }
}
