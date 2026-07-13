import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
import 'package:monsters/theme/app_theme.dart';
import 'package:monsters/widgets/home/companion_hero.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: createAppRouter(initialLocation: AppPath.home),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: false),
              child: child!,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mobile home uses companion layout and bottom navigation', (
    tester,
  ) async {
    await pumpHome(tester, const Size(390, 844));

    expect(find.byKey(const Key('mobileCompanionHero')), findsOneWidget);
    expect(find.byKey(const Key('desktopCompanionHero')), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('記下現在的心情'), findsOneWidget);
  });

  testWidgets('desktop home uses independent sidebar layout', (tester) async {
    await pumpHome(tester, const Size(1440, 900));

    expect(find.byKey(const Key('desktopCompanionHero')), findsOneWidget);
    expect(find.byKey(const Key('mobileCompanionHero')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('陪你整理今天的心情'), findsOneWidget);
    expect(find.text('怪獸圖鑑'), findsOneWidget);
  });

  testWidgets('primary home action opens annoyance chat on desktop', (
    tester,
  ) async {
    await pumpHome(tester, const Size(1440, 900));

    await tester.tap(find.byKey(const Key('homeAnnoyanceChatButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);
  });

  testWidgets('tapping companion monster runs reaction animation', (
    tester,
  ) async {
    await pumpHome(tester, const Size(390, 844));

    await tester.tap(find.byKey(const Key('homeAnimatedMonster')));
    await tester.pump();

    expect(
      find.byKey(const Key('homeAnimatedMonsterReacting')),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeAnimatedMonsterIdle')), findsOneWidget);
  });

  testWidgets('reduced motion keeps companion monster static', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: CompanionHero(greetingName: '小林')),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('homeAnimatedMonster')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('homeAnimatedMonsterIdle')), findsOneWidget);
    expect(find.byKey(const Key('homeAnimatedMonsterReacting')), findsNothing);
  });
}
