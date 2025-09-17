import 'package:flutter/material.dart';

/// Provider para gerenciamento de tema do ReceitaAgro
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  /// Modo de tema atual
  ThemeMode get themeMode => _themeMode;

  /// Se o provider foi inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa o provider carregando as preferências salvas
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Por enquanto usa o modo system como padrão
      // Pode ser implementado posteriormente para carregar das SharedPreferences
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Em caso de erro, usa modo system
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Define o modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Aqui pode ser implementado posteriormente para salvar nas SharedPreferences
  }

  /// Alterna entre tema claro e escuro
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        // No modo system, alterna baseado no tema do sistema
        await setThemeMode(ThemeMode.light);
        break;
    }
  }
}