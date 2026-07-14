import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

abstract class AnnoyanceMediaPlatform {
  String createRecordingPath();

  Future<Duration?> loadAudio(AudioPlayer player, String path);

  VideoPlayerController createVideoController(String path);
}
