import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../domain/quote.dart';
import '../domain/quote_filter.dart';

/// Repository for quote data operations
/// Handles all quote-related queries and data transformations
class QuoteRepository {
  final SupabaseService _supabaseService;

  QuoteRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Fetch paginated quotes with optional filters
  Future<List<Quote>> fetchQuotes({
    required int limit,
    required int offset,
    QuoteFilter? filter,
  }) async {
    try {
      appLogger.info('Fetching quotes: limit=$limit, offset=$offset, filter=$filter');

      // Build base query
      var query = _supabaseService.client
          .from('quotes')
          .select();

      // Apply filters
      if (filter != null) {
        if (filter.category != null) {
          query = query.eq('category', filter.category!);
        }

        if (filter.author != null) {
          query = query.ilike('author', '%${filter.author}%');
        }

        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          query = query.ilike('text', '%${filter.searchQuery}%');
        }
      }

      // Apply ordering and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final quotes = (response as List)
          .map((json) => Quote.fromJson(json as Map<String, dynamic>))
          .toList();

      appLogger.info('Fetched ${quotes.length} quotes');
      return quotes;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching quotes', e, stackTrace);
      throw StorageException(
        message: 'Failed to load quotes: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching quotes', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Fetch quotes by category
  Future<List<Quote>> fetchQuotesByCategory({
    required String category,
    required int limit,
    required int offset,
  }) async {
    return fetchQuotes(
      limit: limit,
      offset: offset,
      filter: QuoteFilter.byCategory(category),
    );
  }

  /// Search quotes by keyword
  Future<List<Quote>> searchQuotes({
    required String query,
    required int limit,
    required int offset,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return fetchQuotes(
      limit: limit,
      offset: offset,
      filter: QuoteFilter.bySearchQuery(query),
    );
  }

  /// Fetch quotes by author
  Future<List<Quote>> fetchQuotesByAuthor({
    required String author,
    required int limit,
    required int offset,
  }) async {
    return fetchQuotes(
      limit: limit,
      offset: offset,
      filter: QuoteFilter.byAuthor(author),
    );
  }

  /// Get all available categories
  Future<List<String>> fetchCategories() async {
    try {
      appLogger.info('Fetching quote categories');

      final response = await _supabaseService.client
          .from('quotes')
          .select('category')
          .order('category', ascending: true);

      // Extract unique categories
      final categories = (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();

      appLogger.info('Fetched ${categories.length} categories');
      return categories;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching categories', e, stackTrace);
      throw StorageException(
        message: 'Failed to load categories: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching categories', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get total count of quotes (optionally filtered)
  Future<int> getQuoteCount({QuoteFilter? filter}) async {
    try {
      appLogger.info('Fetching quote count with filter: $filter');

      var query = _supabaseService.client
          .from('quotes')
          .select('id');

      // Apply filters
      if (filter != null) {
        if (filter.category != null) {
          query = query.eq('category', filter.category!);
        }

        if (filter.author != null) {
          query = query.ilike('author', '%${filter.author}%');
        }

        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          query = query.ilike('text', '%${filter.searchQuery}%');
        }
      }

      final response = await query;
      final count = (response as List).length;

      appLogger.info('Quote count: $count');
      return count;
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching quote count', e, stackTrace);
      throw StorageException(
        message: 'Failed to get quote count: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching quote count', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Get a random quote (for Quote of the Day feature)
  Future<Quote?> getRandomQuote() async {
    try {
      appLogger.info('Fetching random quote');

      // Get total count first
      final count = await getQuoteCount();
      if (count == 0) return null;

      // Generate random offset
      final randomOffset = DateTime.now().millisecondsSinceEpoch % count;

      final quotes = await fetchQuotes(
        limit: 1,
        offset: randomOffset,
      );

      return quotes.isNotEmpty ? quotes.first : null;
    } catch (e, stackTrace) {
      appLogger.error('Error fetching random quote', e, stackTrace);
      return null;
    }
  }
}

