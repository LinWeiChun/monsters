import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'annoyance_draft.dart';

enum AnnoyanceMediaOrigin { gallery, camera, recorder }

class AnnoyanceMediaFile {
  const AnnoyanceMediaFile({
    required this.method,
    required this.file,
    required this.bytes,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.duration,
  });

  final AnnoyanceRecordMethod method;
  final XFile file;
  final Uint8List bytes;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final Duration? duration;
}

class AnnoyanceMediaLimits {
  const AnnoyanceMediaLimits._();

  static const int imageMaxBytes = 5 * 1024 * 1024;
  static const int audioMaxBytes = 10 * 1024 * 1024;
  static const int videoMaxBytes = 50 * 1024 * 1024;
  static const Duration audioMaxDuration = Duration(minutes: 5);
  static const Duration videoMaxDuration = Duration(seconds: 60);

  static const Set<String> imageMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };
  static const Set<String> audioMimeTypes = {
    'audio/mp4',
    'audio/aac',
    'audio/mpeg',
    'audio/wav',
  };
  static const Set<String> videoMimeTypes = {
    'video/mp4',
    'video/quicktime',
    'video/webm',
  };
}

class AnnoyanceMediaValidationException implements Exception {
  const AnnoyanceMediaValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
