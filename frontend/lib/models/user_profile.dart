import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.userName,
    this.account,
    this.birthday,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  final int userId;
  final String? account;
  final String email;
  final String userName;
  final String? birthday;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
