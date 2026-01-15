import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';
import '../domain/daily_quote.dart';

/// Repository for daily quote operations
class DailyQuoteRepository {
  final SupabaseService _supabaseService;
  static const String _dailyQuoteKey = 'daily_quote';
  static const String _dailyQuoteDateKey = 'daily_quote_date';
  static const String _totalQuoteCountKey = 'total_quote_count';

  DailyQuoteRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Get daily quote (with caching)
  Future<DailyQuote> getDailyQuote() async {
    try {
      final todayString = DailyQuote.getTodayString();
      appLogger.info('Getting daily quote for $todayString');

      // Check cache first
      final cachedQuote = await _getCachedDailyQuote();
      if (cachedQuote != null && cachedQuote.isValidForToday()) {
        appLogger.info('Returning cached daily quote');
        return cachedQuote;
      }

      // Fetch new daily quote
      final quote = await _fetchDailyQuote(todayString);
      final dailyQuote = DailyQuote(
        quote: quote,
        date: DateTime.now(),
        dateString: todayString,
      );

      // Cache it
      await _cacheDailyQuote(dailyQuote);

      appLogger.info('Daily quote fetched and cached: ${quote.id}');
      return dailyQuote;
    } catch (e, stackTrace) {
      appLogger.error('Failed to get daily quote', e, stackTrace);

      // Try to return cached quote even if expired
      final cachedQuote = await _getCachedDailyQuote();
      if (cachedQuote != null) {
        appLogger.info('Returning expired cached quote as fallback');
        return cachedQuote;
      }

      throw StorageException.fromError(e);
    }
  }

  /// Fetch daily quote from Supabase
  Future<Quote> _fetchDailyQuote(String dateString) async {
    try {
      // Get total quote count (cached)
      final totalCount = await _getTotalQuoteCount();

      if (totalCount == 0) {
        throw const StorageException(
          message: 'No quotes available in database',
          code: 'no_quotes',
        );
      }

      // Deterministic selection: hash date to get index
      final index = _getQuoteIndexForDate(dateString, totalCount);

      appLogger.info('Fetching quote at index $index of $totalCount');

      // Fetch quote at that index
      final response = await _supabaseService.client
          .from('quotes')
          .select()
          .order('created_at', ascending: true)
          .range(index, index)
          .single();

      return Quote.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.error('Failed to fetch daily quote from Supabase', e, stackTrace);
      rethrow;
    }
  }

  /// Get total quote count (with caching)
  Future<int> _getTotalQuoteCount() async {
    try {
      // Check cache
      final prefs = await SharedPreferences.getInstance();
      final cachedCount = prefs.getInt(_totalQuoteCountKey);

      if (cachedCount != null && cachedCount > 0) {
        return cachedCount;
      }

      // Fetch from database
      final response = await _supabaseService.client
          .from('quotes')
          .select('id');

      final count = (response as List).length;

      // Cache it
      await prefs.setInt(_totalQuoteCountKey, count);

      appLogger.info('Total quote count: $count');
      return count;
    } catch (e, stackTrace) {
      appLogger.error('Failed to get total quote count', e, stackTrace);
      // Return default if error
      return 100;
    }
  }

  /// Deterministic quote selection based on date
  int _getQuoteIndexForDate(String dateString, int totalCount) {
    // Simple hash: sum of ASCII values of date string
    int hash = 0;
    for (int i = 0; i < dateString.length; i++) {
      hash += dateString.codeUnitAt(i);
    }

    // Add year, month, day components for more variation
    final parts = dateString.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    hash = (hash * 31) + year;
    hash = (hash * 31) + month;
    hash = (hash * 31) + day;

    // Ensure positive and within range
    return hash.abs() % totalCount;
  }

  /// Get cached daily quote
  Future<DailyQuote?> _getCachedDailyQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final quoteJson = prefs.getString(_dailyQuoteKey);
      final dateString = prefs.getString(_dailyQuoteDateKey);

      if (quoteJson == null || dateString == null) {
        return null;
      }

      final quote = Quote.fromJson(json.decode(quoteJson));
      final date = DateTime.parse(dateString);

      return DailyQuote(
        quote: quote,
        date: date,
        dateString: dateString.split('T')[0], // Extract YYYY-MM-DD
      );
    } catch (e, stackTrace) {
      appLogger.error('Failed to get cached daily quote', e, stackTrace);
      return null;
    }
  }

  /// Cache daily quote
  Future<void> _cacheDailyQuote(DailyQuote dailyQuote) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _dailyQuoteKey,
        json.encode(dailyQuote.quote.toJson()),
      );
      await prefs.setString(
        _dailyQuoteDateKey,
        dailyQuote.date.toIso8601String(),
      );

      appLogger.info('Daily quote cached');
    } catch (e, stackTrace) {
      appLogger.error('Failed to cache daily quote', e, stackTrace);
    }
  }

  /// Clear cache (for testing)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dailyQuoteKey);
      await prefs.remove(_dailyQuoteDateKey);
      await prefs.remove(_totalQuoteCountKey);
      appLogger.info('Daily quote cache cleared');
    } catch (e, stackTrace) {
      appLogger.error('Failed to clear cache', e, stackTrace);
    }
  }
}

