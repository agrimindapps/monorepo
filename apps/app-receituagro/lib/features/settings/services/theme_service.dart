import 'package:flutter/material.dart';

/// Interface for theme management following SOLID principles
abstract class IThemeService extends ChangeNotifier {
  /// Current theme mode (light/dark)
  ThemeMode get themeMode;
  
  /// Whether the current theme is dark
  bool get isDark;
  
  /// Toggle between light and dark theme
  void toggleTheme();
  
  /// Set specific theme mode
  void setTheme(ThemeMode mode);
  
  /// Get current theme icon
  IconData get themeIcon;
}

/// Mock implementation for development and testing
class MockThemeService extends ChangeNotifier implements IThemeService {
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  ThemeMode get themeMode => _themeMode;
  
  @override
  bool get isDark {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // In a real implementation, this would check system theme
        return false;
    }
  }
  
  @override
  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
  
  @override
  void setTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
  
  @override
  IconData get themeIcon {
    return isDark ? Icons.light_mode : Icons.dark_mode;
  }
}