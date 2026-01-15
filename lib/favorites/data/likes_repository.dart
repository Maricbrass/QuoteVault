import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../domain/quote_like.dart';

/// Repository for likes operations
class LikesRepository {
  final SupabaseService _supabaseService;

  LikesRepository({SupabaseService? supabaseService})
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

  /// Like a quote
  Future<QuoteLike> likeQuote(String quoteId) async {
    try {
      final userId = _currentUserId;
      appLogger.info('Liking quote: quoteId=$quoteId, userId=$userId');

      final response = await _supabaseService.client
          .from('quote_likes')
          .insert({
            'user_id': userId,
            'quote_id': quoteId,
          })
          .select()
          .single();

      appLogger.info('Quote liked successfully');
      return QuoteLike.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error liking quote', e, stackTrace);

      // Handle duplicate like
      if (e.code == '23505') {
        throw const StorageException(
          message: 'Quote is already liked',
          code: 'duplicate_like',
        );
      }

      throw StorageException(
        message: 'Failed to like quote: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error liking quote', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Unlike a quote
  Future<void> unlikeQuote(String quoteId) async {
    try {
      final userId = _currentUserId;
      appLogger.info('Unliking quote: quoteId=$quoteId, userId=$userId');

      await _supabaseService.client
          .from('quote_likes')
          .delete()
          .eq('user_id', userId)
          .eq('quote_id', quoteId);

      appLogger.info('Quote unliked successfully');
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error unliking quote', e, stackTrace);
      throw StorageException(
        message: 'Failed to unlike quote: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error unliking quote', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Check if user liked a quote
  Future<bool> isLiked(String quoteId) async {
    try {
      final userId = _currentUserId;

      final response = await _supabaseService.client
          .from('quote_likes')
          .select('id')
          .eq('user_id', userId)
          .eq('quote_id', quoteId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      appLogger.error('Error checking if liked', e, stackTrace);
      return false;
    }
  }

  /// Get like count for a quote
  Future<int> getLikeCount(String quoteId) async {
    try {
      final response = await _supabaseService.client
          .from('quote_likes')
          .select('id')
          .eq('quote_id', quoteId);

      return (response as List).length;
    } catch (e, stackTrace) {
      appLogger.error('Error getting like count', e, stackTrace);
      return 0;
    }
  }

  /// Get all liked quote IDs for current user (for batch checking)
  Future<Set<String>> getLikedQuoteIds() async {
    try {
      final userId = _currentUserId;
      appLogger.info('Fetching liked quote IDs for user: $userId');

      final response = await _supabaseService.client
          .from('quote_likes')
          .select('quote_id')
          .eq('user_id', userId);

      final likedIds = (response as List)
          .map((item) => item['quote_id'] as String)
          .toSet();

      appLogger.info('Fetched ${likedIds.length} liked quote IDs');
      return likedIds;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching liked IDs', e, stackTrace);
      throw StorageException(
        message: 'Failed to fetch liked quotes: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching liked IDs', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get like counts for multiple quotes (batch operation)
  Future<Map<String, int>> getLikeCounts(List<String> quoteIds) async {
    try {
      if (quoteIds.isEmpty) return {};

      appLogger.info('Fetching like counts for ${quoteIds.length} quotes');

      final response = await _supabaseService.client
          .from('quote_likes')
          .select('quote_id')
          .inFilter('quote_id', quoteIds);

      // Count likes per quote
      final likeCounts = <String, int>{};
      for (final item in response as List) {
        final quoteId = item['quote_id'] as String;
        likeCounts[quoteId] = (likeCounts[quoteId] ?? 0) + 1;
      }

      appLogger.info('Fetched like counts for ${likeCounts.length} quotes');
      return likeCounts;
    } catch (e, stackTrace) {
      appLogger.error('Error fetching like counts', e, stackTrace);
      return {};
    }
  }
}

