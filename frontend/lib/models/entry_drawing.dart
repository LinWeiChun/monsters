import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EntryDrawingFile {
  const EntryDrawingFile({
    required this.file,
    required this.bytes,
    required this.name,
    this.mimeType = 'image/png',
  });

  final XFile file;
  final Uint8List bytes;
  final String name;
  final String mimeType;

  int get sizeBytes => bytes.length;
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
