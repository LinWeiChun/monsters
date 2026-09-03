class MemberWorkflowSummary {
  const MemberWorkflowSummary({
    required this.requestId,
    required this.status,
    this.target,
  });

  factory MemberWorkflowSummary.fromJson(Map<String, dynamic> json) {
    return MemberWorkflowSummary(
      requestId: json['requestId']! as String,
      status: json['status']! as String,
      target: json['target'] as String?,
    );
  }

  final String requestId;
  final String status;
  final String? target;
}

class MemberProfile {
  const MemberProfile({
    required this.publicId,
    required this.email,
    required this.publicNickname,
    required this.birthday,
    required this.serviceRegion,
    required this.eligibilityStatus,
    required this.communityEligibilityStatus,
    required this.memberState,
    required this.version,
    this.pendingEmailChange,
    this.pendingBirthdayCorrection,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    MemberWorkflowSummary? workflow(Object? value) {
      return value is Map<String, dynamic>
          ? MemberWorkflowSummary.fromJson(value)
          : null;
    }

    return MemberProfile(
      publicId: json['publicId']! as String,
      email: json['email']! as String,
      publicNickname: json['publicNickname'] as String? ?? '',
      birthday: json['birthday'] as String?,
      serviceRegion: json['serviceRegion'] as String?,
      eligibilityStatus: json['eligibilityStatus']! as String,
      communityEligibilityStatus: json['communityEligibilityStatus']! as String,
      memberState: json['memberState']! as String,
      version: (json['version']! as num).toInt(),
      pendingEmailChange: workflow(json['pendingEmailChange']),
      pendingBirthdayCorrection: workflow(json['pendingBirthdayCorrection']),
    );
  }

  final String publicId;
  final String email;
  final String publicNickname;
  final String? birthday;
  final String? serviceRegion;
  final String eligibilityStatus;
  final String communityEligibilityStatus;
  final String memberState;
  final int version;
  final MemberWorkflowSummary? pendingEmailChange;
  final MemberWorkflowSummary? pendingBirthdayCorrection;
}
