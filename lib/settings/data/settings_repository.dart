import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../domain/user_settings.dart';

/// Repository for user settings persistence
class SettingsRepository {
  static const String _settingsKey = 'user_settings';

  /// Load user settings
  Future<UserSettings> loadSettings() async {
    try {
      appLogger.info('Loading user settings');

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        appLogger.info('No saved settings found, using defaults');
        return UserSettings.defaults();
      }

      final settings = UserSettings.fromJson(
        json.decode(settingsJson) as Map<String, dynamic>,
      );

      appLogger.info('User settings loaded: $settings');
      return settings;
    } catch (e, stackTrace) {
      appLogger.error('Failed to load settings, using defaults', e, stackTrace);
      return UserSettings.defaults();
    }
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    try {
      appLogger.info('Saving user settings: $settings');

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());

      await prefs.setString(_settingsKey, settingsJson);

      appLogger.info('User settings saved successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to save user settings', e, stackTrace);
      // Don't throw - settings changes should be non-blocking
    }
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    try {
      appLogger.info('Resetting user settings to defaults');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);

      appLogger.info('User settings reset successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to reset settings', e, stackTrace);
    }
  }

  /// Clear all settings (for testing)
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      appLogger.info('All settings cleared');
    } catch (e, stackTrace) {
      appLogger.error('Failed to clear settings', e, stackTrace);
    }
  }
}

