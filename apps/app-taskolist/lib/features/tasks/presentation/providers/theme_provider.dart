import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../../core/theme/theme_mode_enum.dart';
import '../../../../core/services/preferences_local_datasource.dart';
import '../../../../core/services/preferences_local_datasource_impl.dart';

// Provider para o data source de preferências
final preferencesDataSourceProvider = Provider<PreferencesLocalDataSource>((ref) {
  return PreferencesLocalDataSourceImpl();
});

// State notifier para gerenciar o tema
class ThemeNotifier extends StateNotifier<AsyncValue<AppThemeMode>> {
  final PreferencesLocalDataSource _preferencesDataSource;

  ThemeNotifier(this._preferencesDataSource) : super(const AsyncValue.loading()) {
    _loadTheme();
  }

  // Carregar tema salvo
  Future<void> _loadTheme() async {
    try {
      final themeMode = await _preferencesDataSource.getThemeMode();
      state = AsyncValue.data(themeMode);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Erro ao carregar tema: $error');
      }
      state = AsyncValue.error(error, stackTrace);
      // Fallback para tema do sistema em caso de erro
      state = const AsyncValue.data(AppThemeMode.system);
    }
  }

  // Definir novo tema
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      // Atualizar estado imediatamente para UI responsiva
      state = AsyncValue.data(themeMode);
      
      // Persistir a mudança
      await _preferencesDataSource.setThemeMode(themeMode);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Erro ao salvar tema: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Alternar entre claro e escuro (útil para quick toggle)
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
        newTheme = AppThemeMode.light; // Default para claro quando vem do sistema
        break;
    }
    
    await setThemeMode(newTheme);
  }

  // Resetar para tema do sistema
  Future<void> resetToSystem() async {
    await setThemeMode(AppThemeMode.system);
  }

  // Verificar se está usando tema do sistema
  bool get isSystemMode {
    return (state.value ?? AppThemeMode.system) == AppThemeMode.system;
  }

  // Obter tema atual ou fallback
  AppThemeMode get currentTheme {
    return state.value ?? AppThemeMode.system;
  }
}

// Provider para o theme notifier
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AsyncValue<AppThemeMode>>((ref) {
  final dataSource = ref.watch(preferencesDataSourceProvider);
  return ThemeNotifier(dataSource);
});

// Provider derivado para obter apenas o valor do tema (sem AsyncValue)
final currentThemeProvider = Provider<AppThemeMode>((ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.value ?? AppThemeMode.system;
});

// Provider derivado para verificar se está carregando
final themeLoadingProvider = Provider<bool>((ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.isLoading;
});

// Provider derivado para verificar se houve erro
final themeErrorProvider = Provider<String?>((ref) {
  final asyncTheme = ref.watch(themeNotifierProvider);
  return asyncTheme.hasError ? asyncTheme.error.toString() : null;
});

// Provider conveniente para obter o ThemeMode do Flutter  
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(currentThemeProvider);
  return appThemeMode.themeMode;
});

