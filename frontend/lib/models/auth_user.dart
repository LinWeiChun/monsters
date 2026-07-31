import 'package:json_annotation/json_annotation.dart';

part 'auth_user.g.dart';

@JsonSerializable()
class AuthUser {
  const AuthUser({
    this.publicId,
    this.userId,
    required this.email,
    required this.userName,
    required this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  final String? publicId;
  final int? userId;
  final String email;
  final String userName;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);
}
