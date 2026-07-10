class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    this.googleClientId = '',
    this.googleServerClientId = '',
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080/api',
      ),
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 20),
      sendTimeout: Duration(seconds: 20),
      googleClientId: String.fromEnvironment('GOOGLE_CLIENT_ID'),
      googleServerClientId: String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
    );
  }

  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final String googleClientId;
  final String googleServerClientId;
}
