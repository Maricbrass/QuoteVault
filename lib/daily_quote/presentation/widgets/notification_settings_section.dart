import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/notification_settings_controller.dart';

/// Settings section for daily quote notifications
class NotificationSettingsSection extends ConsumerWidget {
  const NotificationSettingsSection({super.key});

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay currentTime,
  ) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (newTime != null && context.mounted) {
      await ref
          .read(notificationSettingsControllerProvider.notifier)
          .updateTime(newTime);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification time updated to ${_formatTime(newTime)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationSettingsControllerProvider);
    final settings = settingsState.settings;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Quote Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get inspired every day with a notification',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),

            // Enable/Disable toggle
            SwitchListTile(
              title: const Text('Enable Daily Notifications'),
              subtitle: Text(
                settings.enabled
                    ? 'You\'ll receive a notification at ${settings.getFormattedTime()}'
                    : 'Turn on to receive daily quote notifications',
              ),
              value: settings.enabled,
              onChanged: (value) async {
                if (value) {
                  // Request permissions when enabling
                  final granted = await ref
                      .read(notificationSettingsControllerProvider.notifier)
                      .requestPermissions();

                  if (!granted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enable notification permissions in settings',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                }

                await ref
                    .read(notificationSettingsControllerProvider.notifier)
                    .toggleEnabled();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Daily notifications enabled'
                            : 'Daily notifications disabled',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              secondary: Icon(
                settings.enabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Time picker
            if (settings.enabled) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Notification Time'),
                subtitle: Text(settings.getFormattedTime()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimePicker(
                  context,
                  ref,
                  settings.notificationTime,
                ),
              ),

              // Test notification button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(notificationSettingsControllerProvider.notifier)
                        .sendTestNotification();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test Notification'),
                ),
              ),
            ],

            // Error message
            if (settingsState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settingsState.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

