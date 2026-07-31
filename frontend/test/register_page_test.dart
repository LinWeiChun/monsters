import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/registration_policy.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('shows only email password and required document acceptances', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerAccountField')), findsNothing);
    expect(find.byKey(const Key('registerUserNameField')), findsNothing);
    expect(find.byKey(const Key('registerEmailField')), findsOneWidget);
    expect(find.byKey(const Key('registerPasswordField')), findsOneWidget);
    expect(
      find.byKey(const Key('registerConfirmPasswordField')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('termsAcceptanceCheckbox')), findsOneWidget);
    expect(find.byKey(const Key('privacyAcceptanceCheckbox')), findsOneWidget);
    expect(find.byKey(const Key('showTermsDialogButton')), findsOneWidget);
    expect(find.byKey(const Key('showPrivacyDialogButton')), findsOneWidget);
    expect(find.text('https://example.test/terms'), findsNothing);
    expect(find.text('https://example.test/privacy'), findsNothing);
    expect(find.byType(Scrollbar), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('shows policy documents in a scrollable dialog only', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('showTermsDialogButton')));
    await tester.pumpAndSettle();

    expect(find.text('服務條款'), findsOneWidget);
    expect(find.text('https://example.test/terms'), findsOneWidget);
    expect(find.byType(Scrollbar), findsOneWidget);

    await tester.tap(find.byKey(const Key('closePolicyDialogButton')));
    await tester.pumpAndSettle();

    expect(find.text('https://example.test/terms'), findsNothing);
  });

  for (final size in const [
    Size(390, 844),
    Size(600, 700),
    Size(900, 700),
    Size(1024, 768),
    Size(1200, 800),
    Size(1440, 900),
    Size(1920, 1080),
  ]) {
    testWidgets('email registration form reflows without overflow at $size', (
      tester,
    ) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('registerEmailField')), findsOneWidget);
      expect(find.byKey(const Key('registerSubmitButton')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('requires fields and both current document acceptances', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('請輸入 Email'), findsOneWidget);
    expect(find.text('請輸入密碼'), findsOneWidget);
    expect(find.text('請再次輸入密碼'), findsOneWidget);
    expect(find.text('請同意目前的服務條款與隱私權政策'), findsOneWidget);
  });

  for (final codePointCount in const [14, 15, 128, 129]) {
    testWidgets(
      'maps backend Unicode policy for $codePointCount emoji code points',
      (tester) async {
        await _setSurface(tester, const Size(390, 844));
        await tester.pumpWidget(
          _registerApp(
            _FakeAuthRepository(enforceSyntheticPasswordPolicy: true),
          ),
        );
        await tester.pumpAndSettle();

        final password = List.filled(codePointCount, '😀').join();
        await tester.enterText(
          find.byKey(const Key('registerEmailField')),
          'boundary.$codePointCount@example.test',
        );
        await tester.enterText(
          find.byKey(const Key('registerPasswordField')),
          password,
        );
        await tester.enterText(
          find.byKey(const Key('registerConfirmPasswordField')),
          password,
        );
        await tester.tap(find.byKey(const Key('termsAcceptanceCheckbox')));
        await tester.tap(find.byKey(const Key('privacyAcceptanceCheckbox')));
        await tester.tap(find.byKey(const Key('registerSubmitButton')));
        await tester.pumpAndSettle();

        if (codePointCount == 14) {
          expect(find.text('密碼至少需要 15 個字元'), findsOneWidget);
        } else if (codePointCount == 129) {
          expect(find.text('密碼最多可有 128 個字元'), findsOneWidget);
        } else {
          expect(find.text('請查看你的 Email'), findsOneWidget);
        }
      },
    );
  }

  testWidgets('maps the backend NFC-normalized length result', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _registerApp(
        _FakeAuthRepository(
          registerException: const ApiException(
            type: ApiErrorType.validation,
            code: 'VALIDATION_FAILED',
            message: 'Request validation failed',
            fieldErrors: {'password': 'PASSWORD_TOO_SHORT'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final decomposedPassword = '${List.filled(13, 'a').join()}e\u0301';
    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      'nfc.boundary@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      decomposedPassword,
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      decomposedPassword,
    );
    await tester.tap(find.byKey(const Key('termsAcceptanceCheckbox')));
    await tester.tap(find.byKey(const Key('privacyAcceptanceCheckbox')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('密碼至少需要 15 個字元'), findsOneWidget);
  });

  testWidgets('shows a localized backend weak-password error', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _registerApp(
        _FakeAuthRepository(
          registerException: const ApiException(
            type: ApiErrorType.validation,
            code: 'VALIDATION_FAILED',
            message: 'Request validation failed',
            fieldErrors: {'password': 'PASSWORD_TOO_WEAK'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      'member@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'not-on-local-list',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      'not-on-local-list',
    );
    await tester.tap(find.byKey(const Key('termsAcceptanceCheckbox')));
    await tester.tap(find.byKey(const Key('privacyAcceptanceCheckbox')));
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('這組密碼太常見，請改用較不容易猜到的密碼'), findsOneWidget);
  });

  testWidgets('submits current policy versions and opens waiting page', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_registerApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      ' member@example.test ',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'synthetic-password',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('termsAcceptanceCheckbox')));
    await tester.tap(find.byKey(const Key('privacyAcceptanceCheckbox')));
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(repository.email, 'member@example.test');
    expect(repository.password, 'synthetic-password');
    expect(repository.termsVersion, 'terms-v1');
    expect(repository.privacyVersion, 'privacy-v1');
    expect(find.text('請查看你的 Email'), findsOneWidget);
    expect(find.textContaining('60 秒後可重寄'), findsOneWidget);
  });

  testWidgets('shows stable registration error without disclosing membership', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _registerApp(
        _FakeAuthRepository(
          registerException: const ApiException(
            type: ApiErrorType.server,
            code: 'SERVICE_TEMPORARILY_UNAVAILABLE',
            message: 'Internal detail',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      'member@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'synthetic-password',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('termsAcceptanceCheckbox')));
    await tester.tap(find.byKey(const Key('privacyAcceptanceCheckbox')));
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('註冊服務暫時無法使用，請稍後再試'), findsOneWidget);
    expect(find.text('Internal detail'), findsNothing);
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Widget _registerApp(AuthRepository authRepository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.register),
    ),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({
    this.registerException,
    this.enforceSyntheticPasswordPolicy = false,
  }) : super(_dummyClient());

  final ApiException? registerException;
  final bool enforceSyntheticPasswordPolicy;
  String? email;
  String? password;
  String? termsVersion;
  String? privacyVersion;

  @override
  Future<RegistrationPolicy> registrationPolicy() async {
    return const RegistrationPolicy(
      termsVersion: 'terms-v1',
      termsUrl: 'https://example.test/terms',
      privacyVersion: 'privacy-v1',
      privacyUrl: 'https://example.test/privacy',
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String acceptedTermsVersion,
    required String acceptedPrivacyVersion,
  }) async {
    this.email = email;
    this.password = password;
    termsVersion = acceptedTermsVersion;
    privacyVersion = acceptedPrivacyVersion;
    final exception = registerException;
    if (exception != null) {
      throw exception;
    }
    if (enforceSyntheticPasswordPolicy) {
      final codePointCount = password.runes.length;
      if (codePointCount < 15) {
        throw const ApiException(
          type: ApiErrorType.validation,
          code: 'VALIDATION_FAILED',
          message: 'Request validation failed',
          fieldErrors: {'password': 'PASSWORD_TOO_SHORT'},
        );
      }
      if (codePointCount > 128) {
        throw const ApiException(
          type: ApiErrorType.validation,
          code: 'VALIDATION_FAILED',
          message: 'Request validation failed',
          fieldErrors: {'password': 'PASSWORD_TOO_LONG'},
        );
      }
    }
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
