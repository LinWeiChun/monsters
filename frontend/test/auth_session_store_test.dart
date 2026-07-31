import 'package:flutter_test/flutter_test.dart';
import 'package:monsters/models/auth_user.dart';
import 'package:monsters/models/login_result.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthSessionStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = const AuthSessionStore();
  });

  test(
    'restores session within thirty days and updates last opened time',
    () async {
      final savedAt = DateTime(2026, 7, 1);
      final openedAt = DateTime(2026, 7, 10);

      await store.saveSession(_loginResult, now: savedAt);

      final restored = await store.restoreValidSession(now: openedAt);

      expect(restored?.accessToken, _loginResult.accessToken);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('auth.lastOpenedAt'),
        openedAt.toIso8601String(),
      );
    },
  );

  test('clears and ignores session after more than thirty days', () async {
    await store.saveSession(_loginResult, now: DateTime(2026, 5, 1));

    final restored = await store.restoreValidSession(
      now: DateTime(2026, 7, 10),
    );

    expect(restored, isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('auth.loginResult'), isNull);
    expect(preferences.getString('auth.lastOpenedAt'), isNull);
  });
}

const _loginResult = LoginResult(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  tokenType: 'Bearer',
  expiresIn: 3600,
  user: AuthUser(
    publicId: '00000000-0000-0000-0000-000000000001',
    userId: 1,
    email: 'user@example.com',
    userName: 'Wei',
    avatarUrl: null,
  ),
);
