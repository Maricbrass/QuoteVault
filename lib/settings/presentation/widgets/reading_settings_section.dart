import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';

/// Reading experience settings section
class ReadingSettingsSection extends ConsumerWidget {
  const ReadingSettingsSection({super.key});

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
                  Icons.text_fields,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Reading Experience',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust text size and spacing for comfortable reading',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),

            // Font size scale
            Text(
              'Text Size',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.text_decrease),
                Expanded(
                  child: Slider(
                    value: settings.fontSizeScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 12,
                    label: '${(settings.fontSizeScale * 100).toInt()}%',
                    onChanged: (value) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateFontSizeScale(value);
                    },
                  ),
                ),
                const Icon(Icons.text_increase),
              ],
            ),
            Text(
              '${(settings.fontSizeScale * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Line spacing
            Text(
              'Line Spacing',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.format_line_spacing),
                Expanded(
                  child: Slider(
                    value: settings.lineSpacing,
                    min: 1.2,
                    max: 2.0,
                    divisions: 16,
                    label: settings.lineSpacing.toStringAsFixed(1),
                    onChanged: (value) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateLineSpacing(value);
                    },
                  ),
                ),
                const Icon(Icons.format_line_spacing),
              ],
            ),
            Text(
              settings.lineSpacing.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"The only way to do great work is to love what you do."',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16 * settings.fontSizeScale,
                          height: settings.lineSpacing,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  if (settings.showAuthor) ...[
                    const SizedBox(height: 8),
                    Text(
                      '— Steve Jobs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14 * settings.fontSizeScale,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Show/hide toggles
            SwitchListTile(
              title: const Text('Show Author Names'),
              subtitle: const Text('Display author attribution on quotes'),
              value: settings.showAuthor,
              onChanged: (value) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .toggleShowAuthor();
              },
              contentPadding: EdgeInsets.zero,
            ),

            SwitchListTile(
              title: const Text('Show Categories'),
              subtitle: const Text('Display category tags on quote cards'),
              value: settings.showCategory,
              onChanged: (value) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .toggleShowCategory();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

