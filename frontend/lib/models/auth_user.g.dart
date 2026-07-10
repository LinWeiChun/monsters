// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
  userId: (json['userId'] as num).toInt(),
  account: json['account'] as String,
  email: json['email'] as String,
  userName: json['userName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
  'userId': instance.userId,
  'account': instance.account,
  'email': instance.email,
  'userName': instance.userName,
  'avatarUrl': instance.avatarUrl,
};
