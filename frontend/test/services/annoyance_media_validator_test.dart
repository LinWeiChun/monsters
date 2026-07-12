import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/models/annoyance_draft.dart';
import 'package:monsters/models/annoyance_media.dart';
import 'package:monsters/services/annoyance_media_validator.dart';

void main() {
  const validator = AnnoyanceMediaValidator();

  test('accepts API-compatible media MIME types and extensions', () {
    validator.validateFile(
      AnnoyanceRecordMethod.image,
      'photo.JPEG',
      'image/jpeg',
      AnnoyanceMediaLimits.imageMaxBytes,
    );
    validator.validateFile(
      AnnoyanceRecordMethod.audio,
      'voice.wav',
      'audio/wav',
      AnnoyanceMediaLimits.audioMaxBytes,
    );
    validator.validateFile(
      AnnoyanceRecordMethod.video,
      'clip.webm',
      'video/webm',
      AnnoyanceMediaLimits.videoMaxBytes,
    );
  });

  test('rejects mismatched extension, empty file, and oversized file', () {
    expect(
      () => validator.validateFile(
        AnnoyanceRecordMethod.image,
        'photo.gif',
        'image/png',
        100,
      ),
      throwsA(isA<AnnoyanceMediaValidationException>()),
    );
    expect(
      () => validator.validateFile(
        AnnoyanceRecordMethod.audio,
        'voice.wav',
        'audio/wav',
        0,
      ),
      throwsA(isA<AnnoyanceMediaValidationException>()),
    );
    expect(
      () => validator.validateFile(
        AnnoyanceRecordMethod.video,
        'clip.mp4',
        'video/mp4',
        AnnoyanceMediaLimits.videoMaxBytes + 1,
      ),
      throwsA(isA<AnnoyanceMediaValidationException>()),
    );
  });

  test('validates audio and video durations', () {
    validator.validateDuration(
      AnnoyanceRecordMethod.audio,
      AnnoyanceMediaLimits.audioMaxDuration,
    );
    validator.validateDuration(
      AnnoyanceRecordMethod.video,
      AnnoyanceMediaLimits.videoMaxDuration,
    );

    expect(
      () => validator.validateDuration(AnnoyanceRecordMethod.audio, null),
      throwsA(isA<AnnoyanceMediaValidationException>()),
    );
    expect(
      () => validator.validateDuration(
        AnnoyanceRecordMethod.video,
        AnnoyanceMediaLimits.videoMaxDuration + const Duration(seconds: 1),
      ),
      throwsA(isA<AnnoyanceMediaValidationException>()),
    );
  });

  test('infers MIME type from the selected method and extension', () {
    final audio = XFile('voice.m4a');
    final video = XFile('clip.mov');

    expect(
      validator.resolveMimeType(AnnoyanceRecordMethod.audio, audio),
      'audio/mp4',
    );
    expect(
      validator.resolveMimeType(AnnoyanceRecordMethod.video, video),
      'video/quicktime',
    );
  });
}
