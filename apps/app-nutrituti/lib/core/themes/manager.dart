// STUB: Temporary stub to fix compilation errors
// TODO: Implement proper ThemeManager or migrate to Flutter ThemeData

import 'package:flutter/material.dart';

/// ThemeManager - Manages app theme state
/// This is a stub implementation to fix compilation errors
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();

  factory ThemeManager() => _instance;

  ThemeManager._internal();

  /// ValueNotifier for dark mode state
  final ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

  /// Toggle dark mode
  void toggleDarkMode() {
    isDark.value = !isDark.value;
  }

  /// Set dark mode explicitly
  void setDarkMode(bool value) {
    isDark.value = value;
  }

  /// Get current ThemeData based on dark mode
  ThemeData get currentTheme {
    return isDark.value ? darkTheme : lightTheme;
  }

  /// Light theme
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  /// Dark theme
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}

/// Extension on BuildContext for easy theme access
extension ThemeManagerExtension on BuildContext {
  /// Get current theme data
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Primary color
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Secondary color
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;

  /// Background color
  Color get backgroundColor => Theme.of(this).colorScheme.background;

  /// Surface color
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Error color
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// On Primary color
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;

  /// On Secondary color
  Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;

  /// On Background color
  Color get onBackgroundColor => Theme.of(this).colorScheme.onBackground;

  /// On Surface color
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;

  /// On Error color
  Color get onErrorColor => Theme.of(this).colorScheme.onError;

  // Text Styles
  TextStyle get displayLarge => Theme.of(this).textTheme.displayLarge ?? const TextStyle();
  TextStyle get displayMedium => Theme.of(this).textTheme.displayMedium ?? const TextStyle();
  TextStyle get displaySmall => Theme.of(this).textTheme.displaySmall ?? const TextStyle();
  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge ?? const TextStyle();
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium ?? const TextStyle();
  TextStyle get headlineSmall => Theme.of(this).textTheme.headlineSmall ?? const TextStyle();
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge ?? const TextStyle();
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium ?? const TextStyle();
  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall ?? const TextStyle();
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge ?? const TextStyle();
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium ?? const TextStyle();
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall ?? const TextStyle();
  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge ?? const TextStyle();
  TextStyle get labelMedium => Theme.of(this).textTheme.labelMedium ?? const TextStyle();
  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall ?? const TextStyle();

  // Media Query helpers
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
}
