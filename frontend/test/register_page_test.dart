import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/register_result.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('shows register form actions', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('開始你的陪伴旅程'), findsOneWidget);
    expect(find.byKey(const Key('registerAccountField')), findsOneWidget);
    expect(find.byKey(const Key('registerEmailField')), findsOneWidget);
    expect(find.byKey(const Key('registerUserNameField')), findsOneWidget);
    expect(find.byKey(const Key('registerPasswordField')), findsOneWidget);
    expect(
      find.byKey(const Key('registerConfirmPasswordField')),
      findsOneWidget,
    );
    expect(find.text('完成註冊'), findsOneWidget);
    expect(find.text('已有帳號？'), findsOneWidget);
    expect(find.text('返回登入'), findsOneWidget);
  });

  testWidgets('shows web register layout copy', (tester) async {
    await _setDesktopSurface(tester);
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('建立新帳號'), findsOneWidget);
    expect(find.text('註冊完成後，請使用新帳號登入。'), findsOneWidget);
    expect(find.text('‹  返回登入'), findsOneWidget);
    expect(find.text('完成註冊'), findsOneWidget);
    expect(find.text('從一個帳號開始，\n把每一天好好收進來。'), findsOneWidget);
    expect(find.text('帳號可使用英文、數字與底線　·　密碼至少 8 字元'), findsOneWidget);
  });

  testWidgets('validates required register fields', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    final submitButton = find.byKey(const Key('registerSubmitButton'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('請輸入帳號'), findsOneWidget);
    expect(find.text('請輸入 Email'), findsOneWidget);
    expect(find.text('請輸入暱稱'), findsOneWidget);
    expect(find.text('請輸入密碼'), findsOneWidget);
    expect(find.text('請再次輸入密碼'), findsOneWidget);
  });

  testWidgets('validates password confirmation', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerAccountField')),
      'wei_account',
    );
    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('registerUserNameField')),
      'Wei',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      'password456',
    );
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('兩次輸入的密碼不一致'), findsOneWidget);
  });

  testWidgets('validates account format', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_registerApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerAccountField')),
      '123',
    );
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('帳號至少 4 字元'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('registerAccountField')),
      '1234',
    );
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('帳號需以英文開頭，僅可使用英文、數字與底線'), findsOneWidget);
  });

  testWidgets('submits register form and navigates to login on success', (
    tester,
  ) async {
    await _setMobileSurface(tester);
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_registerApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerAccountField')),
      ' Wei_Account ',
    );
    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      ' user@example.com ',
    );
    await tester.enterText(
      find.byKey(const Key('registerUserNameField')),
      ' Wei ',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(repository.account, 'wei_account');
    expect(repository.email, 'user@example.com');
    expect(repository.userName, 'Wei');
    expect(repository.password, 'password123');
    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
  });

  testWidgets('shows repository error message', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(
      _registerApp(
        _FakeAuthRepository(
          exception: const ApiException(
            type: ApiErrorType.conflict,
            message: 'Email already exists',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registerAccountField')),
      'wei_account',
    );
    await tester.enterText(
      find.byKey(const Key('registerEmailField')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('registerUserNameField')),
      'Wei',
    );
    await tester.enterText(
      find.byKey(const Key('registerPasswordField')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('registerConfirmPasswordField')),
      'password123',
    );
    await tester.ensureVisible(find.byKey(const Key('registerSubmitButton')));
    await tester.tap(find.byKey(const Key('registerSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('registerErrorMessage')), findsOneWidget);
    expect(find.text('Email already exists'), findsOneWidget);
  });
}

Future<void> _setMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> _setDesktopSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1440, 900));
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
  _FakeAuthRepository({this.exception}) : super(_dummyClient());

  final ApiException? exception;
  String? email;
  String? password;
  String? userName;
  String? account;

  @override
  Future<RegisterResult> register({
    required String account,
    required String email,
    required String password,
    required String userName,
  }) async {
    this.account = account;
    this.email = email;
    this.password = password;
    this.userName = userName;
    final exception = this.exception;
    if (exception != null) {
      throw exception;
    }
    return RegisterResult(
      userId: 1,
      account: account,
      email: email,
      userName: userName,
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
