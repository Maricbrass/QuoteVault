import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../domain/user.dart';

/// Repository for authentication operations
/// Handles all auth-related business logic and data transformations
class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Get current authenticated user
  User? get currentUser {
    final supabaseUser = _supabaseService.currentUser;
    if (supabaseUser == null) return null;
    return _mapSupabaseUserToDomain(supabaseUser);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges {
    return _supabaseService.authStateChanges.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return _mapSupabaseUserToDomain(user);
    });
  }

  /// Sign in with email and password
  Future<User> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException.invalidCredentials();
      }

      return _mapSupabaseUserToDomain(response.user!);
    } on supabase.AuthException catch (e, stackTrace) {
      appLogger.error('Auth error during sign in', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error during sign in', e, stackTrace);
      throw AuthException.fromError(e);
    }
  }

  /// Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw const AuthException(
          message: 'Sign up failed',
          code: 'signup_failed',
        );
      }

      return _mapSupabaseUserToDomain(response.user!);
    } on supabase.AuthException catch (e, stackTrace) {
      appLogger.error('Auth error during sign up', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error during sign up', e, stackTrace);
      throw AuthException.fromError(e);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } on supabase.AuthException catch (e, stackTrace) {
      appLogger.error('Auth error during sign out', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error during sign out', e, stackTrace);
      throw AuthException.fromError(e);
    }
  }

  /// Reset password for email
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e, stackTrace) {
      appLogger.error('Auth error during password reset', e, stackTrace);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error during password reset', e, stackTrace);
      throw AuthException.fromError(e);
    }
  }

  /// Map Supabase User to domain User model
  User _mapSupabaseUserToDomain(supabase.User supabaseUser) {
    final createdAt = supabaseUser.createdAt;
    final updatedAt = supabaseUser.updatedAt;

    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt) : null,
    );
  }

  /// Handle Supabase auth exceptions and convert to app exceptions
  AuthException _handleAuthException(supabase.AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.toLowerCase().contains('invalid')) {
          return AuthException.invalidCredentials();
        }
        return AuthException(message: e.message, code: e.statusCode);
      case '401':
        return AuthException.invalidCredentials();
      case '404':
        return AuthException.userNotFound();
      case '422':
        if (e.message.toLowerCase().contains('already registered')) {
          return AuthException.emailAlreadyInUse();
        }
        return AuthException(message: e.message, code: e.statusCode);
      default:
        return AuthException(
          message: e.message,
          code: e.statusCode,
          originalError: e,
        );
    }
  }
}

