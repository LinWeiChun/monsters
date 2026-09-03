import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/member_data_result.dart';
import 'package:monsters/pages/member_restoration_page.dart';
import 'package:monsters/pages/email_change_page.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/providers/member_data_provider.dart';
import 'package:monsters/repositories/auth_repository.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:monsters/repositories/member_data_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
import 'package:monsters/services/google_sign_in_service.dart';

void main() {
  testWidgets('changing email token ignores the previous in-flight result', (
    tester,
  ) async {
    final repository = _DelayedEmailRepository();
    Widget app(String token) => ProviderScope(
      overrides: [memberDataRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: EmailChangePage(token: token)),
    );
    await tester.pumpWidget(app('first'));
    await tester.pump();
    await tester.pumpWidget(app(''));
    await tester.pump();
    expect(find.text('Email 驗證連結無效'), findsOneWidget);
    repository.pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Email 驗證連結無效'), findsOneWidget);
    expect(find.text('Email 已完成變更'), findsNothing);
  });

  testWidgets('empty email change token is rejected without a request', (
    tester,
  ) async {
    final repository = _FakeMemberDataRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [memberDataRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.emailChange),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.completedEmailToken, isNull);
    expect(find.text('Email 驗證連結無效'), findsOneWidget);
    expect(find.textContaining('確認目前 Email'), findsOneWidget);
  });

  testWidgets('valid email change token completes without authenticating', (
    tester,
  ) async {
    final repository = _FakeMemberDataRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [memberDataRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(
          routerConfig: createAppRouter(
            initialLocation: '${AppPath.emailChange}?token=single-use-token',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.completedEmailToken, 'single-use-token');
    expect(find.text('Email 已完成變更'), findsOneWidget);
    expect(find.textContaining('下次登入請使用新 Email'), findsOneWidget);
  });

  testWidgets('direct restoration route requires a fresh login credential', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _RestorationRouteTestApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('恢復驗證已失效'), findsOneWidget);
    expect(find.textContaining('請重新登入'), findsOneWidget);
    expect(
      find.byKey(const Key('memberRestorationConfirmation')),
      findsNothing,
    );
  });

  testWidgets('restoration requires confirmation and clears local session', (
    tester,
  ) async {
    final memberRepository = _FakeMemberDataRepository();
    final authRepository = _FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memberDataRepositoryProvider.overrideWithValue(memberRepository),
          authRepositoryProvider.overrideWithValue(authRepository),
          googleSignInServiceProvider.overrideWithValue(
            _FakeGoogleSignInService(),
          ),
        ],
        child: const MaterialApp(
          home: MemberRestorationPage(
            continuationCredential: 'restore-continuation',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('memberRestorationSubmit')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('memberRestorationConfirmation')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('memberRestorationSubmit')));
    await tester.pumpAndSettle();

    expect(memberRepository.restorationCredential, 'restore-continuation');
    expect(authRepository.didClearLocalSession, isTrue);
    expect(find.text('帳號已恢復'), findsOneWidget);
    expect(find.textContaining('請重新登入'), findsOneWidget);
  });
}

class _RestorationRouteTestApp extends StatelessWidget {
  const _RestorationRouteTestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.memberRestoration),
    );
  }
}

class _FakeMemberDataRepository extends MemberDataRepository {
  _FakeMemberDataRepository()
    : super(
        _dummyClient(),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

  String? completedEmailToken;
  String? restorationCredential;

  @override
  Future<void> completeEmailChange({required String token}) async {
    completedEmailToken = token;
  }

  @override
  Future<MemberStateResult> restore({
    required String continuationCredential,
  }) async {
    restorationCredential = continuationCredential;
    return const MemberStateResult(
      memberState: 'ACTIVE',
      version: 8,
      nextAction: 'LOGIN_REQUIRED',
    );
  }
}

class _DelayedEmailRepository extends _FakeMemberDataRepository {
  final pending = Completer<void>();

  @override
  Future<void> completeEmailChange({required String token}) => pending.future;
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository()
    : super(
        _dummyClient(),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

  bool didClearLocalSession = false;

  @override
  Future<void> clearLocalSession() async {
    didClearLocalSession = true;
  }
}

class _FakeGoogleSignInService extends GoogleSignInService {
  _FakeGoogleSignInService() : super(config: _config);

  @override
  Future<void> initialize() async {}

  @override
  Stream<String> get idTokenEvents => const Stream.empty();

  @override
  Future<void> signOut() async {}
}

const _config = AppConfig(
  apiBaseUrl: 'http://example.com/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

ApiClient _dummyClient() => ApiClient(config: _config, dio: Dio());
