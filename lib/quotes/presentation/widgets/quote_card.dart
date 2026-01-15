import 'package:flutter/material.dart';
import '../../domain/quote.dart';

/// Widget displaying a single quote card
class QuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onFavorite;
  final bool isLiked;
  final bool isFavorited;

  const QuoteCard({
    super.key,
    required this.quote,
    this.onTap,
    this.onLike,
    this.onFavorite,
    this.isLiked = false,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
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

                  // Like button (placeholder)
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: onLike,
                    tooltip: 'Like',
                    visualDensity: VisualDensity.compact,
                  ),

                  // Favorite button (placeholder)
                  IconButton(
                    icon: Icon(
                      isFavorited ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorited
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: onFavorite,
                    tooltip: 'Add to favorites',
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

