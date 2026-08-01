class EligibilityDocument {
  const EligibilityDocument({required this.version, required this.url});
  factory EligibilityDocument.fromJson(Map<String, dynamic> json) =>
      EligibilityDocument(
        version: json['version'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
  final String version;
  final String url;
}

class EligibilityPolicy {
  const EligibilityPolicy({
    required this.serviceRegion,
    required this.minimumAge,
    required this.adultAge,
    required this.minorNotice,
    required this.guardianConsent,
    required this.publicNicknameDisclosure,
  });
  factory EligibilityPolicy.fromJson(Map<String, dynamic> json) =>
      EligibilityPolicy(
        serviceRegion: json['serviceRegion'] as String,
        minimumAge: json['minimumAge'] as int,
        adultAge: json['adultAge'] as int,
        minorNotice: EligibilityDocument.fromJson(
          json['minorNotice'] as Map<String, dynamic>,
        ),
        guardianConsent: EligibilityDocument.fromJson(
          json['guardianConsent'] as Map<String, dynamic>,
        ),
        publicNicknameDisclosure: EligibilityDocument.fromJson(
          json['publicNicknameDisclosure'] as Map<String, dynamic>,
        ),
      );
  final String serviceRegion;
  final int minimumAge;
  final int adultAge;
  final EligibilityDocument minorNotice;
  final EligibilityDocument guardianConsent;
  final EligibilityDocument publicNicknameDisclosure;
}

class EligibilityOutcome {
  const EligibilityOutcome({
    required this.eligibilityStatus,
    required this.communityEligibilityStatus,
    required this.nextAction,
    this.consentReference,
  });
  factory EligibilityOutcome.fromJson(Map<String, dynamic> json) =>
      EligibilityOutcome(
        eligibilityStatus: json['eligibilityStatus'] as String,
        communityEligibilityStatus:
            json['communityEligibilityStatus'] as String,
        nextAction: json['nextAction'] as String,
        consentReference: json['consentReference'] as String?,
      );
  final String eligibilityStatus;
  final String communityEligibilityStatus;
  final String nextAction;
  final String? consentReference;
}

class EligibilityRouteData {
  const EligibilityRouteData(this.continuationCredential);
  final String continuationCredential;
}

class GuardianConsentAction {
  const GuardianConsentAction({
    required this.purpose,
    required this.status,
    required this.consentReference,
  });
  factory GuardianConsentAction.fromJson(Map<String, dynamic> json) =>
      GuardianConsentAction(
        purpose: json['purpose'] as String,
        status: json['status'] as String,
        consentReference: json['consentReference'] as String,
      );
  final String purpose;
  final String status;
  final String consentReference;
}
