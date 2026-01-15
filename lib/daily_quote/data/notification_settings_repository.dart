import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../domain/notification_settings.dart';

/// Repository for notification settings persistence
class NotificationSettingsRepository {
  static const String _settingsKey = 'notification_settings';

  /// Load notification settings
  Future<NotificationSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        appLogger.info('No saved notification settings, using defaults');
        return NotificationSettings.defaultSettings();
      }

      final settings = NotificationSettings.fromJson(
        json.decode(settingsJson),
      );

      appLogger.info('Notification settings loaded: $settings');
      return settings;
    } catch (e, stackTrace) {
      appLogger.error('Failed to load notification settings', e, stackTrace);
      return NotificationSettings.defaultSettings();
    }
  }

  /// Save notification settings
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _settingsKey,
        json.encode(settings.toJson()),
      );

      appLogger.info('Notification settings saved: $settings');
    } catch (e, stackTrace) {
      appLogger.error('Failed to save notification settings', e, stackTrace);
    }
  }

  /// Clear settings (for testing)
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      appLogger.info('Notification settings cleared');
    } catch (e, stackTrace) {
      appLogger.error('Failed to clear notification settings', e, stackTrace);
    }
  }
}

