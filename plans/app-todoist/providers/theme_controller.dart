// Flutter imports:
import 'package:flutter/foundation.dart';
// Project imports:
import 'package:fnutrituti/core/themes/manager.dart';
// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/background_theme.dart';

/// Theme Controller migrado para GetX
class TodoistThemeController extends GetxController {
  final Rx<BackgroundTheme> _currentTheme = Rx<BackgroundTheme>(BackgroundTheme.defaultGreen);
  SharedPreferences? _prefs;
  final ThemeManager _themeManager = ThemeManager();

  // Getters reativos
  BackgroundTheme get currentTheme => _currentTheme.value;
  bool get isDark => _themeManager.isDark.value;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _loadTheme();
  }

  // Carregar tema salvo das preferências
  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = _prefs?.getInt('background_theme') ?? 0;

      // Verificar se o índice é válido
      if (savedThemeIndex >= 0 &&
          savedThemeIndex < BackgroundTheme.values.length) {
        _currentTheme.value = BackgroundTheme.values[savedThemeIndex];
      } else {
        _currentTheme.value = BackgroundTheme.defaultGreen;
      }
    } catch (e) {
      // Em caso de erro, usar tema padrão
      _currentTheme.value = BackgroundTheme.defaultGreen;
      if (kDebugMode) {
        print('Erro ao carregar tema: $e');
      }
    }
  }

  // Alterar tema de fundo
  Future<void> changeTheme(BackgroundTheme newTheme) async {
    if (_currentTheme.value == newTheme) return;

    _currentTheme.value = newTheme;

    // Salvar nas preferências
    await _saveTheme();
  }

  // Toggle dark/light mode usando o core ThemeManager
  void toggleDarkMode() {
    _themeManager.toggleTheme();
  }

  // Salvar tema nas preferências
  Future<void> _saveTheme() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setInt('background_theme', _currentTheme.value.index);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar tema: $e');
      }
    }
  }

  // Obter todas as opções de tema disponíveis
  List<BackgroundTheme> get availableThemes => BackgroundTheme.values;

  // Verificar se um tema está selecionado
  bool isSelected(BackgroundTheme theme) => _currentTheme.value == theme;

  // Resetar para tema padrão
  Future<void> resetToDefault() async {
    await changeTheme(BackgroundTheme.defaultGreen);
  }

  // Debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'current_theme': _currentTheme.value.toString(),
      'is_dark': isDark,
      'available_themes_count': availableThemes.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
