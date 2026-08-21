import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/auth_user.dart';
import 'package:monsters/models/device_session.dart';
import 'package:monsters/models/login_result.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
import 'package:monsters/services/google_sign_in_service.dart';

void main() {
  testWidgets('completes explicit Google account linking', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    final repository = _FakeAuthRepository();
    final google = _FakeGoogleSignInService();
    await tester.pumpWidget(_app(repository, google));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('googleLinkRequiredStage')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('googleLinkEmailField')),
      'member@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('googleLinkPasswordField')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('googleLinkExistingLoginButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('googleLinkReauthenticationStage')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('googleLinkReauthenticationPasswordField')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('googleLinkReauthenticateButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('googleLinkConfirmationStage')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('googleLinkConfirmButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('googleLinkSuccessStage')), findsOneWidget);
    expect(repository.email, 'member@example.test');
    expect(repository.loginPassword, 'synthetic-password');
    expect(repository.reauthenticationPassword, 'synthetic-password');
    expect(repository.reauthenticationCredential, 'link-proof');
    expect(repository.googleIdToken, 'fresh-google-id-token');
    expect(google.signInCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a generic conflict without linking', (tester) async {
    await _setSurface(tester, const Size(600, 700));
    final repository = _FakeAuthRepository(linkConflict: true);
    await tester.pumpWidget(_app(repository, _FakeGoogleSignInService()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('googleLinkEmailField')),
      'member@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('googleLinkPasswordField')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('googleLinkExistingLoginButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('googleLinkReauthenticationPasswordField')),
      'synthetic-password',
    );
    await tester.tap(find.byKey(const Key('googleLinkReauthenticateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('googleLinkConfirmButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('googleLinkConflictStage')), findsOneWidget);
    expect(find.textContaining('沒有變更任何登入方式'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancels before authentication without creating a link', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    final repository = _FakeAuthRepository();
    final google = _FakeGoogleSignInService();
    await tester.pumpWidget(_app(repository, google));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('googleLinkCancelButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginEmailField')), findsOneWidget);
    expect(repository.googleIdToken, isNull);
    expect(google.didSignOut, isTrue);
  });

  for (final size in const [
    Size(390, 844),
    Size(600, 700),
    Size(1199, 800),
    Size(1440, 900),
  ]) {
    testWidgets('Google link required state reflows at $size', (tester) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(
        _app(_FakeAuthRepository(), _FakeGoogleSignInService()),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('googleLinkRequiredStage')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _app(
  AuthRepository repository,
  GoogleSignInService googleSignInService,
) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      googleSignInServiceProvider.overrideWithValue(googleSignInService),
    ],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.googleAccountLink),
    ),
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.linkConflict = false})
    : super(
        ApiClient(config: _config, dio: Dio()),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

  final bool linkConflict;
  String? email;
  String? loginPassword;
  String? reauthenticationPassword;
  String? reauthenticationCredential;
  String? googleIdToken;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    this.email = email;
    loginPassword = password;
    return _authenticatedResult;
  }

  @override
  Future<SessionReauthentication> reauthenticateForGoogleLink({
    required String password,
  }) async {
    reauthenticationPassword = password;
    return const SessionReauthentication(
      credential: 'link-proof',
      purpose: 'LOGIN_METHOD_LINK',
      expiresIn: 300,
    );
  }

  @override
  Future<void> linkGoogleAccount({
    required String idToken,
    required String reauthenticationCredential,
  }) async {
    googleIdToken = idToken;
    this.reauthenticationCredential = reauthenticationCredential;
    if (linkConflict) {
      throw const ApiException(
        type: ApiErrorType.conflict,
        code: 'GOOGLE_ACCOUNT_LINK_CONFLICT',
        message: 'hidden conflict detail',
      );
    }
  }
}

class _FakeGoogleSignInService extends GoogleSignInService {
  _FakeGoogleSignInService() : super(config: _config);

  int signInCount = 0;
  bool didSignOut = false;

  @override
  Stream<String> get idTokenEvents => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<String> signInAndGetIdToken() async {
    signInCount++;
    return 'fresh-google-id-token';
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }
}

const _config = AppConfig(
  apiBaseUrl: 'http://example.test/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

const _authenticatedResult = LoginResult(
  accessToken: 'current-access-token',
  refreshToken: 'current-refresh-token',
  tokenType: 'Bearer',
  expiresIn: 600,
  user: AuthUser(
    publicId: '00000000-0000-0000-0000-000000000010',
    userId: 10,
    email: 'member@example.test',
    userName: 'Synthetic Member',
    avatarUrl: null,
  ),
);
