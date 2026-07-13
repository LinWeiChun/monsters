import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'annoyance_media_platform.dart';

AnnoyanceMediaPlatform createPlatform() => _IoMediaPlatform();

class _IoMediaPlatform implements AnnoyanceMediaPlatform {
  @override
  String createRecordingPath() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '${Directory.systemTemp.path}/annoyance-$timestamp.wav';
  }

  @override
  Future<Duration?> loadAudio(AudioPlayer player, String path) {
    return player.setFilePath(path);
  }

  @override
  VideoPlayerController createVideoController(String path) {
    return VideoPlayerController.file(File(path));
  }
}
