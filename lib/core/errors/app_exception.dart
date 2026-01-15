/// Base class for all application exceptions
/// Provides a consistent error handling interface across the app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.fromError(dynamic error) {
    if (error is AuthException) return error;

    return AuthException(
      message: error.toString(),
      originalError: error,
    );
  }

  // Common auth exceptions
  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Invalid email or password',
      code: 'invalid_credentials',
    );
  }

  factory AuthException.userNotFound() {
    return const AuthException(
      message: 'User not found',
      code: 'user_not_found',
    );
  }

  factory AuthException.emailAlreadyInUse() {
    return const AuthException(
      message: 'Email already in use',
      code: 'email_in_use',
    );
  }

  factory AuthException.weakPassword() {
    return const AuthException(
      message: 'Password is too weak. Must be at least 8 characters',
      code: 'weak_password',
    );
  }

  factory AuthException.sessionExpired() {
    return const AuthException(
      message: 'Session has expired. Please login again',
      code: 'session_expired',
    );
  }

  factory AuthException.invalidEmail() {
    return const AuthException(
      message: 'Invalid email address',
      code: 'invalid_email',
    );
  }

  factory AuthException.tooManyRequests() {
    return const AuthException(
      message: 'Too many attempts. Please try again later',
      code: 'too_many_requests',
    );
  }

  factory AuthException.emailNotConfirmed() {
    return const AuthException(
      message: 'Please verify your email before signing in',
      code: 'email_not_confirmed',
    );
  }

  factory AuthException.passwordResetFailed() {
    return const AuthException(
      message: 'Failed to send password reset email',
      code: 'password_reset_failed',
    );
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.fromError(dynamic error) {
    if (error is NetworkException) return error;

    return NetworkException(
      message: 'Network error occurred',
      originalError: error,
    );
  }

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection',
      code: 'no_connection',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Connection timeout',
      code: 'timeout',
    );
  }

  factory NetworkException.serverError() {
    return const NetworkException(
      message: 'Server error occurred',
      code: 'server_error',
    );
  }
}

/// Storage-related exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.fromError(dynamic error) {
    if (error is StorageException) return error;

    return StorageException(
      message: 'Storage error occurred',
      originalError: error,
    );
  }

  factory StorageException.readError() {
    return const StorageException(
      message: 'Failed to read from storage',
      code: 'read_error',
    );
  }

  factory StorageException.writeError() {
    return const StorageException(
      message: 'Failed to write to storage',
      code: 'write_error',
    );
  }
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory UnknownException.fromError(dynamic error) {
    if (error is AppException) return error as UnknownException;

    return UnknownException(
      message: 'An unexpected error occurred',
      originalError: error,
    );
  }
}

