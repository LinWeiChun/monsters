import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
import 'package:monsters/theme/app_theme.dart';

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

  testWidgets('mobile home matches Penpot companion layout', (tester) async {
    await pumpHome(tester, const Size(390, 844));

    expect(find.byKey(const Key('mobileCompanionHero')), findsOneWidget);
    expect(find.byKey(const Key('desktopCompanionHero')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('你，我在這裡。'), findsOneWidget);
    expect(find.text('我的怪獸'), findsOneWidget);
    expect(find.text('記下現在的心情'), findsOneWidget);
    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('社群'), findsOneWidget);
    expect(find.text('怪獸'), findsOneWidget);
    expect(find.text('互動'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    _expectTopLeft(
      tester,
      find.byKey(const Key('homeMobileLogo')),
      const Offset(20, 12),
    );
    _expectTopLeft(
      tester,
      find.byKey(const Key('homeNotificationButton')),
      const Offset(338, 18),
    );
    _expectTopLeft(
      tester,
      find.byKey(const Key('homeAnnoyanceChatButton')),
      const Offset(16, 536),
    );
  });

  for (final size in const [Size(500, 844), Size(599, 900)]) {
    testWidgets('mobile Penpot canvas fills viewport width at $size', (
      tester,
    ) async {
      await pumpHome(tester, size);

      expect(find.byKey(const Key('mobileCompanionHero')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('homeMobileViewport'))).width,
        size.width,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('desktop home matches Penpot companion layout', (tester) async {
    await pumpHome(tester, const Size(1440, 900));

    expect(find.byKey(const Key('desktopCompanionHero')), findsOneWidget);
    expect(find.byKey(const Key('mobileCompanionHero')), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('陪你整理今天的心情'), findsOneWidget);
    expect(find.text('選一件現在最想做的事，不需要一次處理所有情緒。'), findsOneWidget);
    expect(find.text('嗨，我在這裡。'), findsOneWidget);
    expect(find.text('記下現在的心情'), findsOneWidget);
    expect(find.text('＋ 記下現在的心情'), findsOneWidget);
    expect(find.text('寫一篇日記'), findsOneWidget);
    expect(find.text('回顧心情記錄'), findsOneWidget);
    expect(find.text('我的怪獸'), findsOneWidget);
    expect(find.text('互動區'), findsNWidgets(2));
    expect(find.text('陪伴首頁'), findsOneWidget);
    expect(find.byKey(const Key('appTopNavLogo')), findsOneWidget);
    expect(find.byKey(const Key('appTopNavProfile')), findsOneWidget);
  });

  for (final size in const [
    Size(600, 700),
    Size(900, 700),
    Size(1024, 768),
    Size(1199, 800),
  ]) {
    testWidgets('tablet home reflows without overflow at $size', (
      tester,
    ) async {
      await pumpHome(tester, size);

      expect(find.byKey(const Key('tabletCompanionHero')), findsOneWidget);
      expect(find.byKey(const Key('desktopCompanionHero')), findsNothing);
      expect(find.byKey(const Key('mobileCompanionHero')), findsNothing);
      expect(find.byKey(const Key('homeTabletLogo')), findsOneWidget);
      expect(find.byKey(const Key('homeAccountMenu')), findsOneWidget);
      expect(find.byKey(const Key('homeAnnoyanceChatButton')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('homeTabletShell'))).width,
        size.width,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('1200px switches to desktop home navigation', (tester) async {
    await pumpHome(tester, const Size(1200, 800));

    expect(find.byKey(const Key('desktopCompanionHero')), findsOneWidget);
    expect(find.byKey(const Key('tabletCompanionHero')), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('homeDesktopShell'))).width,
      1200,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop home remains bounded on a wide web viewport', (
    tester,
  ) async {
    await pumpHome(tester, const Size(1920, 1080));

    expect(find.byKey(const Key('desktopCompanionHero')), findsOneWidget);
    expect(find.byKey(const Key('appTopNavLogo')), findsOneWidget);
    expect(find.byKey(const Key('homeAnnoyanceChatButton')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary home action opens annoyance chat on desktop', (
    tester,
  ) async {
    await pumpHome(tester, const Size(1440, 900));

    await tester.tap(find.byKey(const Key('homeAnnoyanceChatButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annoyanceChatStartButton')), findsOneWidget);
  });

  testWidgets('mobile notification shows coming soon feedback', (tester) async {
    await pumpHome(tester, const Size(390, 844));

    await tester.tap(find.byKey(const Key('homeNotificationButton')));
    await tester.pump();

    expect(find.text('通知即將開放'), findsOneWidget);
    expect(find.byKey(const Key('homeAccountMenu')), findsNothing);
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
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: createAppRouter(initialLocation: AppPath.home),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeAnimatedMonster')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('homeAnimatedMonsterIdle')), findsOneWidget);
    expect(find.byKey(const Key('homeAnimatedMonsterReacting')), findsNothing);
  });
}

void _expectTopLeft(
  WidgetTester tester,
  Finder finder,
  Offset expectedTopLeft,
) {
  expect(tester.getTopLeft(finder).dx, moreOrLessEquals(expectedTopLeft.dx));
  expect(tester.getTopLeft(finder).dy, moreOrLessEquals(expectedTopLeft.dy));
}
