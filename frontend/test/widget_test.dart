import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows splash route on startup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonstersApp()));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('註冊'), findsOneWidget);
  });

  testWidgets('navigates from splash to login route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonstersApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('登入'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(find.byKey(const Key('loginPasswordField')), findsOneWidget);
  });
}
