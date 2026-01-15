import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/quote_repository.dart';
import '../../domain/pagination_meta.dart';
import '../../domain/quote.dart';
import 'quote_feed_controller.dart';

/// State for quote search
class QuoteSearchState {
  final String searchQuery;
  final List<Quote> results;
  final PaginationMeta pagination;
  final bool isSearching;
  final bool isLoadingMore;
  final String? errorMessage;

  const QuoteSearchState({
    this.searchQuery = '',
    this.results = const [],
    required this.pagination,
    this.isSearching = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  /// Create initial state
  factory QuoteSearchState.initial() {
    return QuoteSearchState(
      pagination: PaginationMeta.initial(),
    );
  }

  /// Check if search is active
  bool get hasQuery => searchQuery.trim().isNotEmpty;

  /// Check if search is valid (meets minimum length)
  bool get isValidQuery => searchQuery.trim().length >= 2;

  /// Check if results are empty
  bool get isEmpty => results.isEmpty && !isSearching && hasQuery;

  /// Check if has results
  bool get hasResults => results.isNotEmpty;

  /// Check if can load more
  bool get canLoadMore => pagination.hasMore && !isLoadingMore && !isSearching;

  QuoteSearchState copyWith({
    String? searchQuery,
    List<Quote>? results,
    PaginationMeta? pagination,
    bool? isSearching,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return QuoteSearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      results: results ?? this.results,
      pagination: pagination ?? this.pagination,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

/// Controller for quote search with debouncing
class QuoteSearchController extends StateNotifier<QuoteSearchState> {
  final QuoteRepository _repository;
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 400);

  QuoteSearchController(this._repository)
      : super(QuoteSearchState.initial());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Update search query with debouncing
  void updateQuery(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update query immediately
    state = state.copyWith(
      searchQuery: query,
      errorMessage: null,
    );

    // Clear results if query is too short
    if (!state.isValidQuery) {
      state = state.copyWith(
        results: [],
        pagination: PaginationMeta.initial(),
      );
      return;
    }

    // Debounce the search
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch();
    });
  }

  /// Perform the actual search
  Future<void> _performSearch() async {
    if (!state.isValidQuery) return;

    state = state.copyWith(
      isSearching: true,
      errorMessage: null,
      pagination: PaginationMeta.initial(),
    );

    try {
      appLogger.info('Searching quotes: "${state.searchQuery}"');

      final results = await _repository.searchQuotes(
        query: state.searchQuery,
        limit: state.pagination.pageSize,
        offset: 0,
      );

      final hasMore = results.length == state.pagination.pageSize;

      state = state.copyWith(
        isSearching: false,
        results: results,
        pagination: state.pagination.nextPage(hasMore: hasMore),
      );

      appLogger.info('Found ${results.length} quotes');
    } catch (e, stackTrace) {
      appLogger.error('Search failed', e, stackTrace);
      state = state.copyWith(
        isSearching: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Load more search results
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      appLogger.info('Loading more search results, page: ${state.pagination.currentPage}');

      final newResults = await _repository.searchQuotes(
        query: state.searchQuery,
        limit: state.pagination.pageSize,
        offset: state.pagination.offset,
      );

      final hasMore = newResults.length == state.pagination.pageSize;
      final allResults = [...state.results, ...newResults];

      state = state.copyWith(
        isLoadingMore: false,
        results: allResults,
        pagination: state.pagination.nextPage(hasMore: hasMore),
      );

      appLogger.info('Loaded ${newResults.length} more results, total: ${allResults.length}');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load more search results', e, stackTrace);
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Clear search
  void clear() {
    _debounceTimer?.cancel();
    state = QuoteSearchState.initial();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Extract user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }

    if (errorString.startsWith('StorageException: ')) {
      return errorString.substring(18);
    }

    return errorString;
  }
}

/// Provider for quote search controller
final quoteSearchProvider =
    StateNotifierProvider<QuoteSearchController, QuoteSearchState>((ref) {
  final repository = ref.watch(quoteRepositoryProvider);
  return QuoteSearchController(repository);
});

