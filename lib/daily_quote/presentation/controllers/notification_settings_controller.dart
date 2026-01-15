import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/daily_quote_repository.dart';
import '../../data/notification_settings_repository.dart';
import '../../domain/notification_settings.dart';
import '../../services/notification_service.dart';

/// State for notification settings
class NotificationSettingsState {
  final NotificationSettings settings;
  final bool isLoading;
  final String? errorMessage;

  const NotificationSettingsState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationSettingsState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller for notification settings
class NotificationSettingsController
    extends StateNotifier<NotificationSettingsState> {
  final NotificationSettingsRepository _repository;
  final NotificationService _notificationService;

  NotificationSettingsController(
    this._repository,
    this._notificationService,
  ) : super(NotificationSettingsState(
          settings: NotificationSettings.defaultSettings(),
        )) {
    // Load settings on initialization
    loadSettings();
  }

  /// Load notification settings
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Loading notification settings');
      final settings = await _repository.loadSettings();

      state = state.copyWith(
        isLoading: false,
        settings: settings,
      );

      // Reschedule notification with loaded settings
      await _notificationService.scheduleDailyQuoteNotification(settings);

      appLogger.info('Notification settings loaded');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load notification settings', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load settings',
      );
    }
  }

  /// Toggle notification enabled/disabled
  Future<void> toggleEnabled() async {
    try {
      final newSettings = state.settings.copyWith(
        enabled: !state.settings.enabled,
      );

      state = state.copyWith(settings: newSettings);

      await _repository.saveSettings(newSettings);
      await _notificationService.scheduleDailyQuoteNotification(newSettings);

      appLogger.info('Notification enabled: ${newSettings.enabled}');
    } catch (e, stackTrace) {
      appLogger.error('Failed to toggle notification', e, stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to update settings',
      );
    }
  }

  /// Update notification time
  Future<void> updateTime(TimeOfDay newTime) async {
    try {
      final newSettings = state.settings.copyWith(
        notificationTime: newTime,
      );

      state = state.copyWith(settings: newSettings);

      await _repository.saveSettings(newSettings);
      await _notificationService.scheduleDailyQuoteNotification(newSettings);

      appLogger.info('Notification time updated: ${newSettings.getFormattedTime()}');
    } catch (e, stackTrace) {
      appLogger.error('Failed to update notification time', e, stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to update time',
      );
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      appLogger.info('Requesting notification permissions');
      final granted = await _notificationService.requestPermissions();

      if (!granted) {
        state = state.copyWith(
          errorMessage: 'Notification permissions denied',
        );
      }

      return granted;
    } catch (e, stackTrace) {
      appLogger.error('Failed to request permissions', e, stackTrace);
      return false;
    }
  }

  /// Test notification (show immediate notification)
  Future<void> sendTestNotification() async {
    try {
      appLogger.info('Sending test notification');
      await _notificationService.showImmediateNotification(
        title: 'Quote of the Day',
        body: 'This is a test notification! Your daily quotes will arrive at ${state.settings.getFormattedTime()}.',
      );
    } catch (e, stackTrace) {
      appLogger.error('Failed to send test notification', e, stackTrace);
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for notification settings repository
final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepository();
});

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for notification settings controller
final notificationSettingsControllerProvider = StateNotifierProvider<
    NotificationSettingsController, NotificationSettingsState>((ref) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationSettingsController(repository, notificationService);
});

