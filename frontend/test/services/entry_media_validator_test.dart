import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters/models/entry_media.dart';
import 'package:monsters/models/entry_record.dart';
import 'package:monsters/services/entry_media_validator.dart';

void main() {
  const validator = EntryMediaValidator();

  test('accepts API-compatible media MIME types and extensions', () {
    validator.validateFile(
      EntryRecordMethod.image,
      'photo.JPEG',
      'image/jpeg',
      EntryMediaLimits.imageMaxBytes,
    );
    validator.validateFile(
      EntryRecordMethod.audio,
      'voice.wav',
      'audio/wav',
      EntryMediaLimits.audioMaxBytes,
    );
    validator.validateFile(
      EntryRecordMethod.video,
      'clip.webm',
      'video/webm',
      EntryMediaLimits.videoMaxBytes,
    );
  });

  test('rejects mismatched extension, empty file, and oversized file', () {
    expect(
      () => validator.validateFile(
        EntryRecordMethod.image,
        'photo.gif',
        'image/png',
        100,
      ),
      throwsA(isA<EntryMediaValidationException>()),
    );
    expect(
      () => validator.validateFile(
        EntryRecordMethod.audio,
        'voice.wav',
        'audio/wav',
        0,
      ),
      throwsA(isA<EntryMediaValidationException>()),
    );
    expect(
      () => validator.validateFile(
        EntryRecordMethod.video,
        'clip.mp4',
        'video/mp4',
        EntryMediaLimits.videoMaxBytes + 1,
      ),
      throwsA(isA<EntryMediaValidationException>()),
    );
  });

  test('validates audio and video durations', () {
    validator.validateDuration(
      EntryRecordMethod.audio,
      EntryMediaLimits.audioMaxDuration,
    );
    validator.validateDuration(
      EntryRecordMethod.video,
      EntryMediaLimits.videoMaxDuration,
    );

    expect(
      () => validator.validateDuration(EntryRecordMethod.audio, null),
      throwsA(isA<EntryMediaValidationException>()),
    );
    expect(
      () => validator.validateDuration(
        EntryRecordMethod.video,
        EntryMediaLimits.videoMaxDuration + const Duration(seconds: 1),
      ),
      throwsA(isA<EntryMediaValidationException>()),
    );
  });

  test('infers MIME type from the selected method and extension', () {
    final audio = XFile('voice.m4a');
    final video = XFile('clip.mov');

    expect(
      validator.resolveMimeType(EntryRecordMethod.audio, audio),
      'audio/mp4',
    );
    expect(
      validator.resolveMimeType(EntryRecordMethod.video, video),
      'video/quicktime',
    );
  });
}
