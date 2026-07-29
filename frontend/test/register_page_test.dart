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
    expect(find.text('https://example.test/terms'), findsOneWidget);
    expect(find.text('https://example.test/privacy'), findsOneWidget);
  });

  for (final size in const [Size(390, 844), Size(900, 700), Size(1440, 900)]) {
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
  _FakeAuthRepository({this.registerException}) : super(_dummyClient());

  final ApiException? registerException;
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
