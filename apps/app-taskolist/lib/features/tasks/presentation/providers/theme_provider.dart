import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/preferences_local_datasource.dart';
import '../../../../core/services/preferences_local_datasource_impl.dart';
import '../../../../core/theme/theme_mode_enum.dart';
final preferencesDataSourceProvider = Provider<PreferencesLocalDataSource>((
  ref,
) {
  return PreferencesLocalDataSourceImpl();
});
class ThemeNotifier extends StateNotifier<AsyncValue<AppThemeMode>> {
  final PreferencesLocalDataSource _preferencesDataSource;

  ThemeNotifier(this._preferencesDataSource)
    : super(const AsyncValue.loading()) {
    _loadTheme();
  }
  Future<void> _loadTheme() async {
    try {
      final themeMode = await _preferencesDataSource.getThemeMode();
      state = AsyncValue.data(themeMode);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar tema: $error');
      }
      state = AsyncValue.error(error, stackTrace);
      state = const AsyncValue.data(AppThemeMode.system);
    }
  }
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      state = AsyncValue.data(themeMode);
      await _preferencesDataSource.setThemeMode(themeMode);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar tema: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }
  Future<void> toggleTheme() async {
    final currentTheme = state.value ?? AppThemeMode.system;

    AppThemeMode newTheme;
    switch (currentTheme) {
      case AppThemeMode.light:
        newTheme = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        newTheme = AppThemeMode.light;
        break;
      case AppThemeMode.system:
        newTheme =
            AppThemeMode.light; // Default para claro quando vem do sistema
        break;
    }

    await setThemeMode(newTheme);
  }
  Future<void> resetToSystem() async {
    await setThemeMode(AppThemeMode.system);
  }
  bool get isSystemMode {
    return (state.value ?? AppThemeMode.system) == AppThemeMode.system;
  }
  AppThemeMode get currentTheme {
    return state.value ?? AppThemeMode.system;
  }
}
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AsyncValue<AppThemeMode>>((ref) {
      final dataSource = ref.watch(preferencesDataSourceProvider);
      return ThemeNotifier(dataSource);
    });
final currentThemeProvider = Provider<AppThemeMode>((ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.value ?? AppThemeMode.system;
});
final themeLoadingProvider = Provider<bool>((ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.isLoading;
});
final themeErrorProvider = Provider<String?>((ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.hasError ? asyncTheme.error.toString() : null;
});
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(currentThemeProvider);
  return appThemeMode.themeMode;
});
