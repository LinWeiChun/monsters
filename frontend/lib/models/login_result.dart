import 'package:json_annotation/json_annotation.dart';

import 'auth_user.dart';

part 'login_result.g.dart';

@JsonSerializable()
class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
