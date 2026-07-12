import 'package:image_picker/image_picker.dart';

import '../models/annoyance_draft.dart';
import '../models/annoyance_media.dart';

class AnnoyanceMediaValidator {
  const AnnoyanceMediaValidator();

  void validateFile(
    AnnoyanceRecordMethod method,
    String name,
    String mimeType,
    int sizeBytes,
  ) {
    final allowedMimeTypes = switch (method) {
      AnnoyanceRecordMethod.image => AnnoyanceMediaLimits.imageMimeTypes,
      AnnoyanceRecordMethod.audio => AnnoyanceMediaLimits.audioMimeTypes,
      AnnoyanceRecordMethod.video => AnnoyanceMediaLimits.videoMimeTypes,
      AnnoyanceRecordMethod.text => const <String>{},
    };
    final allowedExtensions = switch (method) {
      AnnoyanceRecordMethod.image => const {'.jpg', '.jpeg', '.png', '.webp'},
      AnnoyanceRecordMethod.audio => const {
        '.m4a',
        '.mp4',
        '.aac',
        '.mp3',
        '.wav',
      },
      AnnoyanceRecordMethod.video => const {'.mp4', '.mov', '.webm'},
      AnnoyanceRecordMethod.text => const <String>{},
    };
    final extension = extensionOf(name);
    if (!allowedMimeTypes.contains(mimeType) ||
        !allowedExtensions.contains(extension)) {
      throw AnnoyanceMediaValidationException('${method.label}格式不支援，請重新選擇。');
    }
    final maximumBytes = switch (method) {
      AnnoyanceRecordMethod.image => AnnoyanceMediaLimits.imageMaxBytes,
      AnnoyanceRecordMethod.audio => AnnoyanceMediaLimits.audioMaxBytes,
      AnnoyanceRecordMethod.video => AnnoyanceMediaLimits.videoMaxBytes,
      AnnoyanceRecordMethod.text => 0,
    };
    if (sizeBytes <= 0) {
      throw const AnnoyanceMediaValidationException('檔案內容不可為空。');
    }
    if (sizeBytes > maximumBytes) {
      throw AnnoyanceMediaValidationException('${method.label}檔案超過大小限制。');
    }
  }

  void validateDuration(AnnoyanceRecordMethod method, Duration? duration) {
    final maximumDuration = switch (method) {
      AnnoyanceRecordMethod.audio => AnnoyanceMediaLimits.audioMaxDuration,
      AnnoyanceRecordMethod.video => AnnoyanceMediaLimits.videoMaxDuration,
      _ => null,
    };
    if (maximumDuration == null) {
      return;
    }
    if (duration == null || duration <= Duration.zero) {
      throw AnnoyanceMediaValidationException('${method.label}長度無法讀取。');
    }
    if (duration > maximumDuration) {
      throw AnnoyanceMediaValidationException('${method.label}超過長度限制。');
    }
  }

  String resolveMimeType(AnnoyanceRecordMethod method, XFile file) {
    final reported = file.mimeType?.toLowerCase().split(';').first.trim();
    if (reported != null && reported.isNotEmpty) {
      return reported;
    }
    final extension = extensionOf(file.name);
    return switch ((method, extension)) {
      (AnnoyanceRecordMethod.image, '.jpg' || '.jpeg') => 'image/jpeg',
      (AnnoyanceRecordMethod.image, '.png') => 'image/png',
      (AnnoyanceRecordMethod.image, '.webp') => 'image/webp',
      (AnnoyanceRecordMethod.audio, '.m4a' || '.mp4') => 'audio/mp4',
      (AnnoyanceRecordMethod.audio, '.aac') => 'audio/aac',
      (AnnoyanceRecordMethod.audio, '.mp3') => 'audio/mpeg',
      (AnnoyanceRecordMethod.audio, '.wav') => 'audio/wav',
      (AnnoyanceRecordMethod.video, '.mp4') => 'video/mp4',
      (AnnoyanceRecordMethod.video, '.mov') => 'video/quicktime',
      (AnnoyanceRecordMethod.video, '.webm') => 'video/webm',
      _ => '',
    };
  }

  String extensionOf(String name) {
    final normalized = name.toLowerCase();
    final dotIndex = normalized.lastIndexOf('.');
    return dotIndex < 0 ? '' : normalized.substring(dotIndex);
  }
}
