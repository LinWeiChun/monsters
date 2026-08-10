import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:monsters/repositories/auth_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'web cookie store never persists or exposes refresh credential',
    () async {
      const store = WebCookieSessionCredentialStore();

      await store.saveRefreshCredential('web-refresh-credential');

      expect(store.usesCookieTransport, isTrue);
      expect(await store.readRefreshCredential(), isNull);
      await store.clearRefreshCredential();
    },
  );

  test('platform factory selects web, Android, and iOS adapters', () {
    final adapter = _MemorySecureCredentialAdapter();

    expect(
      createSessionCredentialStore(isWeb: true, secureAdapter: adapter),
      isA<WebCookieSessionCredentialStore>(),
    );
    expect(
      createSessionCredentialStore(
        isWeb: false,
        targetPlatform: TargetPlatform.android,
        secureAdapter: adapter,
      ),
      isA<AndroidSessionCredentialStore>(),
    );
    expect(
      createSessionCredentialStore(
        isWeb: false,
        targetPlatform: TargetPlatform.iOS,
        secureAdapter: adapter,
      ),
      isA<IosSessionCredentialStore>(),
    );
  });

  for (final testCase
      in <(String, SessionCredentialStore Function(SecureCredentialAdapter))>[
        (
          'Android Keystore adapter',
          (adapter) => AndroidSessionCredentialStore(adapter),
        ),
        (
          'iOS Keychain adapter',
          (adapter) => IosSessionCredentialStore(adapter),
        ),
      ]) {
    test('${testCase.$1} persists only the refresh credential', () async {
      final adapter = _MemorySecureCredentialAdapter();
      final store = testCase.$2(adapter);

      await store.saveRefreshCredential('app-refresh-credential');

      expect(store.usesCookieTransport, isFalse);
      expect(await store.readRefreshCredential(), 'app-refresh-credential');
      expect(adapter.values, {
        'auth.refreshCredential': 'app-refresh-credential',
      });
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), isEmpty);

      await store.clearRefreshCredential();
      expect(await store.readRefreshCredential(), isNull);
    });
  }
}

class _MemorySecureCredentialAdapter implements SecureCredentialAdapter {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
