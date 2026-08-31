import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
import 'package:monsters/pages/password_reset_page.dart';
import 'package:monsters/theme/app_colors.dart';

void main() {
  testWidgets('login forgot password link opens formal request page', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(_FakeAuthRepository(), AppPath.login));
    await tester.pumpAndSettle();

    await tester.tap(find.text('忘記密碼？'));
    await tester.pumpAndSettle();

    expect(find.text('忘記密碼'), findsOneWidget);
    expect(find.byKey(const Key('passwordResetEmailField')), findsOneWidget);
  });

  testWidgets(
    'request result is generic and does not reveal member existence',
    (tester) async {
      await _setSurface(tester, const Size(390, 844));
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(_app(repository, AppPath.passwordResetRequest));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('passwordResetEmailField')),
        'member@example.test',
      );
      await tester.tap(find.byKey(const Key('passwordResetRequestButton')));
      await tester.pumpAndSettle();

      expect(repository.requestedEmail, 'member@example.test');
      expect(find.text('請查看你的 Email'), findsOneWidget);
      expect(find.textContaining('不會顯示 Email 是否存在'), findsOneWidget);
      expect(find.textContaining('member@example.test'), findsNothing);
    },
  );

  testWidgets('missing reset token shows invalid-link recovery', (
    tester,
  ) async {
    await _setSurface(tester, const Size(600, 900));
    await tester.pumpWidget(_app(_FakeAuthRepository(), AppPath.passwordReset));
    await tester.pumpAndSettle();

    expect(find.text('無法使用此連結'), findsOneWidget);
    expect(find.text('重新申請'), findsOneWidget);
  });

  testWidgets('successful reset requires a fresh login', (tester) async {
    await _setSurface(tester, const Size(1200, 900));
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      _app(repository, '${AppPath.passwordReset}?token=synthetic-token'),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('newPasswordField')),
      'correct horse battery staple',
    );
    await tester.enterText(
      find.byKey(const Key('confirmNewPasswordField')),
      'correct horse battery staple',
    );
    await tester.tap(find.byKey(const Key('passwordResetCompletionButton')));
    await tester.pumpAndSettle();

    expect(repository.resetToken, 'synthetic-token');
    expect(repository.newPassword, 'correct horse battery staple');
    expect(find.text('密碼重設完成'), findsOneWidget);
    expect(find.textContaining('所有已登入裝置都已失效'), findsOneWidget);
    expect(find.text('重新登入'), findsOneWidget);
  });

  testWidgets('expired token maps to a stable recovery state', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    final repository = _FakeAuthRepository(
      resetException: const ApiException(
        type: ApiErrorType.validation,
        message: 'expired',
        code: 'PASSWORD_RESET_TOKEN_EXPIRED',
      ),
    );
    await tester.pumpWidget(
      _app(repository, '${AppPath.passwordReset}?token=expired-token'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('newPasswordField')),
      'correct horse battery staple',
    );
    await tester.enterText(
      find.byKey(const Key('confirmNewPasswordField')),
      'correct horse battery staple',
    );
    await tester.tap(find.byKey(const Key('passwordResetCompletionButton')));
    await tester.pumpAndSettle();

    expect(find.text('重設連結已過期'), findsOneWidget);
    expect(find.text('重設連結已過期，請重新申請'), findsOneWidget);
  });

  for (final width in [
    390.0,
    599.0,
    600.0,
    900.0,
    1024.0,
    1199.0,
    1200.0,
    1440.0,
    1920.0,
  ]) {
    testWidgets('password reset request fits ${width.toInt()}px viewport', (
      tester,
    ) async {
      await _setSurface(tester, Size(width, 900));
      await tester.pumpWidget(
        _app(_FakeAuthRepository(), AppPath.passwordResetRequest),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });
  }

  for (final size in [
    const Size(390, 844),
    const Size(600, 900),
    const Size(1200, 500),
  ]) {
    testWidgets('reset remains usable with keyboard at $size', (tester) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(
        _app(_FakeAuthRepository(), '${AppPath.passwordReset}?token=test'),
      );
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(
        find.byKey(const Key('newPasswordField')),
        'long enough test password',
      );
      await tester.pumpAndSettle();
      final button = find.byKey(const Key('passwordResetCompletionButton'));
      expect(
        tester.getRect(button).bottom,
        lessThanOrEqualTo(size.height - 300),
      );
      expect(button.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(
        Theme.of(tester.element(button)).colorScheme.primary,
        AppColors.registerPrimary,
      );
    });
  }

  testWidgets('a changed reset token clears the previous form and result', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    final repository = _FakeAuthRepository();
    Widget page(String token) => ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: PasswordResetPage(token: token)),
    );
    await tester.pumpWidget(page('first'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('newPasswordField')),
      'old value',
    );
    await tester.enterText(
      find.byKey(const Key('confirmNewPasswordField')),
      'old value',
    );
    await tester.pumpWidget(page('second'));
    await tester.pumpAndSettle();
    expect(find.text('old value'), findsNothing);
    final password = List.filled(80, 'e\u0301').join();
    await tester.enterText(find.byKey(const Key('newPasswordField')), password);
    await tester.enterText(
      find.byKey(const Key('confirmNewPasswordField')),
      password,
    );
    await tester.tap(find.byKey(const Key('passwordResetCompletionButton')));
    await tester.pumpAndSettle();
    expect(repository.resetToken, 'second');
    expect(repository.newPassword, password);
    expect(find.text('密碼重設完成'), findsOneWidget);
    await tester.pumpWidget(page('third'));
    await tester.pumpAndSettle();
    expect(find.text('密碼重設完成'), findsNothing);
    expect(find.byKey(const Key('newPasswordField')), findsOneWidget);
  });
}

Widget _app(AuthRepository repository, String initialLocation) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: initialLocation),
    ),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.resetException})
    : super(
        ApiClient(config: _config, dio: Dio()),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

  final ApiException? resetException;
  String? requestedEmail;
  String? resetToken;
  String? newPassword;

  @override
  Future<void> requestPasswordReset({required String email}) async {
    requestedEmail = email;
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    resetToken = token;
    this.newPassword = newPassword;
    final exception = resetException;
    if (exception != null) {
      throw exception;
    }
  }
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

const _config = AppConfig(
  apiBaseUrl: 'https://api.example.test/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);
