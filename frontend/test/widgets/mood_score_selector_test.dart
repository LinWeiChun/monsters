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
            keyPrefix: 'diary',
            semanticLabel: '今日心情分數，1 到 5 分',
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '今日心情分數，1 到 5 分',
      ),
      findsOneWidget,
    );

    for (var score = 1; score <= 5; score += 1) {
      expect(find.byKey(Key('diaryScore$score')), findsOneWidget);
      expect(find.byKey(Key('diaryScoreImage$score')), findsOneWidget);
      expect(find.text('$score分'), findsOneWidget);
    }

    expect(find.byKey(const Key('diaryScoreSelected3')), findsOneWidget);

    await tester.tap(find.byKey(const Key('diaryScore5')));
    expect(selectedScore, 5);
  });

  testWidgets('reports one-based boundary scores without index conversion', (
    tester,
  ) async {
    final selectedScores = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodScoreSelector(
            selectedScore: null,
            onSelected: selectedScores.add,
            keyPrefix: 'diaryBoundary',
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('diaryBoundaryScore1')));
    await tester.tap(find.byKey(const Key('diaryBoundaryScore5')));

    expect(selectedScores, <int>[1, 5]);
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
