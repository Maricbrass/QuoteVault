import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/quote_repository.dart';
import '../../domain/pagination_meta.dart';
import '../../domain/quote.dart';
import '../../domain/quote_filter.dart';

/// State for quote feed
class QuoteFeedState {
  final List<Quote> quotes;
  final PaginationMeta pagination;
  final QuoteFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const QuoteFeedState({
    this.quotes = const [],
    required this.pagination,
    this.filter = const QuoteFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  /// Create initial state
  factory QuoteFeedState.initial() {
    return QuoteFeedState(
      pagination: PaginationMeta.initial(),
    );
  }

  /// Check if feed is empty
  bool get isEmpty => quotes.isEmpty && !isLoading;

  /// Check if feed has data
  bool get hasData => quotes.isNotEmpty;

  /// Check if can load more
  bool get canLoadMore => pagination.hasMore && !isLoadingMore && !isLoading;

  QuoteFeedState copyWith({
    List<Quote>? quotes,
    PaginationMeta? pagination,
    QuoteFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return QuoteFeedState(
      quotes: quotes ?? this.quotes,
      pagination: pagination ?? this.pagination,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

/// Controller for quote feed with pagination
class QuoteFeedController extends StateNotifier<QuoteFeedState> {
  final QuoteRepository _repository;

  QuoteFeedController(this._repository)
      : super(QuoteFeedState.initial()) {
    // Load initial quotes
    loadQuotes();
  }

  /// Load initial quotes
  Future<void> loadQuotes({QuoteFilter? filter}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      filter: filter,
      pagination: PaginationMeta.initial(),
    );

    try {
      appLogger.info('Loading initial quotes with filter: $filter');

      final quotes = await _repository.fetchQuotes(
        limit: state.pagination.pageSize,
        offset: 0,
        filter: filter,
      );

      final hasMore = quotes.length == state.pagination.pageSize;

      state = state.copyWith(
        isLoading: false,
        quotes: quotes,
        pagination: state.pagination.nextPage(hasMore: hasMore),
      );

      appLogger.info('Loaded ${quotes.length} quotes');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load quotes', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Load more quotes (pagination)
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      appLogger.info('Loading more quotes, page: ${state.pagination.currentPage}');

      final newQuotes = await _repository.fetchQuotes(
        limit: state.pagination.pageSize,
        offset: state.pagination.offset,
        filter: state.filter,
      );

      final hasMore = newQuotes.length == state.pagination.pageSize;
      final allQuotes = [...state.quotes, ...newQuotes];

      state = state.copyWith(
        isLoadingMore: false,
        quotes: allQuotes,
        pagination: state.pagination.nextPage(hasMore: hasMore),
      );

      appLogger.info('Loaded ${newQuotes.length} more quotes, total: ${allQuotes.length}');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load more quotes', e, stackTrace);
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Refresh quotes (pull-to-refresh)
  Future<void> refresh() async {
    appLogger.info('Refreshing quotes');
    state = state.copyWith(pagination: PaginationMeta.initial());
    await loadQuotes(filter: state.filter);
  }

  /// Apply filter and reload
  Future<void> applyFilter(QuoteFilter filter) async {
    appLogger.info('Applying filter: $filter');
    await loadQuotes(filter: filter);
  }

  /// Clear filter and reload
  Future<void> clearFilter() async {
    appLogger.info('Clearing filter');
    await loadQuotes(filter: const QuoteFilter());
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

/// Provider for quote repository
final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository();
});

/// Provider for quote feed controller
final quoteFeedProvider =
    StateNotifierProvider<QuoteFeedController, QuoteFeedState>((ref) {
  final repository = ref.watch(quoteRepositoryProvider);
  return QuoteFeedController(repository);
});

