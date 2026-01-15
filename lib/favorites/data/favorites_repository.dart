import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';
import '../domain/favorite.dart';

/// Repository for favorites operations
class FavoritesRepository {
  final SupabaseService _supabaseService;

  FavoritesRepository({SupabaseService? supabaseService})
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

  /// Add quote to favorites
  Future<Favorite> addFavorite(String quoteId) async {
    try {
      final userId = _currentUserId;
      appLogger.info('Adding favorite: quoteId=$quoteId, userId=$userId');

      final response = await _supabaseService.client
          .from('user_favorites')
          .insert({
            'user_id': userId,
            'quote_id': quoteId,
          })
          .select()
          .single();

      appLogger.info('Favorite added successfully');
      return Favorite.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error adding favorite', e, stackTrace);

      // Handle duplicate favorite
      if (e.code == '23505') {
        throw const StorageException(
          message: 'Quote is already in favorites',
          code: 'duplicate_favorite',
        );
      }

      throw StorageException(
        message: 'Failed to add favorite: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error adding favorite', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Remove quote from favorites
  Future<void> removeFavorite(String quoteId) async {
    try {
      final userId = _currentUserId;
      appLogger.info('Removing favorite: quoteId=$quoteId, userId=$userId');

      await _supabaseService.client
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('quote_id', quoteId);

      appLogger.info('Favorite removed successfully');
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error removing favorite', e, stackTrace);
      throw StorageException(
        message: 'Failed to remove favorite: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error removing favorite', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Check if quote is favorited
  Future<bool> isFavorited(String quoteId) async {
    try {
      final userId = _currentUserId;

      final response = await _supabaseService.client
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      appLogger.error('Error checking if favorited', e, stackTrace);
      return false;
    }
  }

  /// Get all favorite quote IDs for current user (for batch checking)
  Future<Set<String>> getFavoriteQuoteIds() async {
    try {
      final userId = _currentUserId;
      appLogger.info('Fetching favorite IDs for user: $userId');

      final response = await _supabaseService.client
          .from('user_favorites')
          .select('quote_id')
          .eq('user_id', userId);

      final favoriteIds = (response as List)
          .map((item) => item['quote_id'] as String)
          .toSet();

      appLogger.info('Fetched ${favoriteIds.length} favorite IDs');
      return favoriteIds;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching favorite IDs', e, stackTrace);
      throw StorageException(
        message: 'Failed to fetch favorites: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching favorite IDs', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get all favorited quotes with full quote details
  Future<List<Quote>> getFavoritedQuotes() async {
    try {
      final userId = _currentUserId;
      appLogger.info('Fetching favorited quotes for user: $userId');

      // Join user_favorites with quotes table
      final response = await _supabaseService.client
          .from('user_favorites')
          .select('quote_id, quotes(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final quotes = (response as List)
          .map((item) {
            final quoteData = item['quotes'] as Map<String, dynamic>;
            return Quote.fromJson(quoteData);
          })
          .toList();

      appLogger.info('Fetched ${quotes.length} favorited quotes');
      return quotes;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching favorited quotes', e, stackTrace);
      throw StorageException(
        message: 'Failed to fetch favorited quotes: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching favorited quotes', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get favorite count for current user
  Future<int> getFavoriteCount() async {
    try {
      final userId = _currentUserId;

      final response = await _supabaseService.client
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e, stackTrace) {
      appLogger.error('Error getting favorite count', e, stackTrace);
      return 0;
    }
  }
}

