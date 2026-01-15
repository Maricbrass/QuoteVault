import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'settings/presentation/controllers/settings_controller.dart';
import 'settings/presentation/providers/theme_provider.dart';

/// Root application widget
/// Configures theme, routing, and global providers
class QuoteVaultApp extends ConsumerWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp.router(
      title: 'QuoteVault',
      debugShowCheckedModeBanner: false,

      // Dynamic theme configuration from user settings
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,
    );
  }
}

