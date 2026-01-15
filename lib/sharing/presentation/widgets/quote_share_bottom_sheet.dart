import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../quotes/domain/quote.dart';
import '../controllers/quote_share_controller.dart';
import '../screens/quote_card_preview_screen.dart';

/// Bottom sheet for sharing options
class QuoteShareBottomSheet extends ConsumerWidget {
  final Quote quote;

  const QuoteShareBottomSheet({
    super.key,
    required this.quote,
  });

  /// Show the bottom sheet
  static void show(BuildContext context, Quote quote) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuoteShareBottomSheet(quote: quote),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareState = ref.watch(quoteShareControllerProvider);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(102),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Share Quote',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Quote preview
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
                    '"${quote.text}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${quote.author}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share as text option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.text_fields,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Share as Text'),
              subtitle: const Text('Share the quote as plain text'),
              trailing: shareState.isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: shareState.isProcessing
                  ? null
                  : () async {
                      await ref
                          .read(quoteShareControllerProvider.notifier)
                          .shareText(quote);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
            ),

            const Divider(height: 24),

            // Share as image option
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: const Text('Share as Image'),
              subtitle: const Text('Create a styled quote card'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuoteCardPreviewScreen(quote: quote),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
