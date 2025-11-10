import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/domain/entities/settings_entity.dart';

part 'theme_providers.freezed.dart';
part 'theme_providers.g.dart';

/// State class for theme with freezed immutability
@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState({
    required ThemeSettingsEntity settings,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ThemeState;

  const ThemeState._();

  /// Configuração inicial padrão
  factory ThemeState.initial() {
    return ThemeState(settings: ThemeSettingsEntity.defaults());
  }
}

/// Riverpod notifier for theme management using SharedPreferences
@riverpod
class Theme extends _$Theme {
  static const String _themeKey = 'theme_mode_plantis';
  static const String _followSystemKey = 'follow_system_theme_plantis';

  @override
  ThemeState build() {
    // Carrega o tema de forma assíncrona após inicialização
    _initializeTheme();
    return ThemeState.initial();
  }

  /// Inicializa o tema de forma segura durante build
  void _initializeTheme() {
    // Agenda o carregamento para após o build estar completo
    Future.microtask(() async {
      await _loadTheme();
    });
  }

  /// Carrega o tema das preferências
  Future<void> _loadTheme() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      ThemeMode themeMode = ThemeMode.system;

      if (savedTheme != null) {
        themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
      final followSystemTheme = prefs.getBool(_followSystemKey) ?? true;

      final newSettings = ThemeSettingsEntity(
        themeMode: themeMode,
        followSystemTheme: followSystemTheme,
      );

      state = state.copyWith(settings: newSettings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar tema: $e',
      );
    }
  }

  /// Altera o modo do tema com persistência automática
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state.settings.themeMode == themeMode) return;

    try {
      final newSettings = state.settings.copyWith(
        themeMode: themeMode,
        followSystemTheme: themeMode == ThemeMode.system,
      );
      state = state.copyWith(settings: newSettings, errorMessage: null);
      final prefs = await SharedPreferences.getInstance();
      await Future.wait<void>([
        prefs.setString(_themeKey, themeMode.toString()),
        prefs.setBool(_followSystemKey, newSettings.followSystemTheme),
      ]);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao salvar tema: $e');
    }
  }

  /// Alterna entre claro e escuro (ignora system)
  Future<void> toggleTheme() async {
    final currentMode = state.settings.themeMode;

    ThemeMode newMode;
    switch (currentMode) {
      case ThemeMode.dark:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light; // Default para claro quando vem do sistema
        break;
    }

    await setThemeMode(newMode);
  }

  /// Define tema claro
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Define tema escuro
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Define tema automático (sistema)
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Atualiza configuração de seguir sistema
  Future<void> setFollowSystemTheme(bool followSystem) async {
    try {
      final newSettings = state.settings.copyWith(
        followSystemTheme: followSystem,
        themeMode: followSystem ? ThemeMode.system : state.settings.themeMode,
      );

      state = state.copyWith(settings: newSettings, errorMessage: null);
      final prefs = await SharedPreferences.getInstance();
      await Future.wait<void>([
        prefs.setBool(_followSystemKey, followSystem),
        if (followSystem)
          prefs.setString(_themeKey, ThemeMode.system.toString()),
      ]);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar configuração: $e',
      );
    }
  }

  /// Limpa erro
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Recarrega configurações
  Future<void> refresh() async {
    await _loadTheme();
  }
}

// =============================================================================
// DERIVED PROVIDERS
// =============================================================================

/// Provider para o ThemeSettingsEntity atual
@riverpod
ThemeSettingsEntity themeSettings(ThemeSettingsRef ref) {
  return ref.watch(themeProvider).settings;
}

/// Provider para o ThemeMode do Flutter
@riverpod
ThemeMode themeMode(ThemeModeRef ref) {
  return ref.watch(themeSettingsProvider).themeMode;
}

/// Provider para verificar se está carregando
@riverpod
bool themeLoading(ThemeLoadingRef ref) {
  return ref.watch(themeProvider).isLoading;
}

/// Provider para mensagem de erro
@riverpod
String? themeError(ThemeErrorRef ref) {
  return ref.watch(themeProvider).errorMessage;
}

/// Provider para verificar se é modo escuro (Plantis específico)
@riverpod
bool plantisIsDarkMode(PlantisIsDarkModeRef ref) {
  return ref.watch(themeSettingsProvider).isDarkMode;
}

/// Provider para verificar se é modo claro (Plantis específico)
@riverpod
bool plantisIsLightMode(PlantisIsLightModeRef ref) {
  return ref.watch(themeSettingsProvider).isLightMode;
}

/// Provider para verificar se segue o sistema (Plantis específico)
@riverpod
bool plantisFollowSystemTheme(PlantisFollowSystemThemeRef ref) {
  return ref.watch(themeSettingsProvider).followSystemTheme;
}

/// Provider auxiliar para verificar se está no modo escuro considerando o contexto
@riverpod
bool contextAwareDarkMode(ContextAwareDarkModeRef ref, BuildContext context) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.themeMode == ThemeMode.system) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  return themeSettings.isDarkMode;
}

/// Provider para o texto de status do tema
@riverpod
String themeStatusText(ThemeStatusTextRef ref) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.isDarkMode) {
    return 'Tema escuro ativo';
  } else if (themeSettings.isLightMode) {
    return 'Tema claro ativo';
  } else {
    return 'Seguir sistema';
  }
}

/// Provider para ícone do tema atual
@riverpod
IconData themeIcon(ThemeIconRef ref) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.isDarkMode) {
    return Icons.dark_mode;
  } else if (themeSettings.isLightMode) {
    return Icons.light_mode;
  } else {
    return Icons.settings_brightness;
  }
}
