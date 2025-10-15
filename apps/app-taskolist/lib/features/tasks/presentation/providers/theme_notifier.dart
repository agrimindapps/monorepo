import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/preferences_local_datasource.dart';
import '../../../../core/services/preferences_local_datasource_impl.dart';
import '../../../../core/theme/theme_mode_enum.dart';

part 'theme_notifier.g.dart';

@riverpod
PreferencesLocalDataSource preferencesDataSource(PreferencesDataSourceRef ref) {
  return PreferencesLocalDataSourceImpl();
}

class ThemeState {
  final AppThemeMode themeMode;
  final bool isLoading;

  const ThemeState({required this.themeMode, this.isLoading = false});

  ThemeState copyWith({AppThemeMode? themeMode, bool? isLoading}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  PreferencesLocalDataSource get _dataSource =>
      ref.read(preferencesDataSourceProvider);

  @override
  Future<ThemeState> build() async {
    try {
      final themeMode = await _dataSource.getThemeMode();
      return ThemeState(themeMode: themeMode);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error loading theme: $error');
      }
      return const ThemeState(themeMode: AppThemeMode.system);
    }
  }

  /// Define novo tema
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _dataSource.setThemeMode(themeMode);
      return ThemeState(themeMode: themeMode);
    });
  }

  /// Alternar entre claro e escuro (útil para quick toggle)
  Future<void> toggleTheme() async {
    final currentTheme = state.value?.themeMode ?? AppThemeMode.system;

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

  /// Resetar para tema do sistema
  Future<void> resetToSystem() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// Verificar se está usando tema do sistema
  bool get isSystemMode {
    return (state.value?.themeMode ?? AppThemeMode.system) ==
        AppThemeMode.system;
  }

  /// Obter tema atual ou fallback
  AppThemeMode get currentTheme {
    return state.value?.themeMode ?? AppThemeMode.system;
  }
}

/// Provider derivado para obter apenas o valor do tema (sem AsyncValue)
@riverpod
AppThemeMode currentTheme(CurrentThemeRef ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.value?.themeMode ?? AppThemeMode.system;
}

/// Provider derivado para verificar se está carregando
@riverpod
bool themeLoading(ThemeLoadingRef ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.isLoading;
}

/// Provider derivado para verificar se houve erro
@riverpod
String? themeError(ThemeErrorRef ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.hasError ? asyncTheme.error.toString() : null;
}

/// Provider conveniente para obter o ThemeMode do Flutter
@riverpod
ThemeMode flutterThemeMode(FlutterThemeModeRef ref) {
  final appThemeMode = ref.watch(currentThemeProvider);
  return appThemeMode.themeMode;
}
