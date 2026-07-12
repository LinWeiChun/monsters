import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/pages/annoyance_chat_page.dart';

void main() {
  testWidgets('uses structured selectors to reach the content step', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AnnoyanceChatPage())),
    );

    expect(find.byKey(const Key('annoyanceChatGreeting')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();

    for (final code in [
      'ACADEMIC',
      'CAREER',
      'LOVE',
      'FRIENDSHIP',
      'FAMILY',
      'OTHER',
    ]) {
      expect(find.byKey(Key('annoyanceCategory$code')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('annoyanceCategoryACADEMIC')));
    await tester.pumpAndSettle();

    expect(find.text('課業'), findsOneWidget);
    for (final method in ['TEXT', 'IMAGE', 'AUDIO', 'VIDEO']) {
      expect(find.byKey(Key('annoyanceRecordMethod$method')), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('annoyanceRecordMethodTEXT')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceContentPrompt')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceContentStep')), findsOneWidget);
    expect(find.text('慢慢來，接下來把想說的話寫下來就好。'), findsOneWidget);
  });

  testWidgets('back and restart actions rebuild the draft flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AnnoyanceChatPage())),
    );

    await tester.tap(find.byKey(const Key('annoyanceChatStartButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceCategoryCAREER')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('annoyanceChatBackButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceCategoryCAREER')), findsOneWidget);
    expect(find.byKey(const Key('annoyanceRecordMethodTEXT')), findsNothing);

    await tester.tap(find.byKey(const Key('annoyanceChatRestartButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);
    expect(find.text('事業'), findsNothing);
  });
}
