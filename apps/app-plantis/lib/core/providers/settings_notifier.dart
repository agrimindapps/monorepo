import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/plantis_notification_service.dart';
import '../../features/settings/domain/entities/settings_entity.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import 'settings_state.dart';

part 'settings_notifier.g.dart';

/// Provider do repositório de configurações (obtido via DI)
@riverpod
ISettingsRepository settingsRepository(Ref ref) {
  return ref.watch(settingsRepositoryProvider);
}

/// Provider do serviço de notificações
@riverpod
PlantisNotificationService plantisNotificationService(
  Ref ref,
) {
  return PlantisNotificationService();
}

/// Notifier principal para gerenciar configurações com @riverpod
@riverpod
class Settings extends _$Settings {
  late final ISettingsRepository _repository;
  late final PlantisNotificationService _notificationService;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _notificationService = ref.watch(plantisNotificationServiceProvider);

    // Inicializa automaticamente
    _initialize();

    return SettingsStateX.initial();
  }

  /// Inicializa o notifier carregando configurações
  Future<void> _initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true).clearMessages();

    try {
      await _loadSettings();
      await _syncWithServices();
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.withError('Erro ao inicializar configurações: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Carrega configurações do repositório
  Future<void> _loadSettings() async {
    final result = await _repository.loadSettings();

    result.fold(
      (Failure failure) => throw Exception(failure.message),
      (SettingsEntity settings) {
        state = state.copyWith(settings: settings);
      },
    );
  }

  /// Sincroniza com services externos
  Future<void> _syncWithServices() async {
    try {
      final hasPermissions =
          await _notificationService.areNotificationsEnabled();

      if (state.settings.notifications.permissionsGranted != hasPermissions) {
        await updateNotificationSettings(
          state.settings.notifications.copyWith(
            permissionsGranted: hasPermissions,
          ),
        );
      }
      await _syncAccountSettings();
    } catch (e) {
      debugPrint('Erro ao sincronizar com services: $e');
    }
  }

  /// Sincroniza configurações da conta
  Future<void> _syncAccountSettings() async {
    try {
      final accountSettings = AccountSettingsEntity.defaults();

      if (state.settings.account != accountSettings) {
        await updateAccountSettings(accountSettings);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar conta: $e');
    }
  }

  /// Atualiza configurações completas
  Future<void> updateSettings(SettingsEntity newSettings) async {
    state = state.copyWith(isLoading: true).clearMessages();

    try {
      final result = await _repository.saveSettings(newSettings);

      result.fold(
        (Failure failure) => throw Exception(failure.message),
        (void _) {
          state = state
              .copyWith(settings: newSettings, isLoading: false)
              .withSuccess('Configurações salvas com sucesso');
          _applyCascadeEffects(newSettings);
        },
      );
    } catch (e) {
      state = state
          .copyWith(isLoading: false)
          .withError('Erro ao salvar configurações: $e');
    }
  }

  /// Atualiza configurações específicas de notificações
  Future<void> updateNotificationSettings(
    NotificationSettingsEntity newSettings,
  ) async {
    final updatedSettings = state.settings.copyWith(notifications: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de backup
  Future<void> updateBackupSettings(BackupSettingsEntity newSettings) async {
    final updatedSettings = state.settings.copyWith(backup: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de tema
  Future<void> updateThemeSettings(ThemeSettingsEntity newSettings) async {
    final updatedSettings = state.settings.copyWith(theme: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de conta
  Future<void> updateAccountSettings(AccountSettingsEntity newSettings) async {
    final updatedSettings = state.settings.copyWith(account: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas do app
  Future<void> updateAppSettings(AppSettingsEntity newSettings) async {
    final updatedSettings = state.settings.copyWith(app: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Toggle para lembretes de tarefas
  Future<void> toggleTaskReminders(bool enabled) async {
    final newSettings = state.settings.notifications.copyWith(
      taskRemindersEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para notificações de atraso
  Future<void> toggleOverdueNotifications(bool enabled) async {
    final newSettings = state.settings.notifications.copyWith(
      overdueNotificationsEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para resumo diário
  Future<void> toggleDailySummary(bool enabled) async {
    final newSettings = state.settings.notifications.copyWith(
      dailySummaryEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define minutos de antecedência para lembretes
  Future<void> setReminderMinutesBefore(int minutes) async {
    final newSettings = state.settings.notifications.copyWith(
      reminderMinutesBefore: minutes,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define horário do resumo diário
  Future<void> setDailySummaryTime(TimeOfDay time) async {
    final newSettings = state.settings.notifications.copyWith(
      dailySummaryTime: time,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para tipo específico de tarefa
  Future<void> toggleTaskType(String taskType, bool enabled) async {
    final updatedTaskTypes = Map<String, bool>.from(
      state.settings.notifications.taskTypeSettings,
    );
    updatedTaskTypes[taskType] = enabled;

    final newSettings = state.settings.notifications.copyWith(
      taskTypeSettings: updatedTaskTypes,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define modo de tema
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final newSettings = state.settings.theme.copyWith(
      themeMode: themeMode,
      followSystemTheme: themeMode == ThemeMode.system,
    );
    await updateThemeSettings(newSettings);
  }

  /// Define tema escuro
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Define tema claro
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Define tema automático (sistema)
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Abre configurações do sistema para notificações
  Future<void> openNotificationSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      state = state.withError('Erro ao abrir configurações: $e');
    }
  }

  /// Envia notificação de teste
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.showTaskReminderNotification(
        taskName: 'Teste de Notificação',
        plantName: 'Planta de Teste',
        taskType: 'test',
      );
      state = state.withSuccess('Notificação de teste enviada!');
    } catch (e) {
      state = state.withError('Erro ao enviar notificação: $e');
    }
  }

  /// Limpa todas as notificações
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      state = state.withSuccess('Todas as notificações foram canceladas');
    } catch (e) {
      state = state.withError('Erro ao limpar notificações: $e');
    }
  }

  /// Verifica se deve mostrar notificação
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    return state.settings.notifications.shouldShowNotification(
      notificationType,
      taskType: taskType,
    );
  }

  /// Verifica se tipo de tarefa está habilitado
  bool isTaskTypeEnabled(String taskType) {
    return state.settings.notifications.isTaskTypeEnabled(taskType);
  }

  /// Cria backup manual das configurações
  Future<void> createConfigurationBackup() async {
    try {
      final exportResult = await _repository.exportSettings();

      exportResult.fold(
        (Failure failure) => throw Exception(failure.message),
        (Map<String, dynamic> data) {
          state = state.withSuccess('Configurações incluídas no próximo backup');
        },
      );
    } catch (e) {
      state = state.withError('Erro ao preparar backup: $e');
    }
  }

  /// Reseta todas as configurações
  Future<void> resetAllSettings() async {
    state = state.copyWith(isLoading: true).clearMessages();

    try {
      final result = await _repository.resetToDefaults();

      result.fold(
        (Failure failure) => throw Exception(failure.message),
        (void _) async {
          final newSettings = SettingsEntity.defaults();
          state = state
              .copyWith(settings: newSettings, isLoading: false)
              .withSuccess('Configurações resetadas com sucesso');
          _syncWithServices();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false).withError('Erro inesperado: $e');
    }
  }

  /// Recarrega configurações
  Future<void> refresh() async {
    await _loadSettings();
    await _syncWithServices();
  }

  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    if (state.errorMessage != null || state.successMessage != null) {
      state = state.clearMessages();
    }
  }

  /// Aplica efeitos cascata quando configurações mudam
  void _applyCascadeEffects(SettingsEntity newSettings) {
    // Implementar efeitos cascata se necessário
  }
}

// ============================================================================
// DERIVED STATE PROVIDERS (Computed values)
// ============================================================================

/// Provider para SettingsEntity atual
@riverpod
SettingsEntity currentSettings(Ref ref) {
  return ref.watch(settingsProvider).settings;
}

/// Provider para estado de carregamento
@riverpod
bool settingsLoading(Ref ref) {
  return ref.watch(settingsProvider).isLoading;
}

/// Provider para verificar se está inicializado
@riverpod
bool settingsInitialized(Ref ref) {
  return ref.watch(settingsProvider).isInitialized;
}

/// Provider para mensagem de erro
@riverpod
String? settingsError(Ref ref) {
  return ref.watch(settingsProvider).errorMessage;
}

/// Provider para mensagem de sucesso
@riverpod
String? settingsSuccess(Ref ref) {
  return ref.watch(settingsProvider).successMessage;
}

/// Provider para configurações de notificação
@riverpod
NotificationSettingsEntity notificationSettings(Ref ref) {
  return ref.watch(currentSettingsProvider).notifications;
}

/// Provider para configurações de backup
@riverpod
BackupSettingsEntity backupSettings(Ref ref) {
  return ref.watch(currentSettingsProvider).backup;
}

/// Provider para configurações de tema
@riverpod
ThemeSettingsEntity themeSettings(Ref ref) {
  return ref.watch(currentSettingsProvider).theme;
}

/// Provider para configurações de conta
@riverpod
AccountSettingsEntity accountSettings(Ref ref) {
  return ref.watch(currentSettingsProvider).account;
}

/// Provider para configurações do app
@riverpod
AppSettingsEntity appSettings(Ref ref) {
  return ref.watch(currentSettingsProvider).app;
}

/// Provider para verificar se tem permissões de notificação
@riverpod
bool hasNotificationPermissions(Ref ref) {
  return ref.watch(notificationSettingsProvider).permissionsGranted;
}

/// Provider para verificar se está em modo escuro
@riverpod
bool isDarkMode(Ref ref) {
  return ref.watch(themeSettingsProvider).isDarkMode;
}

/// Provider para verificar se notificações estão habilitadas
@riverpod
bool notificationsEnabled(Ref ref) {
  return ref.watch(notificationSettingsProvider).taskRemindersEnabled;
}

/// Provider para verificar se é plataforma web
@riverpod
bool isWebPlatform(Ref ref) {
  return kIsWeb;
}

/// Provider para texto de status das notificações
@riverpod
String notificationStatusText(Ref ref) {
  final isWeb = ref.watch(isWebPlatformProvider);
  final hasPermissions = ref.watch(hasNotificationPermissionsProvider);

  if (isWeb) {
    return 'Notificações não disponíveis na versão web';
  }
  if (!hasPermissions) {
    return 'Notificações desabilitadas. Habilite nas configurações do dispositivo.';
  }
  return 'Notificações habilitadas para este aplicativo';
}

/// Provider para cor de status das notificações
@riverpod
Color notificationStatusColor(Ref ref) {
  final isWeb = ref.watch(isWebPlatformProvider);
  final hasPermissions = ref.watch(hasNotificationPermissionsProvider);

  if (isWeb) {
    return Colors.grey;
  }
  return hasPermissions ? Colors.green : Colors.red;
}

/// Provider para ícone de status das notificações
@riverpod
IconData notificationStatusIcon(Ref ref) {
  final isWeb = ref.watch(isWebPlatformProvider);
  final hasPermissions = ref.watch(hasNotificationPermissionsProvider);

  if (isWeb) {
    return Icons.web;
  }
  return hasPermissions ? Icons.notifications_active : Icons.notifications_off;
}

/// Provider para subtitle do tema
@riverpod
String themeSubtitle(Ref ref) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.isDarkMode) {
    return 'Tema escuro ativo';
  } else if (themeSettings.isLightMode) {
    return 'Tema claro ativo';
  } else {
    return 'Seguir sistema';
  }
}

// LEGACY ALIAS
// ignore: deprecated_member_use_from_same_package
const settingsNotifierProvider = settingsProvider;
