import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionCredentialStore {
  bool get usesCookieTransport;

  Future<void> saveRefreshCredential(String refreshCredential);

  Future<String?> readRefreshCredential();

  Future<void> clearRefreshCredential();
}

abstract interface class SecureCredentialAdapter {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}

class FlutterSecureCredentialAdapter implements SecureCredentialAdapter {
  const FlutterSecureCredentialAdapter({
    FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        storageNamespace: 'monsters.auth.session',
        migrateWithBackup: false,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
    ),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }
}

class WebCookieSessionCredentialStore implements SessionCredentialStore {
  const WebCookieSessionCredentialStore();

  @override
  bool get usesCookieTransport => true;

  @override
  Future<void> saveRefreshCredential(String refreshCredential) async {}

  @override
  Future<String?> readRefreshCredential() async => null;

  @override
  Future<void> clearRefreshCredential() async {}
}

abstract class _SecureSessionCredentialStore implements SessionCredentialStore {
  const _SecureSessionCredentialStore(this._adapter);

  static const String _refreshCredentialKey = 'auth.refreshCredential';

  final SecureCredentialAdapter _adapter;

  @override
  bool get usesCookieTransport => false;

  @override
  Future<void> saveRefreshCredential(String refreshCredential) {
    return _adapter.write(key: _refreshCredentialKey, value: refreshCredential);
  }

  @override
  Future<String?> readRefreshCredential() {
    return _adapter.read(key: _refreshCredentialKey);
  }

  @override
  Future<void> clearRefreshCredential() {
    return _adapter.delete(key: _refreshCredentialKey);
  }
}

class AndroidSessionCredentialStore extends _SecureSessionCredentialStore {
  const AndroidSessionCredentialStore(super.adapter);
}

class IosSessionCredentialStore extends _SecureSessionCredentialStore {
  const IosSessionCredentialStore(super.adapter);
}

SessionCredentialStore createSessionCredentialStore({
  bool isWeb = kIsWeb,
  TargetPlatform? targetPlatform,
  SecureCredentialAdapter secureAdapter =
      const FlutterSecureCredentialAdapter(),
}) {
  if (isWeb) {
    return const WebCookieSessionCredentialStore();
  }

  return switch (targetPlatform ?? defaultTargetPlatform) {
    TargetPlatform.android => AndroidSessionCredentialStore(secureAdapter),
    TargetPlatform.iOS => IosSessionCredentialStore(secureAdapter),
    final platform =>
      throw UnsupportedError(
        'Session credential storage is unsupported on ${platform.name}',
      ),
  };
}
