import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/theme/app_theme.dart';
import 'package:monsters/widgets/state/empty_view.dart';
import 'package:monsters/widgets/state/error_view.dart';
import 'package:monsters/widgets/state/loading_view.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));
}

void main() {
  testWidgets('LoadingView shows progress indicator and message', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const LoadingView(message: '資料載入中')));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('資料載入中'), findsOneWidget);
  });

  testWidgets('ErrorView shows message and retry action', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      buildTestApp(
        ErrorView(
          title: '載入失敗',
          message: '請稍後再試',
          onRetry: () => retryCount += 1,
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('載入失敗'), findsOneWidget);
    expect(find.text('請稍後再試'), findsOneWidget);

    await tester.tap(find.text('重試'));
    expect(retryCount, 1);
  });

  testWidgets('EmptyView shows empty state and optional action', (
    tester,
  ) async {
    var actionCount = 0;

    await tester.pumpWidget(
      buildTestApp(
        EmptyView(
          title: '沒有紀錄',
          message: '新增第一筆資料',
          actionLabel: '新增',
          onAction: () => actionCount += 1,
        ),
      ),
    );

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('沒有紀錄'), findsOneWidget);
    expect(find.text('新增第一筆資料'), findsOneWidget);

    await tester.tap(find.text('新增'));
    expect(actionCount, 1);
  });
}
