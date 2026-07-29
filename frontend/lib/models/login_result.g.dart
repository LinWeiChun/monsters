// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => LoginResult(
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  tokenType: json['tokenType'] as String?,
  expiresIn: (json['expiresIn'] as num).toInt(),
  user:
      json['user'] == null
          ? null
          : AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  nextAction: json['nextAction'] as String?,
  continuationCredential: json['continuationCredential'] as String?,
);

Map<String, dynamic> _$LoginResultToJson(LoginResult instance) =>
    <String, dynamic>{
      if (instance.accessToken case final value?) 'accessToken': value,
      if (instance.refreshToken case final value?) 'refreshToken': value,
      if (instance.tokenType case final value?) 'tokenType': value,
      'expiresIn': instance.expiresIn,
      if (instance.user case final value?) 'user': value,
      if (instance.nextAction case final value?) 'nextAction': value,
      if (instance.continuationCredential case final value?)
        'continuationCredential': value,
    };
