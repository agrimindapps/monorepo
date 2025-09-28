import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/settings_entity.dart';

/// Estado do tema para Riverpod StateNotifier
/// Usa ThemeSettingsEntity existente como base do estado
@immutable
class ThemeState {
  final ThemeSettingsEntity settings;
  final bool isLoading;
  final String? errorMessage;

  const ThemeState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Configuração inicial padrão
  factory ThemeState.initial() {
    return ThemeState(settings: ThemeSettingsEntity.defaults());
  }

  /// Cria uma cópia com alterações
  ThemeState copyWith({
    ThemeSettingsEntity? settings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ThemeState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Remove erro
  ThemeState clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeState &&
        other.settings == settings &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      settings.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;

  @override
  String toString() =>
      'ThemeState(settings: $settings, isLoading: $isLoading, errorMessage: $errorMessage)';
}

/// StateNotifier para gerenciar o tema usando SharedPreferences
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode_plantis';
  static const String _followSystemKey = 'follow_system_theme_plantis';

  ThemeNotifier() : super(ThemeState.initial()) {
    _loadTheme();
  }

  /// Carrega o tema das preferências
  Future<void> _loadTheme() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Carregar themeMode
      final savedTheme = prefs.getString(_themeKey);
      ThemeMode themeMode = ThemeMode.system;

      if (savedTheme != null) {
        themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }

      // Carregar followSystemTheme
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

      // Atualiza o estado imediatamente para UI responsiva
      state = state.copyWith(settings: newSettings, errorMessage: null);

      // Persiste as configurações
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

      // Persiste as configurações
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
      state = state.clearError();
    }
  }

  /// Recarrega configurações
  Future<void> refresh() async {
    await _loadTheme();
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider principal do ThemeNotifier
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((
  ref,
) {
  return ThemeNotifier();
});

/// Provider para o ThemeSettingsEntity atual
final themeSettingsProvider = Provider<ThemeSettingsEntity>((ref) {
  return ref.watch(themeNotifierProvider).settings;
});

/// Provider para o ThemeMode do Flutter
final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeSettingsProvider).themeMode;
});

/// Provider para verificar se está carregando
final themeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(themeNotifierProvider).isLoading;
});

/// Provider para mensagem de erro
final themeErrorProvider = Provider<String?>((ref) {
  return ref.watch(themeNotifierProvider).errorMessage;
});

/// Provider para verificar se é modo escuro (Plantis específico)
final plantisIsDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeSettingsProvider).isDarkMode;
});

/// Provider para verificar se é modo claro (Plantis específico)
final plantisIsLightModeProvider = Provider<bool>((ref) {
  return ref.watch(themeSettingsProvider).isLightMode;
});

/// Provider para verificar se segue o sistema (Plantis específico)
final plantisFollowSystemThemeProvider = Provider<bool>((ref) {
  return ref.watch(themeSettingsProvider).followSystemTheme;
});

/// Provider auxiliar para verificar se está no modo escuro considerando o contexto
final contextAwareDarkModeProvider = Provider.family<bool, BuildContext>((
  ref,
  context,
) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.themeMode == ThemeMode.system) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  return themeSettings.isDarkMode;
});

// =============================================================================
// CONVENIENCE PROVIDERS
// =============================================================================

/// Provider para o texto de status do tema
final themeStatusTextProvider = Provider<String>((ref) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.isDarkMode) {
    return 'Tema escuro ativo';
  } else if (themeSettings.isLightMode) {
    return 'Tema claro ativo';
  } else {
    return 'Seguir sistema';
  }
});

/// Provider para ícone do tema atual
final themeIconProvider = Provider<IconData>((ref) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.isDarkMode) {
    return Icons.dark_mode;
  } else if (themeSettings.isLightMode) {
    return Icons.light_mode;
  } else {
    return Icons.settings_brightness;
  }
});
