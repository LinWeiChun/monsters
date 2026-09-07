import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/models/member_profile.dart';
import 'package:monsters/models/member_data_result.dart';
import 'package:monsters/providers/auth_provider.dart';
import 'package:monsters/providers/member_data_provider.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:monsters/repositories/member_data_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';
import 'package:monsters/services/google_sign_in_service.dart';
import 'package:monsters/widgets/auth/google_sign_in_web_button.dart';
import 'package:monsters/widgets/member/member_sensitive_dialog.dart';

void main() {
  testWidgets(
    'Web reauthentication uses official events and returns only the scoped proof',
    (tester) async {
      final repository = _FakeMemberDataRepository();
      final google = _EventGoogleSignInService();
      MemberSensitiveInput? result;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberDataRepositoryProvider.overrideWithValue(repository),
            googleSignInServiceProvider.overrideWithValue(google),
          ],
          child: MaterialApp(
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        result = await showDialog<MemberSensitiveInput>(
                          context: context,
                          builder:
                              (_) => const MemberSensitiveDialog(
                                title: '變更 Email',
                                fieldLabel: '新 Email',
                                fieldHint: '',
                                useWebGoogle: true,
                              ),
                        );
                      },
                      child: const Text('開啟'),
                    ),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('開啟'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('memberSensitiveGoogleSubmit')),
        findsNothing,
      );
      await tester.enterText(
        find.byKey(const Key('memberSensitiveValueField')),
        'new@example.test',
      );
      await tester.pump();
      expect(find.byType(GoogleSignInWebButton), findsOneWidget);
      google.events.add('synthetic-id-token');
      await tester.pumpAndSettle();
      expect(repository.reauthCalls, 1);
      expect(repository.reauthPurpose, 'EMAIL_CHANGE');
      expect(result!.reauthentication!.credential, 'purpose-bound-proof');
      expect(result!.password, isEmpty);
      google.events.add('late-event');
      await tester.pump();
      expect(repository.reauthCalls, 1);
      await tester.pumpWidget(const SizedBox());
      await google.events.close();
    },
  );

  testWidgets('cancelled Web reauthentication ignores an in-flight response', (
    tester,
  ) async {
    final pending = Completer<MemberReauthentication>();
    final repository =
        _FakeMemberDataRepository()..pendingReauthentication = pending;
    final google = _EventGoogleSignInService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memberDataRepositoryProvider.overrideWithValue(repository),
          googleSignInServiceProvider.overrideWithValue(google),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MemberSensitiveDialog(
              title: '變更 Email',
              fieldLabel: '新 Email',
              fieldHint: '',
              useWebGoogle: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memberSensitiveValueField')),
      'new@example.test',
    );
    await tester.pump();
    google.events.add('synthetic-id-token');
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete(
      const MemberReauthentication(
        credential: 'late-proof',
        purpose: 'EMAIL_CHANGE',
        expiresIn: 300,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await google.events.close();
  });

  testWidgets('birthday correction opens the built-in date picker', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1200, 760));
    await tester.pumpWidget(_memberDataApp(_FakeMemberDataRepository()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('memberBirthdayAction')));
    await tester.tap(find.byKey(const Key('memberBirthdayAction')));
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('memberSensitiveValueField'));
    expect(tester.widget<TextField>(field).readOnly, isTrue);
    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('mobile pending workflows fit without scrolling', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _memberDataApp(
        _FakeMemberDataRepository(profile: _profile.copyWithPendingWorkflows()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home profile action opens the formal member data route', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _memberDataApp(
        _FakeMemberDataRepository(),
        initialLocation: AppPath.home,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mobileNavProfile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('memberDataTitle')), findsOneWidget);
    expect(find.byKey(const Key('profileUserNameField')), findsNothing);
  });

  for (final size in const [
    Size(390, 844),
    Size(599, 900),
    Size(600, 700),
    Size(1199, 800),
    Size(1200, 760),
    Size(1440, 900),
  ]) {
    testWidgets('member data layout has no overflow at $size', (tester) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(_memberDataApp(_FakeMemberDataRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('memberDataViewport')), findsOneWidget);
      expect(find.byKey(const Key('memberDataTitle')), findsOneWidget);
      expect(find.byKey(const Key('memberNicknameAction')), findsOneWidget);
      expect(find.byKey(const Key('memberEmailAction')), findsOneWidget);
      expect(find.byKey(const Key('memberBirthdayAction')), findsOneWidget);
      expect(find.byKey(const Key('memberDeactivateAction')), findsOneWidget);
      expect(
        find.byType(SingleChildScrollView),
        size.width < 600 ? findsNothing : findsOneWidget,
      );
      if (size.width >= 600) expect(find.byType(FittedBox), findsNothing);
      if (size.width >= 1200)
        expect(find.byKey(const Key('appTopNavigation')), findsOneWidget);
      if (size.width < 600)
        expect(find.byKey(const Key('mobileNavHome')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shows owner-only pending workflow targets', (tester) async {
    await _setSurface(tester, const Size(1200, 760));
    await tester.pumpWidget(
      _memberDataApp(
        _FakeMemberDataRepository(profile: _profile.copyWithPendingWorkflows()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('待驗證 Email：new.member@example.test'), findsOneWidget);
    expect(find.text('生日更正待審：2008-01-02'), findsOneWidget);
  });

  testWidgets(
    'resizing the same page switches mobile tablet and desktop navigation',
    (tester) async {
      await _setSurface(tester, const Size(599, 900));
      await tester.pumpWidget(_memberDataApp(_FakeMemberDataRepository()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mobileNavHome')), findsOneWidget);
      for (final width in [600.0, 1199.0, 1200.0, 599.0]) {
        await tester.binding.setSurfaceSize(Size(width, 900));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('appTopNavigation')),
          width >= 1200 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('mobileNavHome')),
          width < 600 ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('updates nickname only after community impact confirmation', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1200, 760));
    final repository = _FakeMemberDataRepository();
    await tester.pumpWidget(_memberDataApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('memberNicknameAction')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('memberNicknameField')), '新貘友');
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('memberNicknameSubmit')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('我了解既有社群內容也會更新'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('memberNicknameSubmit')));
    await tester.pumpAndSettle();

    expect(repository.updatedNickname, '新貘友');
    expect(repository.expectedVersion, 4);
    expect(find.text('新貘友'), findsOneWidget);
  });

  testWidgets('sensitive dialog enables password and Google reauthentication', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1200, 760));
    await tester.pumpWidget(_memberDataApp(_FakeMemberDataRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('memberEmailAction')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('memberSensitiveValueField')),
      'new.member@example.test',
    );
    await tester.pump();

    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const Key('memberSensitiveGoogleSubmit')),
          )
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('memberSensitivePasswordSubmit')),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const Key('memberSensitivePasswordField')),
      'synthetic-password',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('memberSensitivePasswordSubmit')),
          )
          .onPressed,
      isNotNull,
    );
  });
}

