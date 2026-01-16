/// Enum for theme mode preference
enum ThemeMode {
  system,
  light,
  dark;

  String get displayName {
    switch (this) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

/// Enum for font family preference
enum FontFamily {
  serif,
  sans,
  mono,
  manrope;

  String get displayName {
    switch (this) {
      case FontFamily.serif:
        return 'Serif';
      case FontFamily.sans:
        return 'Sans Serif';
      case FontFamily.mono:
        return 'Monospace';
      case FontFamily.manrope:
        return 'Manrope';
    }
  }

  String get fontFamily {
    switch (this) {
      case FontFamily.serif:
        return 'serif';
      case FontFamily.sans:
        return 'sans-serif';
      case FontFamily.mono:
        return 'monospace';
      case FontFamily.manrope:
        return 'Manrope';
    }
  }
}

/// Enum for accent color preference
enum AccentColor {
  blue,
  purple,
  green,
  orange,
  pink,
  teal,
  primary;

  String get displayName {
    switch (this) {
      case AccentColor.blue:
        return 'Blue';
      case AccentColor.purple:
        return 'Purple';
      case AccentColor.green:
        return 'Green';
      case AccentColor.orange:
        return 'Orange';
      case AccentColor.pink:
        return 'Pink';
      case AccentColor.teal:
        return 'Teal';
      case AccentColor.primary:
        return 'Primary';
    }
  }

  int get colorValue {
    switch (this) {
      case AccentColor.blue:
        return 0xFF2196F3;
      case AccentColor.purple:
        return 0xFF9C27B0;
      case AccentColor.green:
        return 0xFF4CAF50;
      case AccentColor.orange:
        return 0xFFFF9800;
      case AccentColor.pink:
        return 0xFFE91E63;
      case AccentColor.teal:
        return 0xFF009688;
      case AccentColor.primary:
        return 0xFF1111d4;
    }
  }
}
