class MemberReauthentication {
  const MemberReauthentication({
    required this.credential,
    required this.purpose,
    required this.expiresIn,
  });

  factory MemberReauthentication.fromJson(Map<String, dynamic> json) {
    return MemberReauthentication(
      credential: json['credential']! as String,
      purpose: json['purpose']! as String,
      expiresIn: (json['expiresIn']! as num).toInt(),
    );
  }

  final String credential;
  final String purpose;
  final int expiresIn;
}

class BirthdayCorrectionResult {
  const BirthdayCorrectionResult({
    required this.requestId,
    required this.status,
    required this.restricted,
    required this.memberState,
    required this.version,
  });

  factory BirthdayCorrectionResult.fromJson(Map<String, dynamic> json) {
    return BirthdayCorrectionResult(
      requestId: json['requestId']! as String,
      status: json['status']! as String,
      restricted: json['restricted']! as bool,
      memberState: json['memberState']! as String,
      version: (json['version']! as num).toInt(),
    );
  }

  final String requestId;
  final String status;
  final bool restricted;
  final String memberState;
  final int version;
}

class MemberStateResult {
  const MemberStateResult({
    required this.memberState,
    required this.version,
    this.nextAction,
  });

  factory MemberStateResult.fromJson(Map<String, dynamic> json) {
    return MemberStateResult(
      memberState: json['memberState']! as String,
      version: (json['version']! as num).toInt(),
      nextAction: json['nextAction'] as String?,
    );
  }

  final String memberState;
  final int version;
  final String? nextAction;
}
