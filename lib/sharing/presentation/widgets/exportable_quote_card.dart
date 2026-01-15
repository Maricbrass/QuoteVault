import 'package:flutter/material.dart';
import '../../../quotes/domain/quote.dart';
import '../../domain/quote_card_style.dart';

/// Widget that renders a quote card for export
/// This widget is captured as an image
class ExportableQuoteCard extends StatelessWidget {
  final Quote quote;
  final QuoteCardStyle style;
  final double width;
  final double height;

  const ExportableQuoteCard({
    super.key,
    required this.quote,
    required this.style,
    this.width = 1080,
    this.height = 1920,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: style.backgroundGradient,
          color: style.backgroundColor,
        ),
        child: Padding(
          padding: style.padding,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),

                // Opening quote mark
                Text(
                  '"',
                  style: TextStyle(
                    color: style.textColor.withAlpha(77),
                    fontSize: style.quoteFontSize * 2,
                    fontFamily: style.fontFamily,
                    fontWeight: style.quoteFontWeight,
                    height: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Quote text
                Text(
                  quote.text,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: _calculateFontSize(quote.text.length),
                    fontFamily: style.fontFamily,
                    fontWeight: style.quoteFontWeight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Author
                Text(
                  '— ${quote.author}',
                  style: TextStyle(
                    color: style.authorColor,
                    fontSize: style.authorFontSize,
                    fontFamily: style.fontFamily,
                    fontWeight: style.authorFontWeight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Category tag
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: style.textColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      quote.category.toUpperCase(),
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 150),

                // Branding
                if (style.showBranding)
                  Text(
                    'QuoteVault',
                    style: TextStyle(
                      color: style.textColor.withAlpha(77),
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate font size based on quote length
  double _calculateFontSize(int length) {
    if (length < 50) {
      return style.quoteFontSize;
    } else if (length < 100) {
      return style.quoteFontSize * 0.85;
    } else if (length < 150) {
      return style.quoteFontSize * 0.75;
    } else {
      return style.quoteFontSize * 0.65;
    }
  }
}
