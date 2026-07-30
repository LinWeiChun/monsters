import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/login_result.dart';
import 'package:monsters/pages/email_verification_page.dart';
import 'package:monsters/pages/email_verification_pending_page.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';

void main() {
  testWidgets('waiting page starts a 60 second resend cooldown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const EmailVerificationPendingPage(initialEmail: 'member@example.test'),
        _FakeAuthRepository(),
      ),
    );
    await tester.pump();

    expect(find.text('請查看你的 Email'), findsOneWidget);
    expect(find.text('60 秒後可重寄'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('verificationResendButton')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('waiting page resends without exposing account existence', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      _app(const EmailVerificationPendingPage(), repository),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('verificationResendEmailField')),
      'unknown@example.test',
    );
    await tester.tap(find.byKey(const Key('verificationResendButton')));
    await tester.pump();

    expect(repository.resendEmail, 'unknown@example.test');
    expect(find.text('驗證信重寄要求已受理'), findsOneWidget);
    expect(find.text('60 秒後可重寄'), findsOneWidget);
  });

  testWidgets('verification success presents the eligibility next step', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const EmailVerificationPage(token: 'synthetic-token'),
        _FakeAuthRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Email 驗證完成'), findsOneWidget);
    expect(find.textContaining('服務地區、生日與公開暱稱'), findsOneWidget);
    expect(find.text('資格資料流程將在後續步驟開放'), findsOneWidget);
    expect(
      find.byKey(const Key('emailVerificationContinueButton')),
      findsNothing,
    );
  });

  testWidgets('expired token presents a safe restart flow', (tester) async {
    await tester.pumpWidget(
      _app(
        const EmailVerificationPage(token: 'expired-token'),
        _FakeAuthRepository(
          verifyException: const ApiException(
            type: ApiErrorType.validation,
            code: 'EMAIL_VERIFICATION_TOKEN_EXPIRED',
            message: 'Internal expiry detail',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('驗證連結已過期，請重新開始驗證流程'), findsOneWidget);
    expect(find.text('Internal expiry detail'), findsNothing);
    expect(
      find.byKey(const Key('emailVerificationRestartButton')),
      findsOneWidget,
    );
  });
}

Widget _app(Widget child, AuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(home: child),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.verifyException}) : super(_dummyClient());

  final ApiException? verifyException;
  String? resendEmail;

  @override
  Future<void> requestVerificationEmail({required String email}) async {
    resendEmail = email;
  }

  @override
  Future<LoginResult> verifyEmail({required String token}) async {
    final exception = verifyException;
    if (exception != null) {
      throw exception;
    }
    return const LoginResult(
      expiresIn: 600,
      nextAction: 'COMPLETE_ELIGIBILITY',
      continuationCredential: 'synthetic-continuation',
    );
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
