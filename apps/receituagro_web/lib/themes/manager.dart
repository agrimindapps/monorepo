import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class ThemeManager {
  static final ThemeManager _singleton = ThemeManager._internal();
  ThemeData _currentTheme = lightTheme;
  bool isDark = false;

  factory ThemeManager() {
    return _singleton;
  }

  ThemeManager._internal() {
    _init();
  }

  ThemeData get currentTheme => _currentTheme;

  _init() async {
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('currentTheme') ?? false;
    _currentTheme = (isDark) ? darkTheme : lightTheme;
  }

  Future<void> saveTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('currentTheme', isDark);
  }

  void toggleTheme() {
    isDark = !isDark;
    saveTheme();
    _currentTheme = (_currentTheme == lightTheme) ? darkTheme : lightTheme;
  }
}
