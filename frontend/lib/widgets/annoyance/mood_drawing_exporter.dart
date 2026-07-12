import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/annoyance_drawing.dart';
import 'mood_drawing_painter.dart';

class MoodDrawingExporter {
  const MoodDrawingExporter._();

  static Future<Uint8List> renderPng(List<MoodDrawingStroke> strokes) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const dimension = AnnoyanceDrawingLimits.outputDimension;
    final size = Size.square(dimension.toDouble());
    MoodDrawingPainter(strokes: strokes).paint(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(dimension, dimension);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw const FormatException('無法產生 PNG 心情圖。');
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }
}
