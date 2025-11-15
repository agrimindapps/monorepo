import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/preferences_local_datasource.dart';
import '../../../../core/services/preferences_local_datasource_impl.dart';
import '../../../../core/theme/theme_mode_enum.dart';

part 'theme_provider.g.dart';

/// Provider para PreferencesLocalDataSource
@riverpod
PreferencesLocalDataSource preferencesDataSource(Ref ref) {
  return PreferencesLocalDataSourceImpl();
}

/// AsyncNotifier para gerenciar tema do app
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final PreferencesLocalDataSource _preferencesDataSource;

  @override
  Future<AppThemeMode> build() async {
    _preferencesDataSource = ref.watch(preferencesDataSourceProvider);

    try {
      final themeMode = await _preferencesDataSource.getThemeMode();
      return themeMode;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar tema: $error');
      }
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _preferencesDataSource.setThemeMode(themeMode);
      return themeMode;
    });
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
        newTheme = AppThemeMode.light;
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

/// Provider para tema atual
@riverpod
AppThemeMode currentTheme(Ref ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.value ?? AppThemeMode.system;
}

/// Provider para estado de loading do tema
@riverpod
bool themeLoading(Ref ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.isLoading;
}

/// Provider para erro do tema
@riverpod
String? themeError(Ref ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.hasError ? asyncTheme.error.toString() : null;
}

/// Provider para ThemeMode do Flutter
@riverpod
ThemeMode flutterThemeMode(Ref ref) {
  final appThemeMode = ref.watch(currentThemeProvider);
  return appThemeMode.themeMode;
}
