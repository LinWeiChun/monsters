import 'package:image_picker/image_picker.dart';

import '../models/entry_media.dart';
import '../models/entry_record.dart';

class EntryMediaValidator {
  const EntryMediaValidator();

  void validateFile(
    EntryRecordMethod method,
    String name,
    String mimeType,
    int sizeBytes,
  ) {
    final allowedMimeTypes = switch (method) {
      EntryRecordMethod.image => EntryMediaLimits.imageMimeTypes,
      EntryRecordMethod.audio => EntryMediaLimits.audioMimeTypes,
      EntryRecordMethod.video => EntryMediaLimits.videoMimeTypes,
      EntryRecordMethod.text => const <String>{},
    };
    final allowedExtensions = switch (method) {
      EntryRecordMethod.image => const {'.jpg', '.jpeg', '.png', '.webp'},
      EntryRecordMethod.audio => const {'.m4a', '.mp4', '.aac', '.mp3', '.wav'},
      EntryRecordMethod.video => const {'.mp4', '.mov', '.webm'},
      EntryRecordMethod.text => const <String>{},
    };
    final extension = extensionOf(name);
    if (!allowedMimeTypes.contains(mimeType) ||
        !allowedExtensions.contains(extension)) {
      throw EntryMediaValidationException('${method.label}格式不支援，請重新選擇。');
    }
    final maximumBytes = switch (method) {
      EntryRecordMethod.image => EntryMediaLimits.imageMaxBytes,
      EntryRecordMethod.audio => EntryMediaLimits.audioMaxBytes,
      EntryRecordMethod.video => EntryMediaLimits.videoMaxBytes,
      EntryRecordMethod.text => 0,
    };
    if (sizeBytes <= 0) {
      throw const EntryMediaValidationException('檔案內容不可為空。');
    }
    if (sizeBytes > maximumBytes) {
      throw EntryMediaValidationException('${method.label}檔案超過大小限制。');
    }
  }

  void validateDuration(EntryRecordMethod method, Duration? duration) {
    final maximumDuration = switch (method) {
      EntryRecordMethod.audio => EntryMediaLimits.audioMaxDuration,
      EntryRecordMethod.video => EntryMediaLimits.videoMaxDuration,
      _ => null,
    };
    if (maximumDuration == null) {
      return;
    }
    if (duration == null || duration <= Duration.zero) {
      throw EntryMediaValidationException('${method.label}長度無法讀取。');
    }
    if (duration > maximumDuration) {
      throw EntryMediaValidationException('${method.label}超過長度限制。');
    }
  }

  String resolveMimeType(EntryRecordMethod method, XFile file) {
    final reported = file.mimeType?.toLowerCase().split(';').first.trim();
    if (reported != null && reported.isNotEmpty) {
      return reported;
    }
    final extension = extensionOf(file.name);
    return switch ((method, extension)) {
      (EntryRecordMethod.image, '.jpg' || '.jpeg') => 'image/jpeg',
      (EntryRecordMethod.image, '.png') => 'image/png',
      (EntryRecordMethod.image, '.webp') => 'image/webp',
      (EntryRecordMethod.audio, '.m4a' || '.mp4') => 'audio/mp4',
      (EntryRecordMethod.audio, '.aac') => 'audio/aac',
      (EntryRecordMethod.audio, '.mp3') => 'audio/mpeg',
      (EntryRecordMethod.audio, '.wav') => 'audio/wav',
      (EntryRecordMethod.video, '.mp4') => 'video/mp4',
      (EntryRecordMethod.video, '.mov') => 'video/quicktime',
      (EntryRecordMethod.video, '.webm') => 'video/webm',
      _ => '',
    };
  }

  String extensionOf(String name) {
    final normalized = name.toLowerCase();
    final dotIndex = normalized.lastIndexOf('.');
    return dotIndex < 0 ? '' : normalized.substring(dotIndex);
  }
}
