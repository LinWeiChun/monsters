import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'entry_record.dart';

enum EntryMediaOrigin { gallery, camera, recorder }

class EntryMediaFile {
  const EntryMediaFile({
    required this.method,
    required this.file,
    required this.bytes,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.duration,
    this.draftMediaId,
    this.downloadUrl,
  });

  factory EntryMediaFile.fromDraft({
    required EntryRecordMethod method,
    required int draftMediaId,
    required String downloadUrl,
    required String name,
    required String mimeType,
    required int sizeBytes,
    required Duration? duration,
  }) {
    return EntryMediaFile(
      method: method,
      file: null,
      bytes: Uint8List(0),
      name: name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      duration: duration,
      draftMediaId: draftMediaId,
      downloadUrl: downloadUrl,
    );
  }

  final EntryRecordMethod method;
  final XFile? file;
  final Uint8List bytes;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final Duration? duration;
  final int? draftMediaId;
  final String? downloadUrl;

  bool get isPersistedDraft => draftMediaId != null;

  EntryMediaFile withDraftReference({
    required int draftMediaId,
    required String downloadUrl,
  }) {
    return EntryMediaFile(
      method: method,
      file: file,
      bytes: bytes,
      name: name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      duration: duration,
      draftMediaId: draftMediaId,
      downloadUrl: downloadUrl,
    );
  }
}

class EntryMediaLimits {
  const EntryMediaLimits._();

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

class EntryMediaValidationException implements Exception {
  const EntryMediaValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
