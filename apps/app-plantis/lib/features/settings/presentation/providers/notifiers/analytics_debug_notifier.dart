import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/settings_entity.dart';
import '../settings_notifier.dart';

part 'analytics_debug_notifier.g.dart';

/// AnalyticsDebugNotifier - Handles ANALYTICS, DEBUG, TESTING operations (SRP)
///
/// Responsibilities:
/// - Analytics preferences
/// - Debug mode settings
/// - Crash reporting
/// - Data backup/restore
/// - Testing utilities
/// - Device management
///
/// Does NOT handle:
/// - Theme settings (see ThemeNotifier)
/// - Notifications (see NotificationsNotifier)
@riverpod
class AnalyticsDebugNotifier extends _$AnalyticsDebugNotifier {
  @override
  SettingsState build() {
    return SettingsState.initial();
  }

  /// Updates backup settings
  Future<void> updateBackupSettings(BackupSettingsEntity newSettings) async {
    try {
      final currentSettings = state.settings;
      final updatedSettings =
          currentSettings.copyWith(backup: newSettings);

      state = state.copyWith(
        settings: updatedSettings,
        successMessage: 'Configurações de backup atualizadas',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar configurações de backup: $e',
      );
    }
  }

  /// Updates account settings
  Future<void> updateAccountSettings(AccountSettingsEntity newSettings) async {
    try {
      final currentSettings = state.settings;
      final updatedSettings =
          currentSettings.copyWith(account: newSettings);

      state = state.copyWith(
        settings: updatedSettings,
        successMessage: 'Configurações de conta atualizadas',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar configurações de conta: $e',
      );
    }
  }

  /// Updates app settings
  Future<void> updateAppSettings(AppSettingsEntity newSettings) async {
    try {
      final currentSettings = state.settings;
      final updatedSettings = currentSettings.copyWith(app: newSettings);

      state = state.copyWith(
        settings: updatedSettings,
        successMessage: 'Configurações do app atualizadas',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao atualizar configurações do app: $e',
      );
    }
  }

  /// Creates configuration backup
  Future<void> createConfigurationBackup() async {
    try {
      state = state.copyWith(isLoading: true);

      // Backup logic would go here
      // For now, just update state
      final backupSettings = state.backupSettings.copyWith(
        lastBackupTime: DateTime.now(),
      );
      await updateBackupSettings(backupSettings);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Backup de configuração criado com sucesso',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao criar backup: $e',
      );
    }
  }

  /// Resets all settings to defaults
  Future<void> resetAllSettings() async {
    try {
      state = state.copyWith(isLoading: true);

      final defaultSettings = SettingsEntity.defaults();

      state = state.copyWith(
        settings: defaultSettings,
        isLoading: false,
        successMessage: 'Todas as configurações foram resetadas',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao resetar configurações: $e',
      );
    }
  }

  /// Refreshes settings
  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true);
      // Refresh logic would go here
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar configurações: $e',
      );
    }
  }

  /// Clears messages
  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearSuccess: true,
    );
  }

  /// Revokes device access
  Future<void> revokeDevice(String deviceUuid) async {
    try {
      state = state.copyWith(isLoading: true);
      // Revoke logic would go here
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Dispositivo revogado',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao revogar dispositivo: $e',
      );
    }
  }

  /// Revokes all other devices
  Future<void> revokeAllOtherDevices() async {
    try {
      state = state.copyWith(isLoading: true);
      // Revoke logic would go here
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Todos os outros dispositivos foram revogados',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao revogar dispositivos: $e',
      );
    }
  }

  /// Refreshes device information
  Future<void> refreshDevices() async {
    try {
      state = state.copyWith(isLoading: true);
      // Refresh logic would go here
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar dispositivos: $e',
      );
    }
  }

  /// Gets device count
  int getDeviceCount() {
    return state.deviceCount;
  }

  /// Gets active device count
  int getActiveDeviceCount() {
    return state.activeDeviceCount;
  }

  /// Checks if has devices
  bool hasDevices() {
    return state.hasDevices;
  }
}
