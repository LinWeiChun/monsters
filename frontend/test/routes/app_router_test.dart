import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('supports home initial route', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: AppPath.home),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('首頁'), findsWidgets);
  });

  testWidgets('register route can navigate to login route', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: AppPath.register),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('已有帳號'));
    await tester.pumpAndSettle();

    expect(find.text('前往首頁'), findsOneWidget);
  });
}
