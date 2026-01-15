import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/settings_repository.dart';
import '../../domain/settings_enums.dart' as enums;
import '../../domain/user_settings.dart';

/// Controller for user settings
class SettingsController extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  SettingsController(this._repository) : super(UserSettings.defaults()) {
    // Load settings on initialization
    loadSettings();
  }

  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      appLogger.info('Loading user settings');
      final settings = await _repository.loadSettings();
      state = settings;
      appLogger.info('Settings loaded successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load settings', e, stackTrace);
      // Keep default state
    }
  }

  /// Save current settings
  Future<void> _saveSettings() async {
    try {
      await _repository.saveSettings(state);
    } catch (e, stackTrace) {
      appLogger.error('Failed to save settings', e, stackTrace);
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(enums.ThemeMode mode) async {
    appLogger.info('Updating theme mode: $mode');
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  /// Update accent color
  Future<void> updateAccentColor(enums.AccentColor color) async {
    appLogger.info('Updating accent color: $color');
    state = state.copyWith(accentColor: color);
    await _saveSettings();
    _triggerHapticFeedback();
  }

  /// Update font family
  Future<void> updateFontFamily(enums.FontFamily family) async {
    appLogger.info('Updating font family: $family');
    state = state.copyWith(fontFamily: family);
    await _saveSettings();
  }

  /// Update font size scale
  Future<void> updateFontSizeScale(double scale) async {
    final clampedScale = scale.clamp(0.8, 1.4);
    appLogger.info('Updating font size scale: $clampedScale');
    state = state.copyWith(fontSizeScale: clampedScale);
    await _saveSettings();
  }

  /// Update line spacing
  Future<void> updateLineSpacing(double spacing) async {
    final clampedSpacing = spacing.clamp(1.2, 2.0);
    appLogger.info('Updating line spacing: $clampedSpacing');
    state = state.copyWith(lineSpacing: clampedSpacing);
    await _saveSettings();
  }

  /// Toggle show author
  Future<void> toggleShowAuthor() async {
    appLogger.info('Toggling show author: ${!state.showAuthor}');
    state = state.copyWith(showAuthor: !state.showAuthor);
    await _saveSettings();
    _triggerHapticFeedback();
  }

  /// Toggle show category
  Future<void> toggleShowCategory() async {
    appLogger.info('Toggling show category: ${!state.showCategory}');
    state = state.copyWith(showCategory: !state.showCategory);
    await _saveSettings();
    _triggerHapticFeedback();
  }

  /// Toggle auto save favorites
  Future<void> toggleAutoSaveFavorites() async {
    appLogger.info('Toggling auto save favorites: ${!state.autoSaveFavorites}');
    state = state.copyWith(autoSaveFavorites: !state.autoSaveFavorites);
    await _saveSettings();
    _triggerHapticFeedback();
  }

  /// Toggle haptic feedback
  Future<void> toggleHapticFeedback() async {
    appLogger.info('Toggling haptic feedback: ${!state.hapticFeedback}');
    state = state.copyWith(hapticFeedback: !state.hapticFeedback);
    await _saveSettings();
    // Don't trigger haptic when toggling haptic setting
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    appLogger.info('Resetting settings to defaults');
    state = UserSettings.defaults();
    await _repository.resetSettings();
    _triggerHapticFeedback();
  }

  /// Trigger haptic feedback if enabled
  void _triggerHapticFeedback() {
    if (state.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }
}

/// Provider for settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Provider for settings controller
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, UserSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsController(repository);
});

/// Provider for current theme mode (derived from settings)
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsControllerProvider);

  switch (settings.themeMode) {
    case enums.ThemeMode.light:
      return ThemeMode.light;
    case enums.ThemeMode.dark:
      return ThemeMode.dark;
    case enums.ThemeMode.system:
      return ThemeMode.system;
  }
});

/// Provider for accent color value
final accentColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  return Color(settings.accentColor.colorValue);
});

