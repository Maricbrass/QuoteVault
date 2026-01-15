import '../../../quotes/domain/quote.dart';

/// Domain model for Daily Quote
class DailyQuote {
  final Quote quote;
  final DateTime date;
  final String dateString; // YYYY-MM-DD format

  const DailyQuote({
    required this.quote,
    required this.date,
    required this.dateString,
  });

  /// Check if this daily quote is still valid for today
  bool isValidForToday() {
    final today = DateTime.now();
    final todayString = _formatDate(today);
    return dateString == todayString;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get today's date string
  static String getTodayString() {
    return _formatDate(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyQuote &&
        other.quote == quote &&
        other.dateString == dateString;
  }

  @override
  int get hashCode => quote.hashCode ^ dateString.hashCode;

  @override
  String toString() => 'DailyQuote(date: $dateString, quote: ${quote.id})';
}

