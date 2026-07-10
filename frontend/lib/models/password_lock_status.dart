import 'package:json_annotation/json_annotation.dart';

part 'password_lock_status.g.dart';

@JsonSerializable()
class PasswordLockStatus {
  const PasswordLockStatus({required this.enabled});

  factory PasswordLockStatus.fromJson(Map<String, dynamic> json) =>
      _$PasswordLockStatusFromJson(json);

  final bool enabled;

  Map<String, dynamic> toJson() => _$PasswordLockStatusToJson(this);
}
