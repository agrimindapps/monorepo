import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  
  // Getters de conveniência
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  // Texto descritivo para UI
  String get themeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
  
  /// Inicializa o provider carregando a preferência salva
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt(_keyThemeMode);
      
      if (savedThemeIndex != null && savedThemeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[savedThemeIndex];
      }
      
      _isInitialized = true;
      debugPrint('🎨 ThemeProvider: Initialized with $_themeMode');
      notifyListeners();
    } catch (e) {
      debugPrint('🎨 ThemeProvider: Error loading theme preference: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Define um novo tema e salva a preferência
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyThemeMode, mode.index);
      debugPrint('🎨 ThemeProvider: Theme changed to $mode');
    } catch (e) {
      debugPrint('🎨 ThemeProvider: Error saving theme preference: $e');
    }
  }
  
  /// Alterna entre claro e escuro (ignora sistema)
  Future<void> toggleLightDark() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
  
  /// Define tema claro
  Future<void> setLightTheme() => setThemeMode(ThemeMode.light);
  
  /// Define tema escuro
  Future<void> setDarkTheme() => setThemeMode(ThemeMode.dark);
  
  /// Define tema do sistema
  Future<void> setSystemTheme() => setThemeMode(ThemeMode.system);
  
  /// Verifica se o tema escuro está ativo (considerando sistema)
  bool isDarkThemeActive(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }
  
  /// Retorna o próximo tema na sequência (para botão de toggle cíclico)
  ThemeMode get nextTheme {
    switch (_themeMode) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }
  
  /// Cicla entre os temas disponíveis
  Future<void> cycleTheme() => setThemeMode(nextTheme);
  
  /// Reseta para o tema padrão (sistema)
  Future<void> resetToDefault() => setThemeMode(ThemeMode.system);
}