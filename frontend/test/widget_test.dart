import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows login after the startup session check', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonstersApp()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(find.byKey(const Key('loginPasswordField')), findsOneWidget);
  });

  testWidgets('navigates from login to register route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonstersApp()));
    await tester.pumpAndSettle();

    final registerLink = find.text('建立新帳號');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerAccountField')), findsOneWidget);
    expect(find.byKey(const Key('registerEmailField')), findsOneWidget);
  });
}
