import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user.dart';
import '../auth_providers.dart';

/// State for login screen
class LoginState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for login operations
class LoginController extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginController(this._authRepository) : super(const LoginState());

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

/// Provider for login controller
final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginController(authRepository);
});

