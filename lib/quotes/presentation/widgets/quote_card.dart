import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../../favorites/presentation/controllers/likes_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../sharing/presentation/widgets/quote_share_bottom_sheet.dart';
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
    final settings = ref.watch(settingsControllerProvider);

    final isFavorited = favoritesState.isFavorited(quote.id);
    final isLiked = likesState.isLiked(quote.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111E21) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F1F1),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote text
              Text(
                '"${quote.text}"',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontStyle: FontStyle.italic,
                  fontSize: 20 * settings.fontSizeScale,
                  height: settings.lineSpacing,
                  color: isDark ? const Color(0xFFE5E5E5) : const Color(
                      0xFF0E191B),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 16),

              // Author and actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Author and category column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (settings.showAuthor)
                          Text(
                            quote.author,
                            style: TextStyle(
                              fontSize: 14 * settings.fontSizeScale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF17B0CF),
                            ),
                          ),
                        if (settings.showCategory)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Category: ${quote.category}',
                              style: TextStyle(
                                fontSize: 12 * settings.fontSizeScale,
                                color: isDark
                                    ? const Color(0xFF999999)
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like button
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked
                              ? Colors.red
                              : (isDark ? const Color(0xFF999999) : const Color(
                              0xFF999999)),
                          size: 22,
                        ),
                        onPressed: () {
                          ref
                              .read(likesControllerProvider.notifier)
                              .toggleLike(quote.id);
                        },
                        tooltip: isLiked ? 'Unlike' : 'Like',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),

                      // Favorite button
                      IconButton(
                        icon: Icon(
                          isFavorited ? Icons.bookmark : Icons.bookmark_border,
                          color: isFavorited
                              ? const Color(0xFF17B0CF)
                              : (isDark ? const Color(0xFF999999) : const Color(
                              0xFF999999)),
                          size: 22,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesControllerProvider.notifier)
                              .toggleFavorite(quote.id);
                        },
                        tooltip: isFavorited
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),

                      // Save/Share button
                      ElevatedButton(
                        onPressed: () {
                          QuoteShareBottomSheet.show(context, quote);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17B0CF).withAlpha(
                              (0.1 * 255).toInt()),
                          foregroundColor: const Color(0xFF17B0CF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 12 * settings.fontSizeScale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

