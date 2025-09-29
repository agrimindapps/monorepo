import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciamento de tema do app ReceitaAgro
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  /// Initialize the theme provider with saved preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      _themeMode = ThemeMode.system;
    }
  }
  
  /// Set theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeString = 'system';
          break;
      }
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Handle error silently - theme change will still work for current session
    }
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newTheme);
  }
  
  /// Check if current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Check if current theme is light
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  /// Check if current theme follows system
  bool get isSystemMode => _themeMode == ThemeMode.system;
}