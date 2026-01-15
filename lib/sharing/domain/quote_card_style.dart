import 'package:flutter/material.dart';

/// Enum for quote card style templates
enum QuoteCardStyleType {
  classic,
  modern,
  dark,
}

/// Configuration for a quote card style
class QuoteCardStyle {
  final QuoteCardStyleType type;
  final String name;
  final String description;
  final Gradient? backgroundGradient;
  final Color? backgroundColor;
  final Color textColor;
  final Color authorColor;
  final String fontFamily;
  final double quoteFontSize;
  final double authorFontSize;
  final FontWeight quoteFontWeight;
  final FontWeight authorFontWeight;
  final EdgeInsets padding;
  final bool showBranding;

  const QuoteCardStyle({
    required this.type,
    required this.name,
    required this.description,
    this.backgroundGradient,
    this.backgroundColor,
    required this.textColor,
    required this.authorColor,
    this.fontFamily = 'Roboto',
    this.quoteFontSize = 32.0,
    this.authorFontSize = 20.0,
    this.quoteFontWeight = FontWeight.w400,
    this.authorFontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.all(48.0),
    this.showBranding = true,
  });

  /// Classic style - light background, serif font, minimal
  static QuoteCardStyle classic() {
    return const QuoteCardStyle(
      type: QuoteCardStyleType.classic,
      name: 'Classic',
      description: 'Elegant serif font on light background',
      backgroundColor: Color(0xFFF5F5F5),
      textColor: Color(0xFF2C3E50),
      authorColor: Color(0xFF7F8C8D),
      fontFamily: 'serif',
      quoteFontSize: 28.0,
      authorFontSize: 18.0,
      quoteFontWeight: FontWeight.w400,
      authorFontWeight: FontWeight.w600,
    );
  }

  /// Modern style - gradient background, bold sans-serif
  static QuoteCardStyle modern() {
    return QuoteCardStyle(
      type: QuoteCardStyleType.modern,
      name: 'Modern',
      description: 'Bold typography with vibrant gradient',
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF667EEA),
          Color(0xFF764BA2),
        ],
      ),
      textColor: Colors.white,
      authorColor: Color(0xFFE0E0E0),
      quoteFontSize: 32.0,
      authorFontSize: 20.0,
      quoteFontWeight: FontWeight.w700,
      authorFontWeight: FontWeight.w600,
    );
  }

  /// Dark style - dark background, high contrast
  static QuoteCardStyle dark() {
    return QuoteCardStyle(
      type: QuoteCardStyleType.dark,
      name: 'Dark',
      description: 'High contrast design on dark background',
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF16213E),
        ],
      ),
      textColor: Colors.white,
      authorColor: Color(0xFF00D9FF),
      quoteFontSize: 30.0,
      authorFontSize: 19.0,
      quoteFontWeight: FontWeight.w500,
      authorFontWeight: FontWeight.w700,
    );
  }

  /// Get all available styles
  static List<QuoteCardStyle> allStyles() {
    return [
      classic(),
      modern(),
      dark(),
    ];
  }

  /// Get style by type
  static QuoteCardStyle fromType(QuoteCardStyleType type) {
    switch (type) {
      case QuoteCardStyleType.classic:
        return classic();
      case QuoteCardStyleType.modern:
        return modern();
      case QuoteCardStyleType.dark:
        return dark();
    }
  }
}

