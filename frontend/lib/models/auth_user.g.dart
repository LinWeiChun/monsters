// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
  publicId: json['publicId'] as String?,
  userId: (json['userId'] as num?)?.toInt(),
  email: json['email'] as String,
  userName: json['userName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
  'publicId': instance.publicId,
  'userId': instance.userId,
  'email': instance.email,
  'userName': instance.userName,
  'avatarUrl': instance.avatarUrl,
};
