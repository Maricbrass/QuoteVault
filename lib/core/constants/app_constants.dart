/// Application-wide constant values
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'QuoteVault';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userPrefsBox = 'user_preferences';

  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

