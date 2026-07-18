import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/user_profile.dart';
import 'package:monsters/pages/profile_page.dart';
import 'package:monsters/providers/user_profile_provider.dart';
import 'package:monsters/repositories/user_repository.dart';
import 'package:monsters/routes/app_router.dart';
import 'package:monsters/routes/app_routes.dart';

void main() {
  testWidgets('loads and shows current user profile', (tester) async {
    await tester.pumpWidget(_profileApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    expect(find.text('個人資料'), findsWidgets);
    expect(find.byKey(const Key('profileAvatar')), findsOneWidget);
    expect(find.byKey(const Key('profileDisplayName')), findsOneWidget);
    expect(find.text('Wei'), findsWidgets);
    expect(find.text('user@example.com'), findsWidgets);
    expect(find.text('2000-01-02'), findsWidgets);
  });

  for (final size in const [Size(500, 844), Size(599, 900)]) {
    testWidgets('mobile profile canvas fills viewport width at $size', (
      tester,
    ) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(_profileApp(_FakeUserRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profileAvatar')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('profileMobileViewport'))).width,
        size.width,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [
    Size(600, 700),
    Size(900, 700),
    Size(1024, 768),
    Size(1199, 800),
    Size(1440, 900),
    Size(1920, 1080),
  ]) {
    testWidgets('profile uses flow layout without clipping at $size', (
      tester,
    ) async {
      await _setSurface(tester, size);
      await tester.pumpWidget(_profileApp(_FakeUserRepository()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profileAvatar')), findsOneWidget);
      expect(find.byKey(const Key('profileUserNameField')), findsOneWidget);
      expect(find.byKey(const Key('profileBirthdayField')), findsOneWidget);
      expect(find.byKey(const Key('profileSaveButton')), findsOneWidget);
      expect(find.byKey(const Key('profileLogoutButton')), findsOneWidget);
      if (size.width >= 1200) {
        expect(find.byKey(const Key('appTopNavigation')), findsOneWidget);
        expect(find.byKey(const Key('appTopNavProfile')), findsOneWidget);
      }
      expect(
        tester.getSize(find.byKey(const Key('profileResponsiveShell'))).width,
        size.width,
      );
      expect(find.byType(FittedBox), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('validates profile form fields', (tester) async {
    await tester.pumpWidget(_profileApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profileUserNameField')), '');
    await tester.tap(find.byKey(const Key('profileSaveButton')));
    await tester.pumpAndSettle();

    expect(find.text('請輸入暱稱'), findsOneWidget);
  });

  testWidgets('selects birthday from the calendar', (tester) async {
    await _setSurface(tester, const Size(1024, 768));
    await tester.pumpWidget(_profileApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    final birthdayField = find.byKey(const Key('profileBirthdayField'));
    await tester.ensureVisible(birthdayField);
    await tester.tap(birthdayField);
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.text('選擇生日'), findsOneWidget);
    await tester.tap(find.text('15'));
    await tester.tap(find.text('確定'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(birthdayField);
    expect(field.controller?.text, '2000-01-15');
  });

  testWidgets('submits updated profile and shows success message', (
    tester,
  ) async {
    final repository = _FakeUserRepository();
    await tester.pumpWidget(_profileApp(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('profileUserNameField')),
      ' Lin ',
    );
    await tester.tap(find.byKey(const Key('profileSaveButton')));
    await tester.pumpAndSettle();

    expect(repository.updatedUserName, 'Lin');
    expect(repository.updatedBirthday, '2000-01-02');
    expect(find.text('個人資料已更新'), findsOneWidget);
    expect(find.text('Lin'), findsWidgets);
  });

  testWidgets('shows logout confirmation from profile', (tester) async {
    await _setSurface(tester, const Size(1024, 768));
    await tester.pumpWidget(_profileApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profileLogoutButton')));
    await tester.pumpAndSettle();

    expect(find.text('確認登出'), findsOneWidget);
    expect(find.byKey(const Key('profileConfirmLogoutButton')), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('確認登出'), findsNothing);
  });

  testWidgets('shows load error state with retry action', (tester) async {
    await tester.pumpWidget(
      _profileApp(
        _FakeUserRepository(
          loadException: const ApiException(
            type: ApiErrorType.unauthorized,
            message: '尚未登入或 Token 無效',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('尚未登入或 Token 無效'), findsOneWidget);
    expect(find.text('重試'), findsOneWidget);
  });

  testWidgets('home profile action navigates to profile route', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
        ],
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mobileNavProfile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profileUserNameField')), findsOneWidget);
  });

  testWidgets('forward navigation is immediate and back exits to the right', (
    tester,
  ) async {
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(_FakeUserRepository()),
        ],
        child: MaterialApp.router(
          routerConfig: createAppRouter(initialLocation: AppPath.home),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mobileNavProfile')));
    await tester.pump();
    expect(find.byType(ProfilePage), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profileBackButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.getTopLeft(find.byKey(const Key('profileMobileViewport'))).dx,
      greaterThan(0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mobileCompanionHero')), findsOneWidget);
  });
}

Widget _profileApp(UserRepository userRepository) {
  return ProviderScope(
    overrides: [userRepositoryProvider.overrideWithValue(userRepository)],
    child: MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: AppPath.profile),
    ),
  );
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository({this.loadException}) : super(_dummyClient());

  final ApiException? loadException;
  String? updatedUserName;
  String? updatedBirthday;

  @override
  Future<UserProfile> getProfile() async {
    final exception = loadException;
    if (exception != null) {
      throw exception;
    }

    return const UserProfile(
      userId: 1,
      account: 'old-account',
      email: 'user@example.com',
      userName: 'Wei',
      birthday: '2000-01-02',
      avatarUrl: null,
    );
  }

  @override
  Future<UserProfile> updateProfile({
    required String userName,
    required String? birthday,
  }) async {
    updatedUserName = userName;
    updatedBirthday = birthday;
    return UserProfile(
      userId: 1,
      account: 'old-account',
      email: 'user@example.com',
      userName: userName,
      birthday: birthday,
      avatarUrl: null,
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
