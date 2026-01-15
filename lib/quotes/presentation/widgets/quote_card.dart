import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../../favorites/presentation/controllers/likes_controller.dart';
import '../../domain/quote.dart';

/// Widget displaying a single quote card with favorites and likes
class QuoteCard extends ConsumerWidget {
  final Quote quote;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCollection;

  const QuoteCard({
    super.key,
    required this.quote,
    this.onTap,
    this.onAddToCollection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesControllerProvider);
    final likesState = ref.watch(likesControllerProvider);

    final isFavorited = favoritesState.isFavorited(quote.id);
    final isLiked = likesState.isLiked(quote.id);
    final likeCount = likesState.getLikeCount(quote.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote text
              Text(
                '"${quote.text}"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 12),

              // Author
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '— ${quote.author}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category and actions
              Row(
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(context, quote.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quote.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const Spacer(),

                  // Like button with count
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (likeCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '$likeCount',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? Theme.of(context).colorScheme.primary : null,
                        ),
                        onPressed: () {
                          ref
                              .read(likesControllerProvider.notifier)
                              .toggleLike(quote.id);
                        },
                        tooltip: isLiked ? 'Unlike' : 'Like',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  // Favorite button
                  IconButton(
                    icon: Icon(
                      isFavorited ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorited
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      ref
                          .read(favoritesControllerProvider.notifier)
                          .toggleFavorite(quote.id);
                    },
                    tooltip: isFavorited ? 'Remove from favorites' : 'Add to favorites',
                    visualDensity: VisualDensity.compact,
                  ),

                  // Add to collection button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onAddToCollection,
                    tooltip: 'Add to collection',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color for category
  Color _getCategoryColor(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (category.toLowerCase()) {
      case 'motivation':
        return Colors.orange;
      case 'love':
        return Colors.pink;
      case 'success':
        return Colors.green;
      case 'wisdom':
        return Colors.purple;
      case 'humor':
        return Colors.blue;
      default:
        return colorScheme.primary;
    }
  }
}

