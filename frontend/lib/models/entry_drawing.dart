import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EntryDrawingFile {
  const EntryDrawingFile({
    required this.file,
    required this.bytes,
    required this.name,
    this.mimeType = 'image/png',
    this.draftMediaId,
    this.downloadUrl,
    int? sizeBytes,
  }) : _sizeBytes = sizeBytes;

  factory EntryDrawingFile.fromDraft({
    required int draftMediaId,
    required String downloadUrl,
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) {
    return EntryDrawingFile(
      file: null,
      bytes: Uint8List(0),
      name: name,
      mimeType: mimeType,
      draftMediaId: draftMediaId,
      downloadUrl: downloadUrl,
      sizeBytes: sizeBytes,
    );
  }

  final XFile? file;
  final Uint8List bytes;
  final String name;
  final String mimeType;
  final int? draftMediaId;
  final String? downloadUrl;
  final int? _sizeBytes;

  int get sizeBytes => _sizeBytes ?? bytes.length;
  bool get isPersistedDraft => draftMediaId != null;

  EntryDrawingFile withDraftReference({
    required int draftMediaId,
    required String downloadUrl,
  }) {
    return EntryDrawingFile(
      file: file,
      bytes: bytes,
      name: name,
      mimeType: mimeType,
      draftMediaId: draftMediaId,
      downloadUrl: downloadUrl,
      sizeBytes: sizeBytes,
    );
  }
}

class EntryDrawingLimits {
  const EntryDrawingLimits._();

  static const int maxBytes = 5 * 1024 * 1024;
  static const int outputDimension = 1024;
  static const Set<String> mimeTypes = {'image/png', 'image/webp'};
}

class MoodDrawingStroke {
  const MoodDrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.isEraser,
  });

  final List<Offset> points;
  final Color color;
  final double width;
  final bool isEraser;
}
