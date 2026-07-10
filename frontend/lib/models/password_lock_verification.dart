import 'package:json_annotation/json_annotation.dart';

part 'password_lock_verification.g.dart';

@JsonSerializable()
class PasswordLockVerification {
  const PasswordLockVerification({required this.verified});

  factory PasswordLockVerification.fromJson(Map<String, dynamic> json) =>
      _$PasswordLockVerificationFromJson(json);

  final bool verified;

  Map<String, dynamic> toJson() => _$PasswordLockVerificationToJson(this);
}
