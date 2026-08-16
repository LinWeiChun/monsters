class DeviceSession {
  const DeviceSession({
    required this.sessionId,
    required this.deviceType,
    required this.deviceSummary,
    required this.lastActivityAt,
    required this.current,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      sessionId: json['sessionId'] as String,
      deviceType: json['deviceType'] as String,
      deviceSummary: json['deviceSummary'] as String,
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      current: json['current'] as bool? ?? false,
    );
  }

  final String sessionId;
  final String deviceType;
  final String deviceSummary;
  final DateTime lastActivityAt;
  final bool current;
}

class DeviceSessionPage {
  const DeviceSessionPage({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
  });

  factory DeviceSessionPage.fromJson(Map<String, dynamic> json) {
    return DeviceSessionPage(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => DeviceSession.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 3,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  final List<DeviceSession> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
}

class SessionReauthentication {
  const SessionReauthentication({
    required this.credential,
    required this.purpose,
    required this.expiresIn,
  });

  factory SessionReauthentication.fromJson(Map<String, dynamic> json) {
    return SessionReauthentication(
      credential: json['credential'] as String,
      purpose: json['purpose'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }

  final String credential;
  final String purpose;
  final int expiresIn;
}
