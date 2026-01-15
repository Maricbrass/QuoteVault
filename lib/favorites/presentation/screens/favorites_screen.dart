import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../quotes/presentation/widgets/quote_card.dart';
import '../controllers/favorites_controller.dart';

/// Screen displaying user's favorited quotes
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorited quotes when screen opens
    Future.microtask(() {
      ref.read(favoritesControllerProvider.notifier).loadFavoritedQuotes();
    });
  }

  Future<void> _handleRefresh() async {
    await ref.read(favoritesControllerProvider.notifier).refreshFavoritedQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          // Favorite count badge
          if (favoritesState.favoriteCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  label: Text('${favoritesState.favoriteCount}'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, favoritesState),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesState state) {
    // Loading state
    if (state.isLoadingQuotes) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (state.errorMessage != null) {
      return _buildErrorState(context, state.errorMessage!);
    }

    final quotes = state.favoritedQuotes;

    // Empty state
    if (quotes == null || quotes.isEmpty) {
      return _buildEmptyState(context);
    }

    // List of favorited quotes
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return QuoteCard(
            quote: quote,
            onTap: () {
              // TODO: Navigate to quote detail
            },
            onAddToCollection: () {
              // TODO: Show collection picker dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Collections feature coming in next update'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on quotes to save them here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load favorites',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(favoritesControllerProvider.notifier).loadFavoritedQuotes();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

