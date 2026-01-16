import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/settings_controller.dart';
import '../../domain/settings_enums.dart' as enums;

/// Service for generating dynamic themes based on user settings
class ThemeService {
  /// Generate light theme from settings
  static ThemeData getLightTheme(Color accentColor, enums.FontFamily fontFamily) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF6F6F8),
      background: const Color(0xFFF6F6F8),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: _getFontFamily(fontFamily),
      scaffoldBackgroundColor: const Color(0xFFF6F6F8),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Generate dark theme from settings
  static ThemeData getDarkTheme(Color accentColor, enums.FontFamily fontFamily) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF101022),
      background: const Color(0xFF101022),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: _getFontFamily(fontFamily),
      scaffoldBackgroundColor: const Color(0xFF101022),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static String _getFontFamily(enums.FontFamily fontFamily) {
    switch (fontFamily) {
      case enums.FontFamily.serif:
        return 'serif';
      case enums.FontFamily.sans:
        return 'sans-serif';
      case enums.FontFamily.mono:
        return 'monospace';
      case enums.FontFamily.manrope:
        return GoogleFonts.manrope().fontFamily!;
    }
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

