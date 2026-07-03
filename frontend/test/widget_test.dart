import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows splash route on startup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonstersApp()));
    await tester.pumpAndSettle();

    expect(find.text('貘nsters'), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('註冊'), findsOneWidget);
  });

  testWidgets('navigates from splash to login route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonstersApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('登入'));
    await tester.pumpAndSettle();

    expect(find.text('前往首頁'), findsOneWidget);
  });
}
