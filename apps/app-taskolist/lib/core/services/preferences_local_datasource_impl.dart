import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme_mode_enum.dart';
import 'preferences_local_datasource.dart';

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  static const String _themeKey = 'theme_mode';
  static const String _firstLaunchKey = 'first_launch';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    try {
      final prefs = await _preferences;
      final themeValue = prefs.getString(_themeKey) ?? AppThemeMode.system.persistenceValue;
      return AppThemeMode.fromPersistenceValue(themeValue);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar tema: $e');
      }
      return AppThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(_themeKey, themeMode.persistenceValue);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar tema: $e');
      }
    }
  }

  @override
  Future<bool> getFirstLaunch() async {
    try {
      final prefs = await _preferences;
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar primeiro launch: $e');
      }
      return true;
    }
  }

  @override
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    try {
      final prefs = await _preferences;
      await prefs.setBool(_firstLaunchKey, isFirstLaunch);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar primeiro launch: $e');
      }
    }
  }
  
  Future<void> clearAllPreferences() async {
    try {
      final prefs = await _preferences;
      await prefs.clear();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao limpar preferências: $e');
      }
    }
  }
  
  Future<void> close() async {
    // SharedPreferences doesn't need to be closed
    _prefs = null;
  }
}
