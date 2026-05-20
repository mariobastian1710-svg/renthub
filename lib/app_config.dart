class AppConfig {
  // Set this to your deployed base URL.
  // Example: https://your-api.com
  static const String baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: 'https://example.com');
}

