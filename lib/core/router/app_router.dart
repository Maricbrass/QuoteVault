import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/screens/forgot_password_screen.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../../auth/presentation/screens/profile_screen.dart';
import '../../auth/presentation/screens/signup_screen.dart';
import '../../auth/presentation/screens/splash_screen.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../quotes/presentation/screens/category_quotes_screen.dart';
import '../../quotes/presentation/screens/quotes_feed_screen.dart';
import '../../quotes/presentation/screens/search_quotes_screen.dart';
import '../constants/app_routes.dart';

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
      final isOnRegister = state.matchedLocation == AppRoutes.register;
      final isOnForgotPassword = state.matchedLocation == AppRoutes.forgotPassword;

      // Let splash screen handle initial routing
      if (isOnSplash) {
        return null;
      }

      // Allow unauthenticated access to auth-related pages
      final isOnAuthPage = isOnLogin || isOnRegister || isOnForgotPassword;

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isOnAuthPage) {
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
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.quotes,
        name: 'quotes',
        builder: (context, state) => const QuotesFeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.searchQuotes,
        name: 'searchQuotes',
        builder: (context, state) => const SearchQuotesScreen(),
      ),
      GoRoute(
        path: '/quotes/category/:category',
        name: 'categoryQuotes',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          return CategoryQuotesScreen(category: category);
        },
      ),
    ],
  );
});

