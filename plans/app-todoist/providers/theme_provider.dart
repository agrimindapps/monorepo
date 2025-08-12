// Flutter imports:
import 'package:flutter/foundation.dart';
// Project imports:
import 'package:fnutrituti/core/themes/manager.dart';
// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

import '../models/background_theme.dart';

class ThemeProvider extends ChangeNotifier {
  BackgroundTheme _currentTheme = BackgroundTheme.defaultGreen;
  SharedPreferences? _prefs;
  final ThemeManager _themeManager = ThemeManager();

  BackgroundTheme get currentTheme => _currentTheme;

  // Getter para dark mode do core ThemeManager
  bool get isDark => _themeManager.isDark.value;

  ThemeProvider() {
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
        _currentTheme = BackgroundTheme.values[savedThemeIndex];
      } else {
        _currentTheme = BackgroundTheme.defaultGreen;
      }

      notifyListeners();
    } catch (e) {
      // Em caso de erro, usar tema padrão
      _currentTheme = BackgroundTheme.defaultGreen;
      if (kDebugMode) {}
    }
  }

  // Alterar tema de fundo
  Future<void> changeTheme(BackgroundTheme newTheme) async {
    if (_currentTheme == newTheme) return;

    _currentTheme = newTheme;
    notifyListeners();

    // Salvar nas preferências
    await _saveTheme();
  }

  // Toggle dark/light mode usando o core ThemeManager
  void toggleDarkMode() {
    _themeManager.toggleTheme();
    notifyListeners();
  }

  // Salvar tema nas preferências
  Future<void> _saveTheme() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setInt('background_theme', _currentTheme.index);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  // Obter todas as opções de tema disponíveis
  List<BackgroundTheme> get availableThemes => BackgroundTheme.values;

  // Verificar se um tema está selecionado
  bool isSelected(BackgroundTheme theme) => _currentTheme == theme;

  // Resetar para tema padrão
  Future<void> resetToDefault() async {
    await changeTheme(BackgroundTheme.defaultGreen);
  }
}
