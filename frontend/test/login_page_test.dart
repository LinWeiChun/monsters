import 'dart:async';

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
import 'package:monsters/services/google_sign_in_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows login form actions', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_loginApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.text('歡迎回來'), findsOneWidget);
    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(find.byKey(const Key('loginPasswordField')), findsOneWidget);
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('使用 Google 登入'), findsOneWidget);
    expect(find.text('還沒有帳號？'), findsOneWidget);
    expect(find.text('建立新帳號'), findsOneWidget);
  });

  testWidgets('validates required login fields', (tester) async {
    await _setMobileSurface(tester);
    await tester.pumpWidget(_loginApp(_FakeAuthRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginSubmitButton')));
    await tester.pumpAndSettle();

    expect(find.text('請輸入帳號或 Email'), findsOneWidget);
    expect(find.text('請輸入密碼'), findsOneWidget);
  });

  testWidgets('submits credentials and navigates to home on success', (
    tester,
  ) async {
    await _setMobileSurface(tester);
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

  testWidgets('submits Google ID token and navigates to home on success', (
    tester,
  ) async {
    await _setMobileSurface(tester);
    final repository = _FakeAuthRepository();
    final googleSignInService = _FakeGoogleSignInService();
    await tester.pumpWidget(
      _loginApp(repository, googleSignInService: googleSignInService),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginGoogleButton')));
    await tester.pumpAndSettle();

    expect(repository.googleIdToken, 'google-id-token');
    expect(find.text('首頁'), findsWidgets);

    await googleSignInService.dispose();
  });

  testWidgets('handles Google web authentication event', (tester) async {
    await _setMobileSurface(tester);
    final repository = _FakeAuthRepository();
    final googleSignInService = _FakeGoogleSignInService();
    await tester.pumpWidget(
      _loginApp(repository, googleSignInService: googleSignInService),
    );
    await tester.pumpAndSettle();

    googleSignInService.emitIdToken('web-id-token');
    await tester.pumpAndSettle();

    expect(repository.googleIdToken, 'web-id-token');
    expect(find.text('首頁'), findsWidgets);

    await googleSignInService.dispose();
  });

  testWidgets('shows repository error message', (tester) async {
    await _setMobileSurface(tester);
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

  testWidgets('shows Google repository error message', (tester) async {
    await _setMobileSurface(tester);
    final googleSignInService = _FakeGoogleSignInService();
    await tester.pumpWidget(
      _loginApp(
        _FakeAuthRepository(
          googleException: const ApiException(
            type: ApiErrorType.unauthorized,
            message: 'Google failed',
          ),
        ),
        googleSignInService: googleSignInService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginGoogleButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginErrorMessage')), findsOneWidget);
    expect(find.text('Google failed'), findsOneWidget);

    await googleSignInService.dispose();
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
    final googleSignInService = _FakeGoogleSignInService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          googleSignInServiceProvider.overrideWithValue(googleSignInService),
        ],
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeAccountMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('登出'));
    await tester.pumpAndSettle();

    expect(repository.didLogout, isTrue);
    expect(googleSignInService.didSignOut, isTrue);
    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);

    await googleSignInService.dispose();
  });
}

Future<void> _setMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Widget _loginApp(
  AuthRepository authRepository, {
  GoogleSignInService? googleSignInService,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      googleSignInServiceProvider.overrideWithValue(
        googleSignInService ?? _FakeGoogleSignInService(),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.login),
    ),
  );
}

Widget _splashApp(AuthRepository authRepository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      googleSignInServiceProvider.overrideWithValue(_FakeGoogleSignInService()),
    ],
    child: MaterialApp.router(routerConfig: createAppRouter()),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({
    this.exception,
    this.googleException,
    this.restoredSession,
  }) : super(_dummyClient());

  final ApiException? exception;
  final ApiException? googleException;
  final LoginResult? restoredSession;
  String? email;
  String? password;
  String? googleIdToken;
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
  Future<LoginResult> googleLogin({required String idToken}) async {
    googleIdToken = idToken;
    final exception = googleException;
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

class _FakeGoogleSignInService extends GoogleSignInService {
  _FakeGoogleSignInService() : super(config: _testConfig);

  final _idTokenController = StreamController<String>.broadcast();
  bool didInitialize = false;
  bool didSignOut = false;

  @override
  Stream<String> get idTokenEvents => _idTokenController.stream;

  @override
  Future<void> initialize() async {
    didInitialize = true;
  }

  @override
  Future<String> signInAndGetIdToken() async {
    return 'google-id-token';
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }

  void emitIdToken(String idToken) {
    _idTokenController.add(idToken);
  }

  Future<void> dispose() async {
    await _idTokenController.close();
  }
}

const _loginResult = LoginResult(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  tokenType: 'Bearer',
  expiresIn: 3600,
  user: AuthUser(
    userId: 1,
    account: 'wei_account',
    email: 'user@example.com',
    userName: 'Wei',
    avatarUrl: null,
  ),
);

const _testConfig = AppConfig(
  apiBaseUrl: 'http://example.com/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

ApiClient _dummyClient() {
  return ApiClient(config: _testConfig, dio: Dio());
}
