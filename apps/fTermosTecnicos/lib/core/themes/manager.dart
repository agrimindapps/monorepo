import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// @deprecated Use ThemeModeNotifier from lib/features/settings/presentation/providers/settings_providers.dart
/// This class uses GetX and will be removed in a future version.
/// Migrate to Riverpod-based theme management.
@Deprecated('Use ThemeModeNotifier with Riverpod instead')
class ThemeManager {
  static final ThemeManager _singleton = ThemeManager._internal();
  ThemeData _currentTheme = lightTheme;
  RxBool isDark = false.obs;

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
    isDark.value = prefs.getBool('currentTheme') ?? false;
    _currentTheme = (isDark.value) ? darkTheme : lightTheme;
  }

  Future<void> saveTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('currentTheme', isDark.value);
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    saveTheme();
    _currentTheme = (_currentTheme == lightTheme) ? darkTheme : lightTheme;
  }
}