Widget _memberDataApp(
  MemberDataRepository repository, {
  String initialLocation = AppPath.profile,
}) {
  return ProviderScope(
    overrides: [
      memberDataRepositoryProvider.overrideWithValue(repository),
      googleSignInServiceProvider.overrideWithValue(_FakeGoogleSignInService()),
    ],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: initialLocation),
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async => tester.binding.setSurfaceSize(null));
}

class _FakeMemberDataRepository extends MemberDataRepository {
  _FakeMemberDataRepository({MemberProfile profile = _profile})
    : _current = profile,
      super(
        _dummyClient(),
        sessionStore: const WebCookieSessionCredentialStore(),
      );

  MemberProfile _current;
  String? updatedNickname;
  int? expectedVersion;
  int reauthCalls = 0;
  String? reauthPurpose;
  Completer<MemberReauthentication>? pendingReauthentication;

  @override
  Future<MemberReauthentication> reauthenticateWithGoogle({
    required String idToken,
    required String purpose,
  }) async {
    reauthCalls++;
    reauthPurpose = purpose;
    return pendingReauthentication?.future ??
        Future.value(
          MemberReauthentication(
            credential: 'purpose-bound-proof',
            purpose: purpose,
            expiresIn: 300,
          ),
        );
  }

  @override
  Future<MemberProfile> getProfile() async => _current;

  @override
  Future<MemberProfile> updatePublicNickname({
    required String publicNickname,
    required int expectedVersion,
  }) async {
    updatedNickname = publicNickname;
    this.expectedVersion = expectedVersion;
    _current = MemberProfile(
      publicId: _current.publicId,
      email: _current.email,
      publicNickname: publicNickname,
      birthday: _current.birthday,
      serviceRegion: _current.serviceRegion,
      eligibilityStatus: _current.eligibilityStatus,
      communityEligibilityStatus: _current.communityEligibilityStatus,
      memberState: _current.memberState,
      version: expectedVersion + 1,
      pendingEmailChange: _current.pendingEmailChange,
      pendingBirthdayCorrection: _current.pendingBirthdayCorrection,
    );
    return _current;
  }
}

class _FakeGoogleSignInService extends GoogleSignInService {
  _FakeGoogleSignInService() : super(config: _config);

  @override
  Future<void> initialize() async {}

  @override
  Stream<String> get idTokenEvents => const Stream.empty();
}

class _EventGoogleSignInService extends _FakeGoogleSignInService {
  final events = StreamController<String>.broadcast();

  @override
  Stream<String> get idTokenEvents => events.stream;
}

extension on MemberProfile {
  MemberProfile copyWithPendingWorkflows() {
    return MemberProfile(
      publicId: publicId,
      email: email,
      publicNickname: publicNickname,
      birthday: birthday,
      serviceRegion: serviceRegion,
      eligibilityStatus: eligibilityStatus,
      communityEligibilityStatus: communityEligibilityStatus,
      memberState: memberState,
      version: version,
      pendingEmailChange: const MemberWorkflowSummary(
        requestId: 'email-request',
        status: 'PENDING_VERIFICATION',
        target: 'new.member@example.test',
      ),
      pendingBirthdayCorrection: const MemberWorkflowSummary(
        requestId: 'birthday-request',
        status: 'PENDING_REVIEW',
        target: '2008-01-02',
      ),
    );
  }
}

const _profile = MemberProfile(
  publicId: '00000000-0000-0000-0000-000000000001',
  email: 'member@example.test',
  publicNickname: '貘友',
  birthday: '2000-01-02',
  serviceRegion: 'TW',
  eligibilityStatus: 'ADULT',
  communityEligibilityStatus: 'ELIGIBLE',
  memberState: 'ACTIVE',
  version: 4,
);

const _config = AppConfig(
  apiBaseUrl: 'http://example.com/api',
  connectTimeout: Duration(seconds: 1),
  receiveTimeout: Duration(seconds: 1),
  sendTimeout: Duration(seconds: 1),
);

ApiClient _dummyClient() => ApiClient(config: _config, dio: Dio());
