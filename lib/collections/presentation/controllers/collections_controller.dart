import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';
import '../data/collections_repository.dart';
import '../domain/collection.dart';

/// State for collections
class CollectionsState {
  final List<Collection> collections;
  final bool isLoading;
  final bool isCreating;
  final String? errorMessage;

  const CollectionsState({
    this.collections = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.errorMessage,
  });

  /// Get collection by ID
  Collection? getCollection(String id) {
    try {
      return collections.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  CollectionsState copyWith({
    List<Collection>? collections,
    bool? isLoading,
    bool? isCreating,
    String? errorMessage,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      errorMessage: errorMessage,
    );
  }
}

/// Controller for collections
class CollectionsController extends StateNotifier<CollectionsState> {
  final CollectionsRepository _repository;

  CollectionsController(this._repository) : super(const CollectionsState()) {
    // Load collections on initialization
    loadCollections();
  }

  /// Load all collections
  Future<void> loadCollections() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Loading collections');
      final collections = await _repository.getCollections();

      state = state.copyWith(
        isLoading: false,
        collections: collections,
      );

      appLogger.info('Loaded ${collections.length} collections');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load collections', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Create a new collection
  Future<Collection?> createCollection({
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isCreating: true, errorMessage: null);

    try {
      appLogger.info('Creating collection: $name');
      final collection = await _repository.createCollection(
        name: name,
        description: description,
      );

      // Add to local state
      state = state.copyWith(
        isCreating: false,
        collections: [collection, ...state.collections],
      );

      appLogger.info('Collection created successfully');
      return collection;
    } catch (e, stackTrace) {
      appLogger.error('Failed to create collection', e, stackTrace);
      state = state.copyWith(
        isCreating: false,
        errorMessage: _getErrorMessage(e),
      );
      return null;
    }
  }

  /// Update a collection
  Future<void> updateCollection({
    required String collectionId,
    String? name,
    String? description,
  }) async {
    try {
      appLogger.info('Updating collection: $collectionId');
      final updatedCollection = await _repository.updateCollection(
        collectionId: collectionId,
        name: name,
        description: description,
      );

      // Update in local state
      final updatedCollections = state.collections.map((c) {
        return c.id == collectionId ? updatedCollection : c;
      }).toList();

      state = state.copyWith(collections: updatedCollections);

      appLogger.info('Collection updated successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to update collection', e, stackTrace);
      state = state.copyWith(errorMessage: _getErrorMessage(e));
      rethrow;
    }
  }

  /// Delete a collection
  Future<void> deleteCollection(String collectionId) async {
    // Optimistically remove from state
    final previousCollections = state.collections;
    final updatedCollections =
        state.collections.where((c) => c.id != collectionId).toList();

    state = state.copyWith(collections: updatedCollections);

    try {
      appLogger.info('Deleting collection: $collectionId');
      await _repository.deleteCollection(collectionId);
      appLogger.info('Collection deleted successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to delete collection', e, stackTrace);

      // Rollback on failure
      state = state.copyWith(
        collections: previousCollections,
        errorMessage: _getErrorMessage(e),
      );
      rethrow;
    }
  }

  /// Add quote to collection
  Future<void> addQuoteToCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    try {
      appLogger.info('Adding quote to collection: $collectionId');
      await _repository.addQuoteToCollection(
        collectionId: collectionId,
        quoteId: quoteId,
      );

      // Update quote count in local state
      final updatedCollections = state.collections.map((c) {
        if (c.id == collectionId) {
          return c.copyWith(quoteCount: c.quoteCount + 1);
        }
        return c;
      }).toList();

      state = state.copyWith(collections: updatedCollections);

      appLogger.info('Quote added to collection successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to add quote to collection', e, stackTrace);
      state = state.copyWith(errorMessage: _getErrorMessage(e));
      rethrow;
    }
  }

  /// Remove quote from collection
  Future<void> removeQuoteFromCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    try {
      appLogger.info('Removing quote from collection: $collectionId');
      await _repository.removeQuoteFromCollection(
        collectionId: collectionId,
        quoteId: quoteId,
      );

      // Update quote count in local state
      final updatedCollections = state.collections.map((c) {
        if (c.id == collectionId) {
          final newCount = c.quoteCount > 0 ? c.quoteCount - 1 : 0;
          return c.copyWith(quoteCount: newCount);
        }
        return c;
      }).toList();

      state = state.copyWith(collections: updatedCollections);

      appLogger.info('Quote removed from collection successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to remove quote from collection', e, stackTrace);
      state = state.copyWith(errorMessage: _getErrorMessage(e));
      rethrow;
    }
  }

  /// Refresh collections
  Future<void> refresh() async {
    await loadCollections();
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

/// Provider for collections repository
final collectionsRepositoryProvider = Provider<CollectionsRepository>((ref) {
  return CollectionsRepository();
});

/// Provider for collections controller
final collectionsControllerProvider =
    StateNotifierProvider<CollectionsController, CollectionsState>((ref) {
  final repository = ref.watch(collectionsRepositoryProvider);
  return CollectionsController(repository);
});

/// Provider for getting quotes in a collection
final collectionQuotesProvider =
    FutureProvider.family<List<Quote>, String>((ref, collectionId) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  return repository.getCollectionQuotes(collectionId);
});

