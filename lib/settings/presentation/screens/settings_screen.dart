import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../daily_quote/presentation/widgets/notification_settings_section.dart';
import '../widgets/appearance_settings_section.dart';
import '../widgets/reading_settings_section.dart';
import '../widgets/behavior_settings_section.dart';
import '../widgets/about_section.dart';

/// Comprehensive settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          // Appearance settings
          AppearanceSettingsSection(),

          SizedBox(height: 8),

          // Reading experience settings
          ReadingSettingsSection(),

          SizedBox(height: 8),

          // Behavior settings
          BehaviorSettingsSection(),

          SizedBox(height: 8),

          // Notification settings
          NotificationSettingsSection(),

          SizedBox(height: 8),

          // About section
          AboutSection(),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}

