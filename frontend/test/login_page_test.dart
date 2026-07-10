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
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('restores active session from splash and navigates to home', (
    tester,
  ) async {
    await tester.pumpWidget(
      _splashApp(_FakeAuthRepository(restoredSession: _loginResult)),
    );
    await tester.pumpAndSettle();

    expect(find.text('首頁'), findsWidgets);
    expect(find.byKey(const Key('loginEmailField')), findsNothing);
  });

  testWidgets('stays on splash actions when no active session exists', (
    tester,
  ) async {
    await tester.pumpWidget(_splashApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('登入'), findsOneWidget);
    expect(find.text('註冊'), findsOneWidget);
  });

  testWidgets('home logout clears session and navigates to login', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeLogoutButton')));
    await tester.pumpAndSettle();

    expect(repository.didLogout, isTrue);
    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
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

Widget _splashApp(AuthRepository authRepository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    child: MaterialApp.router(routerConfig: createAppRouter()),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.exception, this.restoredSession})
    : super(_dummyClient());

  final ApiException? exception;
  final LoginResult? restoredSession;
  String? email;
  String? password;
  bool didLogout = false;

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
    return _loginResult;
  }

  @override
  Future<LoginResult?> restoreSession({DateTime? now}) async {
    return restoredSession;
  }

  @override
  Future<void> logout() async {
    didLogout = true;
  }
}

const _loginResult = LoginResult(
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
