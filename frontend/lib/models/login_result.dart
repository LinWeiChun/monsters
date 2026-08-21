import 'package:json_annotation/json_annotation.dart';

import 'auth_user.dart';

part 'login_result.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginResult {
  const LoginResult({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    required this.expiresIn,
    this.user,
    this.nextAction,
    this.continuationCredential,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int expiresIn;
  final AuthUser? user;
  final String? nextAction;
  final String? continuationCredential;

  bool get isAuthenticated =>
      accessToken != null && tokenType != null && user != null;

  bool get requiresContinuation =>
      continuationCredential != null && nextAction != null && !isAuthenticated;

  bool get requiresGoogleAccountLink =>
      nextAction == 'LINK_GOOGLE_ACCOUNT' && !isAuthenticated;

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
