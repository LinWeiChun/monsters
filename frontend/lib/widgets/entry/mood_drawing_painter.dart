import 'package:flutter/material.dart';

import '../../models/entry_drawing.dart';

class MoodDrawingPainter extends CustomPainter {
  const MoodDrawingPainter({required this.strokes});

  static const double referenceCanvasSize = 360;
  static const Color backgroundColor = Colors.white;

  final List<MoodDrawingStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) {
        continue;
      }
      final paint =
          Paint()
            ..color = stroke.isEraser ? backgroundColor : stroke.color
            ..strokeWidth =
                stroke.width * size.shortestSide / referenceCanvasSize
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true;
      final scaledPoints = stroke.points
          .map((point) => Offset(point.dx * size.width, point.dy * size.height))
          .toList(growable: false);
      if (scaledPoints.length == 1) {
        canvas.drawCircle(
          scaledPoints.first,
          paint.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()..moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
      for (var index = 1; index < scaledPoints.length; index += 1) {
        final previous = scaledPoints[index - 1];
        final current = scaledPoints[index];
        final midpoint = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2,
        );
        path.quadraticBezierTo(
          previous.dx,
          previous.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }
      path.lineTo(scaledPoints.last.dx, scaledPoints.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MoodDrawingPainter oldDelegate) => true;
}
