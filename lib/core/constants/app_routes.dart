/// Route path constants for navigation
class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Quote Routes
  static const String quotes = '/quotes';
  static const String quoteDetail = '/quotes/:id';
  static const String searchQuotes = '/search';
  static const String categoryQuotes = '/quotes/category/:category';

  // Collections Routes
  static const String collections = '/collections';
  static const String collectionDetail = '/collections/:id';

  // Favorites Routes
  static const String favorites = '/favorites';
}

