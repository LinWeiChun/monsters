import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('supports home initial route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('homeAnnoyanceChatButton')), findsOneWidget);
  });

  testWidgets('register route can navigate to login route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.register),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final loginLink = find.text('返回登入');
    await tester.ensureVisible(loginLink);
    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
  });

  testWidgets('supports annoyance chat route and home entry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final startButton = find.byKey(const Key('homeAnnoyanceChatButton'));
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.text('新增煩惱'), findsOneWidget);
    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);
  });
}
