import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/password_lock_status.dart';
import 'package:monsters/models/password_lock_verification.dart';
import 'package:monsters/providers/user_profile_provider.dart';
import 'package:monsters/repositories/user_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('shows password lock form actions', (tester) async {
    await tester.pumpWidget(_passwordLockApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    expect(find.text('密碼鎖'), findsWidgets);
    expect(find.byKey(const Key('passwordLockModeSelector')), findsOneWidget);
    expect(find.byKey(const Key('passwordLockField')), findsOneWidget);
    expect(find.byKey(const Key('passwordLockConfirmField')), findsOneWidget);
    expect(find.text('儲存密碼鎖'), findsOneWidget);
  });

  testWidgets('validates set password lock fields', (tester) async {
    await tester.pumpWidget(_passwordLockApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('passwordLockSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('請輸入密碼鎖'), findsWidgets);

    await tester.enterText(find.byKey(const Key('passwordLockField')), '1234');
    await tester.enterText(
      find.byKey(const Key('passwordLockConfirmField')),
      '5678',
    );
    await tester.tap(find.byKey(const Key('passwordLockSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('兩次輸入的密碼鎖不一致'), findsOneWidget);
  });

  testWidgets('sets password lock successfully', (tester) async {
    final repository = _FakeUserRepository();
    await tester.pumpWidget(_passwordLockApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('passwordLockField')), '1234');
    await tester.enterText(
      find.byKey(const Key('passwordLockConfirmField')),
      '1234',
    );
    await tester.tap(find.byKey(const Key('passwordLockSubmitButton')));
    await tester.pumpAndSettle();

    expect(repository.setLockPassword, '1234');
    expect(find.text('密碼鎖已更新'), findsOneWidget);
  });

  testWidgets('verifies password lock successfully', (tester) async {
    final repository = _FakeUserRepository(verified: true);
    await tester.pumpWidget(_passwordLockApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('驗證'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('passwordLockField')), '1234');
    await tester.tap(find.byKey(const Key('passwordLockSubmitButton')));
    await tester.pumpAndSettle();

    expect(repository.verifyLockPassword, '1234');
    expect(find.text('密碼鎖驗證成功'), findsOneWidget);
  });

  testWidgets('shows verify failure message', (tester) async {
    await tester.pumpWidget(
      _passwordLockApp(_FakeUserRepository(verified: false)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('驗證'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('passwordLockField')), '1234');
    await tester.tap(find.byKey(const Key('passwordLockSubmitButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('passwordLockVerifyFailedMessage')),
      findsOneWidget,
    );
  });

  testWidgets('home password lock action navigates to password lock route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
        ],
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homePasswordLockButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('passwordLockField')), findsOneWidget);
  });
}

Widget _passwordLockApp(UserRepository userRepository) {
  return ProviderScope(
    overrides: [userRepositoryProvider.overrideWithValue(userRepository)],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.passwordLock),
    ),
  );
}

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository({this.verified = true}) : super(_dummyClient());

  final bool verified;
  String? setLockPassword;
  String? verifyLockPassword;

  @override
  Future<PasswordLockStatus> setPasswordLock({
    required String lockPassword,
  }) async {
    setLockPassword = lockPassword;
    return const PasswordLockStatus(enabled: true);
  }

  @override
  Future<PasswordLockVerification> verifyPasswordLock({
    required String lockPassword,
  }) async {
    verifyLockPassword = lockPassword;
    return PasswordLockVerification(verified: verified);
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
