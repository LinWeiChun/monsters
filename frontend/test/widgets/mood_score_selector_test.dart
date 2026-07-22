import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/widgets/entry/mood_score_selector.dart';

void main() {
  testWidgets('shows 1 to 5 image options and reports the selected score', (
    tester,
  ) async {
    int? selectedScore;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodScoreSelector(
            selectedScore: 3,
            onSelected: (score) => selectedScore = score,
          ),
        ),
      ),
    );

    for (var score = 1; score <= 5; score += 1) {
      expect(find.byKey(Key('entryScore$score')), findsOneWidget);
      expect(find.byKey(Key('entryScoreImage$score')), findsOneWidget);
      expect(find.text('$score分'), findsOneWidget);
    }

    expect(find.byKey(const Key('entryScoreSelected3')), findsOneWidget);

    await tester.tap(find.byKey(const Key('entryScore5')));
    expect(selectedScore, 5);
  });

  testWidgets('image score choices wrap without overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodScoreSelector(selectedScore: 1, onSelected: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('entryScoreImage1')), findsOneWidget);
    expect(find.byKey(const Key('entryScoreImage5')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
