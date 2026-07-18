import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/login_result.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('matches Penpot mobile splash layout while checking session', (
    tester,
  ) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_splashApp(_PendingAuthRepository()));
    await tester.pump();

    expect(find.text('把心裡的重量，先放在這裡。'), findsOneWidget);
    expect(find.text('正在確認登入狀態…'), findsOneWidget);
    expect(find.text('最長保留 30 天登入狀態'), findsOneWidget);
    expect(find.text('貘nsters · 陪你整理每一種心情'), findsOneWidget);
    expect(find.byKey(const Key('splashLoginButton')), findsNothing);
    expect(find.byKey(const Key('splashRegisterButton')), findsNothing);

    _expectRect(
      tester,
      find.byKey(const Key('splashLogo')),
      const Offset(92, 94),
      const Size(206, 64),
    );
    _expectRect(
      tester,
      find.byKey(const Key('splashMonster')),
      const Offset(78, 224),
      const Size(234, 234),
    );
    _expectRect(
      tester,
      find.byKey(const Key('splashStatusCard')),
      const Offset(54, 586),
      const Size(282, 82),
    );
    _expectRect(
      tester,
      find.byKey(const Key('splashStatusDot')),
      const Offset(76, 614),
      const Size(16, 16),
    );
    _expectRect(
      tester,
      find.byKey(const Key('splashStatusText')),
      const Offset(108, 608),
      const Size(123, 17),
    );
    _expectRect(
      tester,
      find.byKey(const Key('splashStatusHint')),
      const Offset(108, 634),
      const Size(118, 14),
    );
  });

  testWidgets('keeps Penpot hierarchy in responsive web splash layout', (
    tester,
  ) async {
    await _setDesktopSurface(tester);
    await tester.pumpWidget(_splashApp(_PendingAuthRepository()));
    await tester.pump();

    expect(find.text('把心裡的重量，先放在這裡。'), findsOneWidget);
    expect(find.text('正在確認登入狀態…'), findsOneWidget);
    expect(find.text('最長保留 30 天登入狀態'), findsOneWidget);
    expect(find.text('貘nsters · 陪你整理每一種心情'), findsNothing);
    expect(find.byKey(const Key('splashLoginButton')), findsNothing);
    expect(find.byKey(const Key('splashRegisterButton')), findsNothing);

    final logo = tester.getRect(find.byKey(const Key('splashLogo')));
    final monster = tester.getRect(find.byKey(const Key('splashMonster')));
    final status = tester.getRect(find.byKey(const Key('splashStatusCard')));
    expect(logo.size, const Size(300, 92));
    expect(monster.size, const Size(220, 220));
    expect(status.width, 340);
    expect(logo.center.dx, moreOrLessEquals(720));
    expect(monster.center.dx, moreOrLessEquals(720));
    expect(status.center.dx, moreOrLessEquals(720));
    expect(logo.bottom, lessThan(monster.top));
    expect(monster.bottom, lessThan(status.top));
  });

  for (final size in const [
    Size(600, 700),
    Size(900, 700),
    Size(1024, 768),
    Size(1920, 1080),
  ]) {
    testWidgets('responsive splash remains usable at $size', (tester) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(_splashApp(_PendingAuthRepository()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      _expectFullyVisible(tester, find.byKey(const Key('splashLogo')), size);
      _expectFullyVisible(tester, find.byKey(const Key('splashMonster')), size);
      _expectFullyVisible(
        tester,
        find.byKey(const Key('splashStatusCard')),
        size,
      );
    });
  }

  testWidgets('redirects to login when session restore fails', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_splashApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(find.byKey(const Key('splashLoginButton')), findsNothing);
    expect(find.byKey(const Key('splashRegisterButton')), findsNothing);
  });
}

Future<void> _setMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> _setDesktopSurface(WidgetTester tester) async {
  await _setSurface(tester, const Size(1440, 900));
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Widget _splashApp(AuthRepository authRepository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.splash),
    ),
  );
}

void _expectRect(
  WidgetTester tester,
  Finder finder,
  Offset expectedTopLeft,
  Size expectedSize,
) {
  expect(tester.getTopLeft(finder).dx, moreOrLessEquals(expectedTopLeft.dx));
  expect(tester.getTopLeft(finder).dy, moreOrLessEquals(expectedTopLeft.dy));
  expect(tester.getSize(finder).width, moreOrLessEquals(expectedSize.width));
  expect(tester.getSize(finder).height, moreOrLessEquals(expectedSize.height));
}

void _expectFullyVisible(
  WidgetTester tester,
  Finder finder,
  Size viewportSize,
) {
  final rect = tester.getRect(finder);
  final viewport = Offset.zero & viewportSize;
  expect(
    viewport.contains(rect.topLeft),
    isTrue,
    reason: '$rect starts outside',
  );
  expect(
    viewport.contains(rect.bottomRight),
    isTrue,
    reason: '$rect ends outside',
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(_dummyClient());

  @override
  Future<LoginResult?> restoreSession({DateTime? now}) async {
    return null;
  }
}

class _PendingAuthRepository extends AuthRepository {
  _PendingAuthRepository() : super(_dummyClient());

  final Completer<LoginResult?> _sessionCompleter = Completer<LoginResult?>();

  @override
  Future<LoginResult?> restoreSession({DateTime? now}) {
    return _sessionCompleter.future;
  }
}

ApiClient _dummyClient() {
  return ApiClient(
    config: const AppConfig(
      apiBaseUrl: 'http://example.com/api',
      connectTimeout: Duration(seconds: 1),
      receiveTimeout: Duration(seconds: 1),
      sendTimeout: Duration(seconds: 1),
    ),
    dio: Dio(),
  );
}
