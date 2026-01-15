import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/likes_repository.dart';
import 'favorites_controller.dart';

/// State for likes
class LikesState {
  final Set<String> likedQuoteIds;
  final Map<String, int> likeCounts;
  final bool isLoading;
  final String? errorMessage;

  const LikesState({
    this.likedQuoteIds = const {},
    this.likeCounts = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  /// Check if quote is liked
  bool isLiked(String quoteId) => likedQuoteIds.contains(quoteId);

  /// Get like count for quote
  int getLikeCount(String quoteId) => likeCounts[quoteId] ?? 0;

  LikesState copyWith({
    Set<String>? likedQuoteIds,
    Map<String, int>? likeCounts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LikesState(
      likedQuoteIds: likedQuoteIds ?? this.likedQuoteIds,
      likeCounts: likeCounts ?? this.likeCounts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller for likes with optimistic updates
class LikesController extends StateNotifier<LikesState> {
  final LikesRepository _repository;

  LikesController(this._repository) : super(const LikesState()) {
    // Load liked IDs on initialization
    loadLikedIds();
  }

  /// Load all liked quote IDs
  Future<void> loadLikedIds() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Loading liked quote IDs');
      final likedIds = await _repository.getLikedQuoteIds();

      state = state.copyWith(
        isLoading: false,
        likedQuoteIds: likedIds,
      );

      appLogger.info('Loaded ${likedIds.length} liked IDs');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load liked IDs', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Toggle like status (like or unlike)
  Future<void> toggleLike(String quoteId) async {
    final isLiked = state.isLiked(quoteId);

    if (isLiked) {
      await unlikeQuote(quoteId);
    } else {
      await likeQuote(quoteId);
    }
  }

  /// Like a quote with optimistic update
  Future<void> likeQuote(String quoteId) async {
    // Optimistic update
    final previousLikedIds = state.likedQuoteIds;
    final previousLikeCounts = state.likeCounts;

    final updatedLikedIds = {...previousLikedIds, quoteId};
    final updatedLikeCounts = {
      ...previousLikeCounts,
      quoteId: (previousLikeCounts[quoteId] ?? 0) + 1,
    };

    state = state.copyWith(
      likedQuoteIds: updatedLikedIds,
      likeCounts: updatedLikeCounts,
      errorMessage: null,
    );

    try {
      appLogger.info('Liking quote (optimistic): $quoteId');
      await _repository.likeQuote(quoteId);
      appLogger.info('Quote liked successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to like quote', e, stackTrace);

      // Rollback on failure
      state = state.copyWith(
        likedQuoteIds: previousLikedIds,
        likeCounts: previousLikeCounts,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Unlike a quote with optimistic update
  Future<void> unlikeQuote(String quoteId) async {
    // Optimistic update
    final previousLikedIds = state.likedQuoteIds;
    final previousLikeCounts = state.likeCounts;

    final updatedLikedIds = Set<String>.from(previousLikedIds)..remove(quoteId);
    final currentCount = previousLikeCounts[quoteId] ?? 0;
    final updatedLikeCounts = {
      ...previousLikeCounts,
      quoteId: currentCount > 0 ? currentCount - 1 : 0,
    };

    state = state.copyWith(
      likedQuoteIds: updatedLikedIds,
      likeCounts: updatedLikeCounts,
      errorMessage: null,
    );

    try {
      appLogger.info('Unliking quote (optimistic): $quoteId');
      await _repository.unlikeQuote(quoteId);
      appLogger.info('Quote unliked successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to unlike quote', e, stackTrace);

      // Rollback on failure
      state = state.copyWith(
        likedQuoteIds: previousLikedIds,
        likeCounts: previousLikeCounts,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Load like counts for multiple quotes (batch)
  Future<void> loadLikeCounts(List<String> quoteIds) async {
    try {
      appLogger.info('Loading like counts for ${quoteIds.length} quotes');
      final counts = await _repository.getLikeCounts(quoteIds);

      state = state.copyWith(
        likeCounts: {...state.likeCounts, ...counts},
      );

      appLogger.info('Loaded like counts for ${counts.length} quotes');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load like counts', e, stackTrace);
    }
  }

  /// Load like count for a single quote
  Future<void> loadLikeCount(String quoteId) async {
    try {
      final count = await _repository.getLikeCount(quoteId);

      state = state.copyWith(
        likeCounts: {...state.likeCounts, quoteId: count},
      );
    } catch (e, stackTrace) {
      appLogger.error('Failed to load like count for $quoteId', e, stackTrace);
    }
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

/// Provider for likes repository
final likesRepositoryProvider = Provider<LikesRepository>((ref) {
  return LikesRepository();
});

/// Provider for likes controller
final likesControllerProvider =
    StateNotifierProvider<LikesController, LikesState>((ref) {
  final repository = ref.watch(likesRepositoryProvider);
  return LikesController(repository);
});

