import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../core/utils/logger.dart';
import '../domain/daily_quote.dart';
import '../domain/notification_settings.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Function(String)? _onNotificationTap;

  /// Initialize notification service
  Future<void> initialize({Function(String)? onNotificationTap}) async {
    if (_initialized) return;

    try {
      appLogger.info('Initializing notification service');

      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Set callback for notification taps
      _onNotificationTap = onNotificationTap;

      // Initialize plugin
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      _initialized = true;
      appLogger.info('Notification service initialized successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to initialize notification service', e, stackTrace);
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null && _onNotificationTap != null) {
        appLogger.info('Notification tapped with payload: $payload');
        _onNotificationTap!(payload);
      }
    } catch (e, stackTrace) {
      appLogger.error('Error handling notification tap', e, stackTrace);
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    try {
      appLogger.info('Requesting notification permissions');

      // iOS requires explicit permission request
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final result = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        appLogger.info('iOS notification permissions: $result');
        return result ?? false;
      }

      // Android doesn't need runtime permissions for notifications (pre-13)
      return true;
    } catch (e, stackTrace) {
      appLogger.error('Failed to request notification permissions', e, stackTrace);
      return false;
    }
  }

  /// Schedule daily quote notification
  Future<void> scheduleDailyQuoteNotification(
    NotificationSettings settings,
  ) async {
    try {
      if (!settings.enabled) {
        await cancelDailyQuoteNotification();
        return;
      }

      appLogger.info('Scheduling daily quote notification at ${settings.getFormattedTime()}');

      // Create notification time for today
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        settings.notificationTime.hour,
        settings.notificationTime.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'daily_quote_channel',
        'Daily Quote',
        channelDescription: 'Daily inspirational quote notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create payload with date
      final payload = json.encode({
        'type': 'daily_quote',
        'date': DailyQuote.getTodayString(),
      });

      // Schedule notification
      await _notifications.zonedSchedule(
        0, // Notification ID
        'Quote of the Day',
        'Your daily inspiration is here! 📖',
        tzScheduledDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      appLogger.info('Daily quote notification scheduled for $scheduledDate');
    } catch (e, stackTrace) {
      appLogger.error('Failed to schedule daily quote notification', e, stackTrace);
    }
  }

  /// Cancel daily quote notification
  Future<void> cancelDailyQuoteNotification() async {
    try {
      appLogger.info('Cancelling daily quote notification');
      await _notifications.cancel(0);
      appLogger.info('Daily quote notification cancelled');
    } catch (e, stackTrace) {
      appLogger.error('Failed to cancel notification', e, stackTrace);
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'daily_quote_channel',
        'Daily Quote',
        channelDescription: 'Daily inspirational quote notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      appLogger.info('Immediate notification shown: $title');
    } catch (e, stackTrace) {
      appLogger.error('Failed to show immediate notification', e, stackTrace);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      appLogger.info('All notifications cancelled');
    } catch (e, stackTrace) {
      appLogger.error('Failed to cancel all notifications', e, stackTrace);
    }
  }

  /// Check if notifications are enabled (Android 13+)
  Future<bool> areNotificationsEnabled() async {
    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? true;
    } catch (e) {
      return true;
    }
  }
}

