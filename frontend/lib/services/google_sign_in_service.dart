import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_config.dart';

class GoogleSignInService {
  GoogleSignInService({required AppConfig config, GoogleSignIn? googleSignIn})
    : _config = config,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final AppConfig _config;
  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  Stream<String> get idTokenEvents async* {
    await initialize();

    await for (final event in _googleSignIn.authenticationEvents) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        yield _idTokenFromAccount(event.user);
      }
    }
  }

  Future<void> initialize() {
    return _initializeFuture ??= _googleSignIn.initialize(
      clientId: _emptyToNull(_config.googleClientId),
      serverClientId: _emptyToNull(_config.googleServerClientId),
    );
  }

  Future<String> signInAndGetIdToken() async {
    await initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleSignInUnsupportedException();
    }

    final account = await _googleSignIn.authenticate();
    return _idTokenFromAccount(account);
  }

  Future<void> signOut() async {
    await initialize();
    await _googleSignIn.signOut();
  }

  String _idTokenFromAccount(GoogleSignInAccount account) {
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const GoogleIdTokenUnavailableException();
    }
    return idToken;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class GoogleSignInUnsupportedException implements Exception {
  const GoogleSignInUnsupportedException();
}

class GoogleIdTokenUnavailableException implements Exception {
  const GoogleIdTokenUnavailableException();
}
