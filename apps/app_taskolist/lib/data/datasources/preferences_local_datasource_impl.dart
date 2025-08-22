import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import '../../core/theme/theme_mode_enum.dart';
import 'preferences_local_datasource.dart';

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  static const String _boxName = 'preferences';
  static const String _themeKey = 'theme_mode';
  static const String _firstLaunchKey = 'first_launch';

  Box? _box;

  Future<Box> get _preferencesBox async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    try {
      final box = await _preferencesBox;
      final themeValue = box.get(_themeKey, defaultValue: AppThemeMode.system.persistenceValue);
      return AppThemeMode.fromPersistenceValue(themeValue);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar tema: $e');
      }
      return AppThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final box = await _preferencesBox;
      await box.put(_themeKey, themeMode.persistenceValue);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar tema: $e');
      }
    }
  }

  @override
  Future<bool> getFirstLaunch() async {
    try {
      final box = await _preferencesBox;
      return box.get(_firstLaunchKey, defaultValue: true);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar primeiro launch: $e');
      }
      return true;
    }
  }

  @override
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    try {
      final box = await _preferencesBox;
      await box.put(_firstLaunchKey, isFirstLaunch);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar primeiro launch: $e');
      }
    }
  }

  // Método para limpar todas as preferências (útil para debug)
  Future<void> clearAllPreferences() async {
    try {
      final box = await _preferencesBox;
      await box.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar preferências: $e');
      }
    }
  }

  // Método para fechar a box (cleanup)
  Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fechar box de preferências: $e');
      }
    }
  }
}