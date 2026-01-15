import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/presentation/auth_providers.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../auth/presentation/screens/splash_screen.dart';
import '../home/presentation/screens/home_screen.dart';
import 'core/constants/app_routes.dart';

/// Provider for GoRouter configuration
/// Handles navigation and auth-based route guards
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // Let splash screen handle initial routing
      if (isOnSplash) {
        return null;
      }

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isOnLogin) {
        return AppRoutes.login;
      }

      // If authenticated and on login page, redirect to home
      if (isAuthenticated && isOnLogin) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

