import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/models/annoyance_drawing.dart';
import 'package:monsters/widgets/annoyance/mood_drawing_canvas.dart';

void main() {
  testWidgets('supports drawing, undo, clear, and PNG completion', (
    tester,
  ) async {
    AnnoyanceDrawingFile? completedDrawing;
    var cancelCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodDrawingCanvas(
            onCompleted: (drawing) => completedDrawing = drawing,
            onCancel: () => cancelCount += 1,
            exportPng: (_) async => Uint8List.fromList([1, 2, 3]),
          ),
        ),
      ),
    );

    final canvas = find.byKey(const Key('moodDrawingGestureArea'));
    final doneButton = find.byKey(const Key('moodDrawingDoneButton'));
    expect(tester.widget<FilledButton>(doneButton).onPressed, isNull);

    await tester.drag(canvas, const Offset(80, 50));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('moodDrawingUndoButton')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('moodDrawingUndoButton')));
    await tester.pump();
    expect(tester.widget<FilledButton>(doneButton).onPressed, isNull);

    await tester.drag(canvas, const Offset(60, 40));
    await tester.pump();
    await tester.tap(find.byKey(const Key('moodDrawingClearButton')));
    await tester.pump();
    expect(tester.widget<FilledButton>(doneButton).onPressed, isNull);

    await tester.tap(find.byKey(const Key('moodDrawingColor4')));
    await tester.tap(find.byKey(const Key('moodDrawingEraserButton')));
    await tester.drag(canvas, const Offset(90, 30));
    await tester.pump();
    await tester.tap(doneButton);
    await tester.pumpAndSettle();

    expect(completedDrawing, isNotNull);
    expect(completedDrawing!.mimeType, 'image/png');
    expect(completedDrawing!.sizeBytes, greaterThan(0));
    expect(
      completedDrawing!.sizeBytes,
      lessThanOrEqualTo(AnnoyanceDrawingLimits.maxBytes),
    );

    await tester.tap(find.byKey(const Key('moodDrawingCancelButton')));
    expect(cancelCount, 1);
  });
}
