import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';
import '../data/favorites_repository.dart';

/// State for favorites
class FavoritesState {
  final Set<String> favoriteQuoteIds;
  final List<Quote>? favoritedQuotes;
  final bool isLoading;
  final bool isLoadingQuotes;
  final String? errorMessage;

  const FavoritesState({
    this.favoriteQuoteIds = const {},
    this.favoritedQuotes,
    this.isLoading = false,
    this.isLoadingQuotes = false,
    this.errorMessage,
  });

  /// Check if quote is favorited
  bool isFavorited(String quoteId) => favoriteQuoteIds.contains(quoteId);

  /// Get favorite count
  int get favoriteCount => favoriteQuoteIds.length;

  FavoritesState copyWith({
    Set<String>? favoriteQuoteIds,
    List<Quote>? favoritedQuotes,
    bool? isLoading,
    bool? isLoadingQuotes,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoriteQuoteIds: favoriteQuoteIds ?? this.favoriteQuoteIds,
      favoritedQuotes: favoritedQuotes ?? this.favoritedQuotes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingQuotes: isLoadingQuotes ?? this.isLoadingQuotes,
      errorMessage: errorMessage,
    );
  }
}

/// Controller for favorites with optimistic updates
class FavoritesController extends StateNotifier<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesController(this._repository) : super(const FavoritesState()) {
    // Load favorite IDs on initialization
    loadFavoriteIds();
  }

  /// Load all favorite quote IDs
  Future<void> loadFavoriteIds() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Loading favorite quote IDs');
      final favoriteIds = await _repository.getFavoriteQuoteIds();

      state = state.copyWith(
        isLoading: false,
        favoriteQuoteIds: favoriteIds,
      );

      appLogger.info('Loaded ${favoriteIds.length} favorite IDs');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load favorite IDs', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Toggle favorite status (add or remove)
  Future<void> toggleFavorite(String quoteId) async {
    final isFavorited = state.isFavorited(quoteId);

    if (isFavorited) {
      await removeFavorite(quoteId);
    } else {
      await addFavorite(quoteId);
    }
  }

  /// Add quote to favorites with optimistic update
  Future<void> addFavorite(String quoteId) async {
    // Optimistic update
    final previousIds = state.favoriteQuoteIds;
    final updatedIds = {...previousIds, quoteId};

    state = state.copyWith(
      favoriteQuoteIds: updatedIds,
      errorMessage: null,
    );

    try {
      appLogger.info('Adding favorite (optimistic): $quoteId');
      await _repository.addFavorite(quoteId);
      appLogger.info('Favorite added successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to add favorite', e, stackTrace);

      // Rollback on failure
      state = state.copyWith(
        favoriteQuoteIds: previousIds,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Remove quote from favorites with optimistic update
  Future<void> removeFavorite(String quoteId) async {
    // Optimistic update
    final previousIds = state.favoriteQuoteIds;
    final updatedIds = Set<String>.from(previousIds)..remove(quoteId);

    state = state.copyWith(
      favoriteQuoteIds: updatedIds,
      errorMessage: null,
    );

    // Also remove from favorited quotes list if loaded
    if (state.favoritedQuotes != null) {
      final updatedQuotes = state.favoritedQuotes!
          .where((quote) => quote.id != quoteId)
          .toList();
      state = state.copyWith(favoritedQuotes: updatedQuotes);
    }

    try {
      appLogger.info('Removing favorite (optimistic): $quoteId');
      await _repository.removeFavorite(quoteId);
      appLogger.info('Favorite removed successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to remove favorite', e, stackTrace);

      // Rollback on failure
      state = state.copyWith(
        favoriteQuoteIds: previousIds,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Load full favorited quotes
  Future<void> loadFavoritedQuotes() async {
    if (state.isLoadingQuotes) return;

    state = state.copyWith(isLoadingQuotes: true, errorMessage: null);

    try {
      appLogger.info('Loading favorited quotes');
      final quotes = await _repository.getFavoritedQuotes();

      state = state.copyWith(
        isLoadingQuotes: false,
        favoritedQuotes: quotes,
      );

      appLogger.info('Loaded ${quotes.length} favorited quotes');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load favorited quotes', e, stackTrace);
      state = state.copyWith(
        isLoadingQuotes: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Refresh favorited quotes
  Future<void> refreshFavoritedQuotes() async {
    state = state.copyWith(favoritedQuotes: null);
    await loadFavoritedQuotes();
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

    if (errorString.startsWith('AuthException: ')) {
      return errorString.substring(15);
    }

    return errorString;
  }
}

/// Provider for favorites repository
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Provider for favorites controller
final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoritesController(repository);
});

