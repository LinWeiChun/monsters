import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import 'entry_media_platform.dart';

EntryMediaPlatform createPlatform() => _IoEntryMediaPlatform();

class _IoEntryMediaPlatform implements EntryMediaPlatform {
  @override
  String createRecordingPath(String filePrefix) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '${Directory.systemTemp.path}/$filePrefix-$timestamp.wav';
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
