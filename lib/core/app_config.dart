class AppConfig {
  // VPS API base URL. You can override via --dart-define API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://160.22.161.184:5000',
  );
}
