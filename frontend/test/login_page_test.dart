import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/auth_user.dart';
import 'package:monsters/models/login_result.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('shows login form actions', (tester) async {
    await tester.pumpWidget(_loginApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('貘nsters'), findsOneWidget);
    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(find.byKey(const Key('loginPasswordField')), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('使用 Google 登入'), findsOneWidget);
    expect(find.text('還沒有帳號？前往註冊'), findsOneWidget);
  });

  testWidgets('validates required login fields', (tester) async {
    await tester.pumpWidget(_loginApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('請輸入 Email'), findsOneWidget);
    expect(find.text('請輸入密碼'), findsOneWidget);
  });

  testWidgets('submits credentials and navigates to home on success', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_loginApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('loginEmailField')),
      'user@example.com',
    );
    await tester.enterText(find.byKey(const Key('loginPasswordField')), 'p');
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();

    expect(repository.email, 'user@example.com');
    expect(repository.password, 'p');
    expect(find.text('首頁'), findsWidgets);
  });

  testWidgets('shows repository error message', (tester) async {
    await tester.pumpWidget(
      _loginApp(
        _FakeAuthRepository(
          exception: const ApiException(
            type: ApiErrorType.unauthorized,
            message: 'Login failed',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('loginEmailField')),
      'user@example.com',
    );
    await tester.enterText(find.byKey(const Key('loginPasswordField')), 'p');
    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginErrorMessage')), findsOneWidget);
    expect(find.text('Login failed'), findsOneWidget);
  });
}

Widget _loginApp(AuthRepository authRepository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.login),
    ),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.exception}) : super(_dummyClient());

  final ApiException? exception;
  String? email;
  String? password;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    this.email = email;
    this.password = password;
    final exception = this.exception;
    if (exception != null) {
      throw exception;
    }
    return const LoginResult(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      user: AuthUser(
        userId: 1,
        email: 'user@example.com',
        userName: 'Wei',
        avatarUrl: null,
      ),
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
