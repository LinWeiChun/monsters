import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/models/device_session.dart';
import 'package:monsters/pages/session_management_page.dart';
import 'package:monsters/providers/session_management_provider.dart';
import 'package:monsters/repositories/session_management_repository.dart';

void main() {
  final page = DeviceSessionPage(
    items: [
      DeviceSession(
        sessionId: 'current',
        deviceType: 'ANDROID',
        deviceSummary: 'Android App',
        lastActivityAt: DateTime(2026, 8, 16, 10),
        current: true,
      ),
      DeviceSession(
        sessionId: 'web',
        deviceType: 'WEB',
        deviceSummary: 'Chrome on macOS',
        lastActivityAt: DateTime(2026, 8, 15, 21, 30),
        current: false,
      ),
      DeviceSession(
        sessionId: 'ios',
        deviceType: 'IOS',
        deviceSummary: 'iOS App',
        lastActivityAt: DateTime(2026, 8, 14, 9, 5),
        current: false,
      ),
    ],
    page: 0,
    size: 3,
    totalItems: 4,
    totalPages: 2,
  );

  for (final width in [390.0, 600.0, 1199.0, 1200.0, 1440.0]) {
    testWidgets(
      'shows the full device screen without main scrolling at $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sessionManagementRepositoryProvider.overrideWithValue(
                _FakeRepository(page),
              ),
            ],
            child: const MaterialApp(home: SessionManagementPage()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('sessionManagementViewport')),
          findsOneWidget,
        );
        expect(find.text('Android App'), findsOneWidget);
        expect(find.text('Chrome on macOS'), findsOneWidget);
        expect(find.text('iOS App'), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsNothing);
        expect(find.byType(ListView), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('uses a modal for reauthentication', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionManagementRepositoryProvider.overrideWithValue(
            _FakeRepository(page),
          ),
        ],
        child: const MaterialApp(home: SessionManagementPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('revokeOtherSessions')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('sessionReauthenticationDialog')),
      findsOneWidget,
    );
    expect(find.text('驗證結果僅供 5 分鐘內管理登入裝置'), findsOneWidget);
  });
}

class _FakeRepository implements SessionManagementRepository {
  _FakeRepository(this.page);

  final DeviceSessionPage page;

  @override
  Future<DeviceSessionPage> list({required int page}) async => this.page;

  @override
  Future<SessionReauthentication> reauthenticate({
    required String password,
  }) async {
    return const SessionReauthentication(
      credential: 'credential',
      purpose: 'SESSION_MANAGEMENT',
      expiresIn: 300,
    );
  }

  @override
  Future<void> revokeAll({required String credential}) async {}

  @override
  Future<void> revokeCurrent() async {}

  @override
  Future<void> revokeOne({
    required String sessionId,
    required String credential,
  }) async {}

  @override
  Future<void> revokeOthers({required String credential}) async {}
}
