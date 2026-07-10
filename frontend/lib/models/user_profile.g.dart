// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  userId: (json['userId'] as num).toInt(),
  email: json['email'] as String,
  userName: json['userName'] as String,
  account: json['account'] as String?,
  birthday: json['birthday'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'account': instance.account,
      'email': instance.email,
      'userName': instance.userName,
      'birthday': instance.birthday,
      'avatarUrl': instance.avatarUrl,
    };
