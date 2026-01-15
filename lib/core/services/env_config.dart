import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Service for managing environment variables
/// Provides type-safe access to configuration values
class EnvConfig {
  EnvConfig._();

  static bool _isInitialized = false;

  /// Initialize environment configuration
  /// Must be called before accessing any environment variables
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      appLogger.info('Environment configuration loaded successfully');
    } catch (e, stackTrace) {
      appLogger.error(
        'Failed to load .env file. Using fallback values.',
        e,
        stackTrace,
      );
      // App can still run with hardcoded fallbacks or fail gracefully
      _isInitialized = true;
    }
  }

  /// Get Supabase URL
  static String get supabaseUrl {
    _ensureInitialized();
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      appLogger.warning('SUPABASE_URL not found in environment');
      throw Exception(
        'SUPABASE_URL is not configured. Please check your .env file.',
      );
    }
    return url;
  }

  /// Get Supabase Anonymous Key
  static String get supabaseAnonKey {
    _ensureInitialized();
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      appLogger.warning('SUPABASE_ANON_KEY not found in environment');
      throw Exception(
        'SUPABASE_ANON_KEY is not configured. Please check your .env file.',
      );
    }
    return key;
  }

  /// Ensure config is initialized before accessing variables
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'EnvConfig not initialized. Call EnvConfig.init() first.',
      );
    }
  }

  /// Check if environment is properly configured
  static bool get isConfigured {
    if (!_isInitialized) return false;

    try {
      final url = dotenv.env['SUPABASE_URL'];
      final key = dotenv.env['SUPABASE_ANON_KEY'];
      return url != null && url.isNotEmpty &&
             key != null && key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

