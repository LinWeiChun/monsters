import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_result.dart';

class AuthSessionStore {
  const AuthSessionStore();

  static const Duration sessionTimeout = Duration(days: 30);
  static const String _loginResultKey = 'auth.loginResult';
  static const String _lastOpenedAtKey = 'auth.lastOpenedAt';

  Future<void> saveSession(LoginResult loginResult, {DateTime? now}) async {
    if (!loginResult.isAuthenticated) {
      throw ArgumentError.value(
        loginResult,
        'loginResult',
        'Only authenticated sessions can be saved',
      );
    }
    final preferences = await SharedPreferences.getInstance();
    final openedAt = now ?? DateTime.now();

    await preferences.setString(
      _loginResultKey,
      jsonEncode(loginResult.toJson()),
    );
    await preferences.setString(_lastOpenedAtKey, openedAt.toIso8601String());
  }

  Future<LoginResult?> restoreValidSession({DateTime? now}) async {
    final preferences = await SharedPreferences.getInstance();
    final loginResultJson = preferences.getString(_loginResultKey);
    final lastOpenedAtValue = preferences.getString(_lastOpenedAtKey);

    if (loginResultJson == null || lastOpenedAtValue == null) {
      return null;
    }

    final currentTime = now ?? DateTime.now();
    final lastOpenedAt = DateTime.tryParse(lastOpenedAtValue);
    if (lastOpenedAt == null ||
        currentTime.difference(lastOpenedAt) > sessionTimeout) {
      await clearSession();
      return null;
    }

    try {
      final decoded = jsonDecode(loginResultJson);
      if (decoded is! Map<String, dynamic>) {
        await clearSession();
        return null;
      }

      final loginResult = LoginResult.fromJson(decoded);
      await preferences.setString(
        _lastOpenedAtKey,
        currentTime.toIso8601String(),
      );
      return loginResult;
    } on Object {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_loginResultKey);
    await preferences.remove(_lastOpenedAtKey);
  }
}
