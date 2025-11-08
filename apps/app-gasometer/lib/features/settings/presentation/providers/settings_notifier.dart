import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/error/app_error.dart' as local_error;
import '../../../../core/providers/dependency_providers.dart';

/// State para Settings
@immutable
class SettingsState {

  const SettingsState({
    this.globalErrorBoundaryEnabled = true,
    this.notificationsEnabled = true,
    this.themeMode = ThemeMode.system,
  });
  final bool globalErrorBoundaryEnabled;
  final bool notificationsEnabled;
  final ThemeMode themeMode;

  SettingsState copyWith({
    bool? globalErrorBoundaryEnabled,
    bool? notificationsEnabled,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      globalErrorBoundaryEnabled:
          globalErrorBoundaryEnabled ?? this.globalErrorBoundaryEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          globalErrorBoundaryEnabled == other.globalErrorBoundaryEnabled &&
          notificationsEnabled == other.notificationsEnabled &&
          themeMode == other.themeMode;

  @override
  int get hashCode =>
      globalErrorBoundaryEnabled.hashCode ^
      notificationsEnabled.hashCode ^
      themeMode.hashCode;

  @override
  String toString() =>
      'SettingsState(globalErrorBoundaryEnabled: $globalErrorBoundaryEnabled, '
      'notificationsEnabled: $notificationsEnabled, '
      'themeMode: $themeMode)';
}

/// Settings Notifier seguindo SOLID principles
///
/// Segue SRP: Responsabilidade única de gerenciar settings state
/// Segue DIP: Depende de abstrações (SharedPreferences interface)
/// Segue OCP: Aberto para extensão via novos settings
class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late final SharedPreferences _preferences;
  late final IAppRatingRepository _appRatingRepository;

  @override
  Future<SettingsState> build() async {
    _preferences = ref.read(gasometerSharedPreferencesProvider);
    _appRatingRepository = ref.read(appRatingRepositoryProvider);
    return await _loadSettings();
  }

  /// Carrega settings do persistent storage
  Future<SettingsState> _loadSettings() async {
    try {
      final globalErrorBoundaryEnabled =
          _preferences.getBool('global_error_boundary_enabled') ?? true;
      final notificationsEnabled =
          _preferences.getBool('notifications_enabled') ?? true;
      final themeIndex =
          _preferences.getInt('theme_mode') ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];

      return SettingsState(
        globalErrorBoundaryEnabled: globalErrorBoundaryEnabled,
        notificationsEnabled: notificationsEnabled,
        themeMode: themeMode,
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading settings: $e');
      _logError(
        local_error.StorageError(
          message: 'Erro ao carregar configurações',
          technicalDetails: e.toString(),
        ),
        stackTrace: stackTrace,
      );
      return const SettingsState();
    }
  }

  /// Toggle error boundary setting
  Future<void> toggleErrorBoundary(bool enabled) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (currentState.globalErrorBoundaryEnabled == enabled) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _preferences.setBool('global_error_boundary_enabled', enabled);

      return currentState.copyWith(
        globalErrorBoundaryEnabled: enabled,
      );
    });
  }

  /// Toggle notifications setting
  Future<void> toggleNotifications(bool enabled) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (currentState.notificationsEnabled == enabled) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _preferences.setBool('notifications_enabled', enabled);

      return currentState.copyWith(
        notificationsEnabled: enabled,
      );
    });
  }

  /// Change theme mode (synchronous to avoid dialog rebuild issues)
  void changeTheme(ThemeMode newTheme) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (currentState.themeMode == newTheme) return;

    // Update state immediately without AsyncValue.loading()
    // This prevents dialog from being destroyed during theme change
    state = AsyncValue.data(
      currentState.copyWith(
        themeMode: newTheme,
      ),
    );

    // Save to preferences in background without blocking UI
    unawaited(
      _preferences.setInt('theme_mode', newTheme.index).catchError((Object e) {
        debugPrint('Error saving theme preference: $e');
        return false;
      }),
    );
  }

  /// Handle app rating with business logic
  Future<bool> handleAppRating(BuildContext context) async {
    try {
      return await _appRatingRepository.showRatingDialog(context: context);
    } catch (e) {
      debugPrint('Error showing app rating: $e');
      return false;
    }
  }

  /// Check if app rating can be shown
  Future<bool> canShowRating() async {
    try {
      return await _appRatingRepository.canShowRatingDialog();
    } catch (e) {
      debugPrint('Error checking rating availability: $e');
      return false;
    }
  }

  /// Recarrega settings do storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadSettings);
  }

  /// Log error helper
  void _logError(local_error.AppError error, {StackTrace? stackTrace}) {
    debugPrint('SettingsNotifier error: ${error.message}');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}

/// Provider para SettingsNotifier
/// Gerencia configurações do app de forma reativa
final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

/// Provider para acessar o themeMode diretamente
/// Útil para MaterialApp
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.valueOrNull?.themeMode ?? ThemeMode.system;
});

/// Provider para acessar notificações enabled
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.valueOrNull?.notificationsEnabled ?? true;
});

/// Provider para acessar error boundary enabled
final errorBoundaryEnabledProvider = Provider<bool>((ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);
  return settingsAsync.valueOrNull?.globalErrorBoundaryEnabled ?? true;
});
