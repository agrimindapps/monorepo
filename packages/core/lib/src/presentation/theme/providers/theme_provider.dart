import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciamento de tema com persistência
///
/// Funcionalidades:
/// - Persistência automática via SharedPreferences
/// - Error handling com fallback para ThemeMode.system
/// - Async initialization com state tracking
/// - Smart toggle (ignora system mode)
/// - Context-aware isDarkMode() helper
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Inicializa o provider carregando o tema salvo
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadThemeMode();
    _isInitialized = true;
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

  /// Altera o tema com persistência automática
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();

    // Salva a preferência
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.toString());
    } catch (e) {
      // Falha silenciosa ao salvar - não bloqueia o funcionamento
    }
  }

  /// Alterna entre claro e escuro (ignora system)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Verifica se está em modo escuro considerando o contexto
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}