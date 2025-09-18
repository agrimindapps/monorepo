import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciamento de tema do ReceitaAgro
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode_receituagro';
  
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
      await _loadThemeMode();
      _isInitialized = true;
    } catch (e) {
      // Em caso de erro, usa modo system
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Carrega o tema das preferências
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e) {
      // Em caso de erro, usa o tema padrão
      _themeMode = ThemeMode.system;
    }
  }

  /// Define o modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Salva a preferência
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      // Falha silenciosa ao salvar
    }
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

  /// Verifica se está em modo escuro
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}