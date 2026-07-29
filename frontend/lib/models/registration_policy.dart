class RegistrationPolicy {
  const RegistrationPolicy({
    required this.termsVersion,
    required this.termsUrl,
    required this.privacyVersion,
    required this.privacyUrl,
  });

  factory RegistrationPolicy.fromJson(Map<String, dynamic> json) {
    return RegistrationPolicy(
      termsVersion: json['termsVersion'] as String,
      termsUrl: json['termsUrl'] as String,
      privacyVersion: json['privacyVersion'] as String,
      privacyUrl: json['privacyUrl'] as String,
    );
  }

  final String termsVersion;
  final String termsUrl;
  final String privacyVersion;
  final String privacyUrl;
}
