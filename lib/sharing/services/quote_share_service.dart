import 'package:share_plus/share_plus.dart';
import '../../core/utils/logger.dart';
import '../../quotes/domain/quote.dart';

/// Service for sharing quotes as text
class QuoteShareService {
  /// Share quote as plain text
  Future<void> shareQuoteText(Quote quote) async {
    try {
      appLogger.info('Sharing quote text: ${quote.id}');

      final text = _formatQuoteText(quote);

      await Share.share(
        text,
        subject: 'Quote by ${quote.author}',
      );

      appLogger.info('Quote text shared successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to share quote text', e, stackTrace);
      rethrow;
    }
  }

  /// Format quote for text sharing
  String _formatQuoteText(Quote quote) {
    return '"${quote.text}"\n\n— ${quote.author}\n\n'
        'Category: ${quote.category}\n'
        'Shared from QuoteVault';
  }

  /// Share file (image)
  Future<void> shareFile({
    required String filePath,
    required String fileName,
    String? text,
  }) async {
    try {
      appLogger.info('Sharing file: $fileName');

      final xFile = XFile(filePath, name: fileName);

      await Share.shareXFiles(
        [xFile],
        text: text,
        subject: 'Quote Card',
      );

      appLogger.info('File shared successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to share file', e, stackTrace);
      rethrow;
    }
  }
}

