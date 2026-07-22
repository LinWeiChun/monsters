import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../models/entry_media.dart';
import '../models/entry_record.dart';
import 'entry_media_platform.dart';
import 'entry_media_platform_factory.dart';
import 'entry_media_validator.dart';

abstract class EntryMediaService {
  Future<EntryMediaFile?> pickImage(EntryMediaOrigin origin);

  Future<EntryMediaFile?> pickVideo(EntryMediaOrigin origin);

  Future<void> startAudioRecording();

  Future<EntryMediaFile?> stopAudioRecording();

  Future<void> cancelAudioRecording();

  Future<void> dispose();
}

class DefaultEntryMediaService implements EntryMediaService {
  DefaultEntryMediaService({
    this.recordingFilePrefix = 'entry',
    ImagePicker? imagePicker,
    AudioRecorder? audioRecorder,
    EntryMediaPlatform? platform,
    EntryMediaValidator validator = const EntryMediaValidator(),
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _audioRecorder = audioRecorder ?? AudioRecorder(),
       _platform = platform ?? createEntryMediaPlatform(),
       _validator = validator;

  final String recordingFilePrefix;
  final ImagePicker _imagePicker;
  final AudioRecorder _audioRecorder;
  final EntryMediaPlatform _platform;
  final EntryMediaValidator _validator;
  String? _recordingPath;

  @override
  Future<EntryMediaFile?> pickImage(EntryMediaOrigin origin) async {
    final file = await _imagePicker.pickImage(
      source: _toImageSource(origin),
      requestFullMetadata: false,
    );
    if (file == null) {
      return null;
    }
    return _prepareFile(EntryRecordMethod.image, file);
  }

  @override
  Future<EntryMediaFile?> pickVideo(EntryMediaOrigin origin) async {
    final file = await _imagePicker.pickVideo(
      source: _toImageSource(origin),
      maxDuration: EntryMediaLimits.videoMaxDuration,
    );
    if (file == null) {
      return null;
    }
    return _prepareFile(EntryRecordMethod.video, file);
  }

  @override
  Future<void> startAudioRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      throw const EntryMediaValidationException('需要麥克風權限才能錄音。');
    }
    if (!await _audioRecorder.isEncoderSupported(AudioEncoder.wav)) {
      throw const EntryMediaValidationException('此裝置不支援 WAV 錄音。');
    }
    _recordingPath = _platform.createRecordingPath(recordingFilePrefix);
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
  Future<EntryMediaFile?> stopAudioRecording() async {
    final path = await _audioRecorder.stop();
    _recordingPath = null;
    if (path == null || path.isEmpty) {
      return null;
    }
    final file = XFile(
      path,
      name: '$recordingFilePrefix-recording.wav',
      mimeType: 'audio/wav',
    );
    return _prepareFile(EntryRecordMethod.audio, file);
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

  Future<EntryMediaFile> _prepareFile(
    EntryRecordMethod method,
    XFile file,
  ) async {
    final sizeBytes = await file.length();
    final mimeType = _validator.resolveMimeType(method, file);
    _validator.validateFile(method, file.name, mimeType, sizeBytes);
    final bytes =
        method == EntryRecordMethod.image
            ? await file.readAsBytes()
            : Uint8List(0);
    final duration = await _readDuration(method, file.path);
    _validator.validateDuration(method, duration);
    return EntryMediaFile(
      method: method,
      file: file,
      bytes: Uint8List.fromList(bytes),
      name: file.name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      duration: duration,
    );
  }

  Future<Duration?> _readDuration(EntryRecordMethod method, String path) async {
    if (method == EntryRecordMethod.audio) {
      final player = AudioPlayer();
      try {
        return await _platform.loadAudio(player, path);
      } finally {
        await player.dispose();
      }
    }
    if (method == EntryRecordMethod.video) {
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

  ImageSource _toImageSource(EntryMediaOrigin origin) {
    return switch (origin) {
      EntryMediaOrigin.gallery => ImageSource.gallery,
      EntryMediaOrigin.camera => ImageSource.camera,
      EntryMediaOrigin.recorder =>
        throw ArgumentError.value(
          origin,
          'origin',
          'Recorder is not an image picker source',
        ),
    };
  }
}
