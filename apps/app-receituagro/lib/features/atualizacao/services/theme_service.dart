import 'package:flutter/material.dart';

/// Interface for theme management following SOLID principles
abstract class IThemeService extends ChangeNotifier {
  /// Current theme mode (light/dark)
  bool get isDark;
  
  /// Listen to theme changes
  void addThemeListener(VoidCallback listener);
  void removeThemeListener(VoidCallback listener);
}

/// Mock implementation for development
class MockThemeService extends ChangeNotifier implements IThemeService {
  bool _isDark = false;
  
  @override
  bool get isDark => _isDark;
  
  /// For testing - toggle theme
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
  
  /// For testing - set specific theme
  void setTheme(bool dark) {
    if (_isDark != dark) {
      _isDark = dark;
      notifyListeners();
    }
  }

  @override
  void addThemeListener(VoidCallback listener) {
    addListener(listener);
  }

  @override
  void removeThemeListener(VoidCallback listener) {
    removeListener(listener);
  }
}

/// Real implementation using ThemeManager (commented for reference)
/*
class ThemeManagerService extends ChangeNotifier implements IThemeService {
  late final ThemeManager _themeManager;
  
  ThemeManagerService() {
    _themeManager = ThemeManager();
    // Listen to theme changes from ThemeManager
    _themeManager.isDark.listen((value) {
      notifyListeners();
    });
  }
  
  @override
  bool get isDark => _themeManager.isDark.value;

  @override
  void addThemeListener(VoidCallback listener) {
    addListener(listener);
  }

  @override
  void removeThemeListener(VoidCallback listener) {
    removeListener(listener);
  }
}
*/