import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/widgets/entry/share_choice_card.dart';

void main() {
  testWidgets('shows private and public share options', (tester) async {
    bool? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShareChoiceCard(
            selectedValue: false,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('entryShareChoiceCard')), findsOneWidget);
    expect(find.byKey(const Key('entrySharePrivateButton')), findsOneWidget);
    expect(find.byKey(const Key('entrySharePublicButton')), findsOneWidget);
    expect(find.text('保持私人'), findsOneWidget);
    expect(find.text('分享到社群'), findsOneWidget);

    await tester.tap(find.byKey(const Key('entrySharePublicButton')));
    expect(selectedValue, isTrue);

    await tester.tap(find.byKey(const Key('entrySharePrivateButton')));
    expect(selectedValue, isFalse);
  });
}
