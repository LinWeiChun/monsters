import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/widgets/annoyance/mood_score_selector.dart';

void main() {
  testWidgets('shows neutral 1 to 5 options and reports the selected score', (
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
      expect(find.byKey(Key('annoyanceScore$score')), findsOneWidget);
      expect(find.text('$score分'), findsOneWidget);
    }

    expect(
      tester.widget<FilledButton>(find.byKey(const Key('annoyanceScore3'))),
      isA<FilledButton>(),
    );

    await tester.tap(find.byKey(const Key('annoyanceScore5')));
    expect(selectedScore, 5);
  });
}
