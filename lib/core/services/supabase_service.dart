import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import 'env_config.dart';

/// Singleton service for managing Supabase client
/// Provides centralized access to Supabase functionality
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  /// Get singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase
  /// Must be called once during app startup
  static Future<void> initialize() async {
    try {
      appLogger.info('Initializing Supabase...');

      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        debug: false, // Set to true for detailed logs during development
      );

      _client = Supabase.instance.client;
      appLogger.info('Supabase initialized successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to initialize Supabase', e, stackTrace);
      rethrow;
    }
  }

  /// Get Supabase client
  /// Throws if not initialized
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  bool get isInitialized => _client != null;

  /// Get auth client
  GoTrueClient get auth => client.auth;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current session
  Session? get currentSession => auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      appLogger.info('Attempting sign in for: $email');
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );
      appLogger.info('Sign in successful');
      return response;
    } catch (e, stackTrace) {
      appLogger.error('Sign in failed', e, stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      appLogger.info('Attempting sign up for: $email');
      final response = await auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      appLogger.info('Sign up successful');
      return response;
    } catch (e, stackTrace) {
      appLogger.error('Sign up failed', e, stackTrace);
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      appLogger.info('Signing out user');
      await auth.signOut();
      appLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      appLogger.error('Sign out failed', e, stackTrace);
      rethrow;
    }
  }

  /// Reset password for email
  Future<void> resetPasswordForEmail(String email) async {
    try {
      appLogger.info('Password reset requested for: $email');
      await auth.resetPasswordForEmail(email);
      appLogger.info('Password reset email sent');
    } catch (e, stackTrace) {
      appLogger.error('Password reset failed', e, stackTrace);
      rethrow;
    }
  }
}

