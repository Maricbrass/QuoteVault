import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../domain/settings_enums.dart' as enums;

/// Service for generating dynamic themes based on user settings
class ThemeService {
  /// Generate light theme from settings
  static ThemeData getLightTheme(Color accentColor, enums.FontFamily fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
      ),
      fontFamily: fontFamily.fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ).surface,
      ),
    );
  }

  /// Generate dark theme from settings
  static ThemeData getDarkTheme(Color accentColor, enums.FontFamily fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      ),
      fontFamily: fontFamily.fontFamily,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ).surface,
      ),
    );
  }
}

/// Provider for light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  final accentColor = Color(settings.accentColor.colorValue);
  return ThemeService.getLightTheme(accentColor, settings.fontFamily);
});

/// Provider for dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  final accentColor = Color(settings.accentColor.colorValue);
  return ThemeService.getDarkTheme(accentColor, settings.fontFamily);
});

