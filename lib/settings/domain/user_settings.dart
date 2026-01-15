import 'settings_enums.dart';

/// Comprehensive user settings model
class UserSettings {
  // Appearance
  final ThemeMode themeMode;
  final AccentColor accentColor;

  // Typography
  final FontFamily fontFamily;
  final double fontSizeScale;
  final double lineSpacing;

  // Reading preferences
  final bool showAuthor;
  final bool showCategory;

  // Behavior
  final bool autoSaveFavorites;
  final bool hapticFeedback;

  // Version for migration
  final int version;

  const UserSettings({
    this.themeMode = ThemeMode.system,
    this.accentColor = AccentColor.blue,
    this.fontFamily = FontFamily.serif,
    this.fontSizeScale = 1.0,
    this.lineSpacing = 1.5,
    this.showAuthor = true,
    this.showCategory = true,
    this.autoSaveFavorites = false,
    this.hapticFeedback = true,
    this.version = 1,
  });

  /// Default settings
  factory UserSettings.defaults() => const UserSettings();

  /// Create from JSON
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['theme_mode'],
        orElse: () => ThemeMode.system,
      ),
      accentColor: AccentColor.values.firstWhere(
        (e) => e.name == json['accent_color'],
        orElse: () => AccentColor.blue,
      ),
      fontFamily: FontFamily.values.firstWhere(
        (e) => e.name == json['font_family'],
        orElse: () => FontFamily.serif,
      ),
      fontSizeScale: (json['font_size_scale'] as num?)?.toDouble() ?? 1.0,
      lineSpacing: (json['line_spacing'] as num?)?.toDouble() ?? 1.5,
      showAuthor: json['show_author'] as bool? ?? true,
      showCategory: json['show_category'] as bool? ?? true,
      autoSaveFavorites: json['auto_save_favorites'] as bool? ?? false,
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode.name,
      'accent_color': accentColor.name,
      'font_family': fontFamily.name,
      'font_size_scale': fontSizeScale,
      'line_spacing': lineSpacing,
      'show_author': showAuthor,
      'show_category': showCategory,
      'auto_save_favorites': autoSaveFavorites,
      'haptic_feedback': hapticFeedback,
      'version': version,
    };
  }

  /// Create copy with modifications
  UserSettings copyWith({
    ThemeMode? themeMode,
    AccentColor? accentColor,
    FontFamily? fontFamily,
    double? fontSizeScale,
    double? lineSpacing,
    bool? showAuthor,
    bool? showCategory,
    bool? autoSaveFavorites,
    bool? hapticFeedback,
    int? version,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      showAuthor: showAuthor ?? this.showAuthor,
      showCategory: showCategory ?? this.showCategory,
      autoSaveFavorites: autoSaveFavorites ?? this.autoSaveFavorites,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      version: version ?? this.version,
    );
  }

  /// Validate font size scale
  double get validFontSizeScale {
    return fontSizeScale.clamp(0.8, 1.4);
  }

  /// Validate line spacing
  double get validLineSpacing {
    return lineSpacing.clamp(1.2, 2.0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.themeMode == themeMode &&
        other.accentColor == accentColor &&
        other.fontFamily == fontFamily &&
        other.fontSizeScale == fontSizeScale &&
        other.lineSpacing == lineSpacing &&
        other.showAuthor == showAuthor &&
        other.showCategory == showCategory &&
        other.autoSaveFavorites == autoSaveFavorites &&
        other.hapticFeedback == hapticFeedback;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      accentColor,
      fontFamily,
      fontSizeScale,
      lineSpacing,
      showAuthor,
      showCategory,
      autoSaveFavorites,
      hapticFeedback,
    );
  }

  @override
  String toString() {
    return 'UserSettings(theme: $themeMode, accent: $accentColor, font: $fontFamily)';
  }
}

