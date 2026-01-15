import 'package:flutter/material.dart';

/// Model for notification settings
class NotificationSettings {
  final bool enabled;
  final TimeOfDay notificationTime;

  const NotificationSettings({
    required this.enabled,
    required this.notificationTime,
  });

  /// Default settings (9:00 AM, disabled)
  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings(
      enabled: false,
      notificationTime: TimeOfDay(hour: 9, minute: 0),
    );
  }

  /// Create from JSON
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? false,
      notificationTime: TimeOfDay(
        hour: json['hour'] as int? ?? 9,
        minute: json['minute'] as int? ?? 0,
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'hour': notificationTime.hour,
      'minute': notificationTime.minute,
    };
  }

  /// Create copy with modifications
  NotificationSettings copyWith({
    bool? enabled,
    TimeOfDay? notificationTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  /// Get notification time as formatted string (e.g., "9:00 AM")
  String getFormattedTime() {
    final hour = notificationTime.hour;
    final minute = notificationTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.enabled == enabled &&
        other.notificationTime.hour == notificationTime.hour &&
        other.notificationTime.minute == notificationTime.minute;
  }

  @override
  int get hashCode =>
      enabled.hashCode ^
      notificationTime.hour.hashCode ^
      notificationTime.minute.hashCode;

  @override
  String toString() =>
      'NotificationSettings(enabled: $enabled, time: ${getFormattedTime()})';
}

