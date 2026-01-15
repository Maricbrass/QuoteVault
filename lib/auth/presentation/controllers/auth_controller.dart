import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/auth_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/user.dart';
import '../auth_providers.dart';

/// State for authentication operations
class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AuthState clearMessages() {
    return AuthState(
      isLoading: isLoading,
      user: user,
    );
  }
}

/// Controller for authentication operations
/// Handles login, signup, logout, and password reset
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  AuthController(
    this._authRepository,
    this._profileRepository,
  ) : super(const AuthState());

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Attempting sign in for: $email');
      final user = await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Welcome back!',
      );
      appLogger.info('Sign in successful');
    } catch (e, stackTrace) {
      appLogger.error('Sign in failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Attempting sign up for: $email');

      // Create auth account
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      // Profile is automatically created via Supabase trigger
      // But we'll verify it exists and fetch it
      await Future.delayed(const Duration(milliseconds: 500));

      final profileExists = await _profileRepository.profileExists(user.id);
      if (!profileExists) {
        appLogger.warning('Profile not auto-created, creating manually');
        await _profileRepository.createProfile(
          userId: user.id,
          email: email,
          name: name,
        );
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Account created successfully!',
      );
      appLogger.info('Sign up successful');
    } catch (e, stackTrace) {
      appLogger.error('Sign up failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Signing out user');
      await _authRepository.signOut();

      state = const AuthState(
        successMessage: 'Signed out successfully',
      );
      appLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      appLogger.error('Sign out failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Sending password reset email to: $email');
      await _authRepository.resetPassword(email);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password reset email sent. Please check your inbox.',
      );
      appLogger.info('Password reset email sent');
    } catch (e, stackTrace) {
      appLogger.error('Password reset failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }

  /// Extract user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }

    // Remove "AuthException: " prefix if present
    if (errorString.startsWith('AuthException: ')) {
      return errorString.substring(15);
    }

    return errorString;
  }
}

/// Provider for profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Provider for auth controller
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  return AuthController(authRepository, profileRepository);
});

