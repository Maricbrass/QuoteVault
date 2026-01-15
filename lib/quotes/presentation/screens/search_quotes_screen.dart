import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/quote_search_controller.dart';
import '../widgets/quote_card.dart';

/// Screen for searching quotes
class SearchQuotesScreen extends ConsumerStatefulWidget {
  const SearchQuotesScreen({super.key});

  @override
  ConsumerState<SearchQuotesScreen> createState() =>
      _SearchQuotesScreenState();
}

class _SearchQuotesScreenState extends ConsumerState<SearchQuotesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      ref.read(quoteSearchProvider.notifier).loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _handleSearch(String query) {
    ref.read(quoteSearchProvider.notifier).updateQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(quoteSearchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(quoteSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search quotes...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: _handleSearch,
        ),
        actions: [
          if (searchState.hasQuery)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: _buildBody(context, searchState),
    );
  }

  Widget _buildBody(BuildContext context, QuoteSearchState searchState) {
    // Show initial state
    if (!searchState.hasQuery) {
      return _buildInitialState(context);
    }

    // Show validation message
    if (!searchState.isValidQuery) {
      return _buildValidationMessage(context);
    }

    // Show searching indicator
    if (searchState.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error
    if (searchState.errorMessage != null) {
      return _buildErrorState(context, searchState.errorMessage!);
    }

    // Show empty results
    if (searchState.isEmpty) {
      return _buildEmptyResults(context, searchState.searchQuery);
    }

    // Show results
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: searchState.results.length +
          (searchState.isLoadingMore ? 1 : 0) +
          (!searchState.pagination.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Results
        if (index < searchState.results.length) {
          final quote = searchState.results[index];
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
        }

        // Loading more indicator
        if (searchState.isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // End of results
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'End of results',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for quotes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter at least 2 characters to search',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Keep typing...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter at least 2 characters to search',
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

  Widget _buildEmptyResults(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Search query: "$query"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
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
              'Search failed',
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
                _handleSearch(_searchController.text);
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

