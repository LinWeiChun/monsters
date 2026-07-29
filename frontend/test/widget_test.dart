import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/app.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
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

  testWidgets('authentication expiration redirects protected pages to login', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppPath.home);
    final container = ProviderContainer(
      overrides: [appRouterProvider.overrideWithValue(router)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MonstersApp(),
      ),
    );
    await tester.pumpAndSettle();

    container.read(authSessionExpiredProvider.notifier).state = true;
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

    expect(find.byKey(const Key('registerAccountField')), findsNothing);
    expect(find.byKey(const Key('registerEmailField')), findsOneWidget);
  });
}
