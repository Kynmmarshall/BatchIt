class AppConstants {
  // API Configuration
  // Override with: --dart-define=API_BASE_URL=http://38.242.246.126/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://38.242.246.126/api',
  );
  static const Duration apiTimeout = Duration(seconds: 30);

  // App Constants
  static const double nearbyRadiusMeters = 500;
  static const double defaultBulkSizeKg = 50;
  static const String defaultCurrency = 'MAD';
}
