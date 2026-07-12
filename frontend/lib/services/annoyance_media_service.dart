import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';
import 'annoyance_media_platform.dart';
import 'annoyance_media_platform_factory.dart';
import 'annoyance_media_validator.dart';

abstract class AnnoyanceMediaService {
  Future<AnnoyanceMediaFile?> pickImage(AnnoyanceMediaOrigin origin);

  Future<AnnoyanceMediaFile?> pickVideo(AnnoyanceMediaOrigin origin);

  Future<void> startAudioRecording();

  Future<AnnoyanceMediaFile?> stopAudioRecording();

  Future<void> cancelAudioRecording();

  Future<void> dispose();
}

class DefaultAnnoyanceMediaService implements AnnoyanceMediaService {
  DefaultAnnoyanceMediaService({
    ImagePicker? imagePicker,
    AudioRecorder? audioRecorder,
    AnnoyanceMediaPlatform? platform,
    AnnoyanceMediaValidator validator = const AnnoyanceMediaValidator(),
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _audioRecorder = audioRecorder ?? AudioRecorder(),
       _platform = platform ?? createAnnoyanceMediaPlatform(),
       _validator = validator;

  final ImagePicker _imagePicker;
  final AudioRecorder _audioRecorder;
  final AnnoyanceMediaPlatform _platform;
  final AnnoyanceMediaValidator _validator;
  String? _recordingPath;

  @override
  Future<AnnoyanceMediaFile?> pickImage(AnnoyanceMediaOrigin origin) async {
    final file = await _imagePicker.pickImage(
      source: _toImageSource(origin),
      requestFullMetadata: false,
    );
    if (file == null) {
      return null;
    }
    return _prepareFile(AnnoyanceRecordMethod.image, file);
  }

  @override
  Future<AnnoyanceMediaFile?> pickVideo(AnnoyanceMediaOrigin origin) async {
    final file = await _imagePicker.pickVideo(
      source: _toImageSource(origin),
      maxDuration: AnnoyanceMediaLimits.videoMaxDuration,
    );
    if (file == null) {
      return null;
    }
    return _prepareFile(AnnoyanceRecordMethod.video, file);
  }

  @override
  Future<void> startAudioRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      throw const AnnoyanceMediaValidationException('需要麥克風權限才能錄音。');
    }
    if (!await _audioRecorder.isEncoderSupported(AudioEncoder.wav)) {
      throw const AnnoyanceMediaValidationException('此裝置不支援 WAV 錄音。');
    }
    _recordingPath = _platform.createRecordingPath();
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: _recordingPath!,
    );
  }

  @override
  Future<AnnoyanceMediaFile?> stopAudioRecording() async {
    final path = await _audioRecorder.stop();
    _recordingPath = null;
    if (path == null || path.isEmpty) {
      return null;
    }
    final file = XFile(
      path,
      name: 'annoyance-recording.wav',
      mimeType: 'audio/wav',
    );
    return _prepareFile(AnnoyanceRecordMethod.audio, file);
  }

  @override
  Future<void> cancelAudioRecording() async {
    await _audioRecorder.cancel();
    _recordingPath = null;
  }

  @override
  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }

  Future<AnnoyanceMediaFile> _prepareFile(
    AnnoyanceRecordMethod method,
    XFile file,
  ) async {
    final sizeBytes = await file.length();
    final mimeType = _validator.resolveMimeType(method, file);
    _validator.validateFile(method, file.name, mimeType, sizeBytes);
    final bytes =
        method == AnnoyanceRecordMethod.image
            ? await file.readAsBytes()
            : Uint8List(0);
    final duration = await _readDuration(method, file.path);
    _validator.validateDuration(method, duration);
    return AnnoyanceMediaFile(
      method: method,
      file: file,
      bytes: Uint8List.fromList(bytes),
      name: file.name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      duration: duration,
    );
  }

  Future<Duration?> _readDuration(
    AnnoyanceRecordMethod method,
    String path,
  ) async {
    if (method == AnnoyanceRecordMethod.audio) {
      final player = AudioPlayer();
      try {
        return await _platform.loadAudio(player, path);
      } finally {
        await player.dispose();
      }
    }
    if (method == AnnoyanceRecordMethod.video) {
      final controller = _platform.createVideoController(path);
      try {
        await controller.initialize();
        return controller.value.duration;
      } finally {
        await controller.dispose();
      }
    }
    return null;
  }

  ImageSource _toImageSource(AnnoyanceMediaOrigin origin) {
    return switch (origin) {
      AnnoyanceMediaOrigin.gallery => ImageSource.gallery,
      AnnoyanceMediaOrigin.camera => ImageSource.camera,
      AnnoyanceMediaOrigin.recorder =>
        throw ArgumentError.value(
          origin,
          'origin',
          'Recorder is not an image picker source',
        ),
    };
  }
}
