import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class ThemeManager extends GetxController {
  static final ThemeManager _instance = ThemeManager._internal();

  // Torna o tema reativo com o GetX
  final Rx<ThemeData> _theme = lightTheme.obs;
  final RxBool isDark = false.obs;

  factory ThemeManager() {
    return _instance;
  }

  ThemeManager._internal() {
    _init();
  }

  // Getter do tema como valor observável
  Rx<ThemeData> get theme => _theme;

  // Getter para o tema atual sem ser observável (para compatibilidade)
  ThemeData get currentTheme => _theme.value;

  _init() async {
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool('currentTheme') ?? false;
    _theme.value = (isDark.value) ? darkTheme : lightTheme;
  }

  Future<void> saveTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('currentTheme', isDark.value);
  }

  void toggleTheme() {
    isDark.value = !isDark.value;
    _theme.value = (isDark.value) ? darkTheme : lightTheme;
    saveTheme();
    // Força atualização do GetX
    update();
  }
}
