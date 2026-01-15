import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';
import '../domain/collection.dart';

/// Repository for collections operations
class CollectionsRepository {
  final SupabaseService _supabaseService;

  CollectionsRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Get current user ID
  String get _currentUserId {
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) {
      throw const AuthException(
        message: 'User not authenticated',
        code: 'not_authenticated',
      );
    }
    return userId;
  }

  /// Create a new collection
  Future<Collection> createCollection({
    required String name,
    String? description,
  }) async {
    try {
      final userId = _currentUserId;
      appLogger.info('Creating collection: name=$name, userId=$userId');

      final response = await _supabaseService.client
          .from('collections')
          .insert({
            'name': name,
            'description': description,
            'owner_id': userId,
          })
          .select()
          .single();

      appLogger.info('Collection created successfully');
      return Collection.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error creating collection', e, stackTrace);
      throw StorageException(
        message: 'Failed to create collection: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error creating collection', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Update collection
  Future<Collection> updateCollection({
    required String collectionId,
    String? name,
    String? description,
  }) async {
    try {
      appLogger.info('Updating collection: id=$collectionId');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;

      if (updates.isEmpty) {
        throw const StorageException(
          message: 'No updates provided',
          code: 'no_updates',
        );
      }

      final response = await _supabaseService.client
          .from('collections')
          .update(updates)
          .eq('id', collectionId)
          .select()
          .single();

      appLogger.info('Collection updated successfully');
      return Collection.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error updating collection', e, stackTrace);
      throw StorageException(
        message: 'Failed to update collection: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error updating collection', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Delete collection
  Future<void> deleteCollection(String collectionId) async {
    try {
      appLogger.info('Deleting collection: id=$collectionId');

      await _supabaseService.client
          .from('collections')
          .delete()
          .eq('id', collectionId);

      appLogger.info('Collection deleted successfully');
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error deleting collection', e, stackTrace);
      throw StorageException(
        message: 'Failed to delete collection: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error deleting collection', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get all collections for current user
  Future<List<Collection>> getCollections() async {
    try {
      final userId = _currentUserId;
      appLogger.info('Fetching collections for user: $userId');

      final response = await _supabaseService.client
          .from('collections')
          .select('*, collection_quotes(count)')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final collections = (response as List).map((json) {
        // Extract quote count from aggregated data
        final quoteCount = json['collection_quotes'] != null
            ? (json['collection_quotes'] as List).isNotEmpty
                ? (json['collection_quotes'][0]['count'] as int? ?? 0)
                : 0
            : 0;

        return Collection.fromJson({
          ...json,
          'quote_count': quoteCount,
        });
      }).toList();

      appLogger.info('Fetched ${collections.length} collections');
      return collections;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching collections', e, stackTrace);
      throw StorageException(
        message: 'Failed to fetch collections: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching collections', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get a single collection
  Future<Collection> getCollection(String collectionId) async {
    try {
      appLogger.info('Fetching collection: id=$collectionId');

      final response = await _supabaseService.client
          .from('collections')
          .select()
          .eq('id', collectionId)
          .single();

      // Get quote count
      final countResponse = await _supabaseService.client
          .from('collection_quotes')
          .select('id')
          .eq('collection_id', collectionId);

      final quoteCount = (countResponse as List).length;

      return Collection.fromJson({
        ...response,
        'quote_count': quoteCount,
      });
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching collection', e, stackTrace);
      throw StorageException(
        message: 'Failed to fetch collection: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching collection', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Add quote to collection
  Future<void> addQuoteToCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    try {
      appLogger.info('Adding quote to collection: collectionId=$collectionId, quoteId=$quoteId');

      await _supabaseService.client
          .from('collection_quotes')
          .insert({
            'collection_id': collectionId,
            'quote_id': quoteId,
          });

      appLogger.info('Quote added to collection successfully');
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error adding quote to collection', e, stackTrace);

      // Handle duplicate
      if (e.code == '23505') {
        throw const StorageException(
          message: 'Quote is already in this collection',
          code: 'duplicate_collection_quote',
        );
      }

      throw StorageException(
        message: 'Failed to add quote to collection: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error adding quote to collection', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Remove quote from collection
  Future<void> removeQuoteFromCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    try {
      appLogger.info('Removing quote from collection: collectionId=$collectionId, quoteId=$quoteId');

      await _supabaseService.client
          .from('collection_quotes')
          .delete()
          .eq('collection_id', collectionId)
          .eq('quote_id', quoteId);

      appLogger.info('Quote removed from collection successfully');
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error removing quote from collection', e, stackTrace);
      throw StorageException(
        message: 'Failed to remove quote from collection: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error removing quote from collection', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get quotes in a collection
  Future<List<Quote>> getCollectionQuotes(String collectionId) async {
    try {
      appLogger.info('Fetching quotes for collection: id=$collectionId');

      final response = await _supabaseService.client
          .from('collection_quotes')
          .select('quote_id, quotes(*)')
          .eq('collection_id', collectionId)
          .order('added_at', ascending: false);

      final quotes = (response as List)
          .map((item) {
            final quoteData = item['quotes'] as Map<String, dynamic>;
            return Quote.fromJson(quoteData);
          })
          .toList();

      appLogger.info('Fetched ${quotes.length} quotes from collection');
      return quotes;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching collection quotes', e, stackTrace);
      throw StorageException(
        message: 'Failed to fetch collection quotes: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching collection quotes', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Check if quote is in collection
  Future<bool> isQuoteInCollection({
    required String collectionId,
    required String quoteId,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('collection_quotes')
          .select('id')
          .eq('collection_id', collectionId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      appLogger.error('Error checking if quote is in collection', e, stackTrace);
      return false;
    }
  }
}

