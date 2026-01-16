import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../quotes/presentation/widgets/quote_card.dart';
import '../../domain/collection.dart';
import '../controllers/collections_controller.dart';

/// Screen displaying quotes in a collection
class CollectionDetailScreen extends ConsumerWidget {
  final Collection collection;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(collectionQuotesProvider(collection.id));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF101022)
          : const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF101022).withOpacity(0.8)
            : const Color(0xFFF6F6F8).withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(collection.name),
        centerTitle: true,
        actions: [
          // Quote count badge
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('${collection.quoteCount}'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: quotesAsync.when(
        data: (quotes) {
          if (quotes.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
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
                  // Show message that quote is already in a collection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This quote is already in this collection'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, error.toString()),
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
              Icons.collections_bookmark_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No quotes yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add quotes to this collection from the quote feed',
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
              'Failed to load quotes',
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
          ],
        ),
      ),
    );
  }
}

