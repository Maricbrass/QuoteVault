import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';

/// Behavior settings section
class BehaviorSettingsSection extends ConsumerWidget {
  const BehaviorSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

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
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Behavior',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Configure app behavior and interactions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),

            // Haptic feedback
            SwitchListTile(
              title: const Text('Haptic Feedback'),
              subtitle: const Text('Vibration feedback for actions'),
              secondary: const Icon(Icons.vibration),
              value: settings.hapticFeedback,
              onChanged: (value) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .toggleHapticFeedback();
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Auto save favorites
            SwitchListTile(
              title: const Text('Auto-Save Shared Quotes'),
              subtitle: const Text('Automatically add shared quotes to favorites'),
              secondary: const Icon(Icons.bookmark_add),
              value: settings.autoSaveFavorites,
              onChanged: (value) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .toggleAutoSaveFavorites();
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Reset settings button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Settings'),
                      content: const Text(
                        'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .resetToDefaults();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings reset to defaults'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

