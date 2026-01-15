import 'package:flutter/material.dart';

/// Empty state widget with icon, message, and optional action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty state for no favorites
class NoFavoritesEmpty extends StatelessWidget {
  const NoFavoritesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.bookmark_border,
      title: 'No Favorites Yet',
      message: 'Tap the bookmark icon on quotes you love to save them here',
    );
  }
}

/// Specific empty state for no collections
class NoCollectionsEmpty extends StatelessWidget {
  final VoidCallback? onCreate;

  const NoCollectionsEmpty({super.key, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.collections_bookmark_outlined,
      title: 'No Collections',
      message: 'Create collections to organize your favorite quotes by theme or topic',
      actionLabel: 'Create Collection',
      onAction: onCreate,
    );
  }
}

/// Specific empty state for offline with no cached data
class OfflineEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.cloud_off,
      title: 'You\'re Offline',
      message: 'No cached quotes available. Connect to the internet to load quotes.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Specific empty state for search with no results
class NoSearchResultsEmpty extends StatelessWidget {
  final String query;

  const NoSearchResultsEmpty({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results',
      message: 'No quotes found for "$query". Try different keywords.',
    );
  }
}

