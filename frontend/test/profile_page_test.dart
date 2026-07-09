import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/config/app_config.dart';
import 'package:monsters/core/network/api_client.dart';
import 'package:monsters/core/network/api_error_type.dart';
import 'package:monsters/core/network/api_exception.dart';
import 'package:monsters/models/user_profile.dart';
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

  testWidgets('validates profile form fields', (tester) async {
    await tester.pumpWidget(_profileApp(_FakeUserRepository()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profileUserNameField')), '');
    await tester.enterText(
      find.byKey(const Key('profileBirthdayField')),
      '2000/01/02',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('請輸入暱稱'), findsOneWidget);
    expect(find.text('生日格式需為 yyyy-MM-dd'), findsOneWidget);
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
    await tester.enterText(
      find.byKey(const Key('profileBirthdayField')),
      '2001-03-04',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.updatedUserName, 'Lin');
    expect(repository.updatedBirthday, '2001-03-04');
    expect(find.text('個人資料已更新'), findsOneWidget);
    expect(find.text('Lin'), findsWidgets);
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

    await tester.tap(find.byKey(const Key('homeProfileButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profileUserNameField')), findsOneWidget);
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
