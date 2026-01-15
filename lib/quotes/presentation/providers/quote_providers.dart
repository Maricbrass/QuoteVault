import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/quote_repository.dart';
import '../../domain/quote.dart';
import '../controllers/quote_feed_controller.dart';

/// Provider for fetching all available categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  return repository.fetchCategories();
});

/// Provider family for fetching quotes by category
final categoryQuotesProvider =
    FutureProvider.family<List<Quote>, String>((ref, category) async {
  final repository = ref.watch(quoteRepositoryProvider);
  return repository.fetchQuotesByCategory(
    category: category,
    limit: 50, // Load more for category view
    offset: 0,
  );
});

/// Provider for random quote (Quote of the Day)
final randomQuoteProvider = FutureProvider<Quote?>((ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  return repository.getRandomQuote();
});

