import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../data/daily_quote_repository.dart';
import '../domain/daily_quote.dart';

/// Provider for daily quote repository
final dailyQuoteRepositoryProvider = Provider<DailyQuoteRepository>((ref) {
  return DailyQuoteRepository();
});

/// Provider for daily quote
final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  try {
    appLogger.info('Fetching daily quote');
    final repository = ref.watch(dailyQuoteRepositoryProvider);
    final dailyQuote = await repository.getDailyQuote();
    appLogger.info('Daily quote fetched: ${dailyQuote.quote.author}');
    return dailyQuote;
  } catch (e, stackTrace) {
    appLogger.error('Failed to fetch daily quote', e, stackTrace);
    rethrow;
  }
});

