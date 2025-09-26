import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/backup_service.dart';
import '../../core/services/plantis_notification_service.dart';
import '../../features/settings/domain/entities/settings_entity.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';

/// Estado das configurações para Riverpod StateNotifier
@immutable
class SettingsState {
  final SettingsEntity settings;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Estado inicial padrão
  factory SettingsState.initial() {
    return SettingsState(
      settings: SettingsEntity.defaults(),
    );
  }

  /// Cria uma cópia com alterações
  SettingsState copyWith({
    SettingsEntity? settings,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Remove mensagens
  SettingsState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  /// Define estado de erro
  SettingsState withError(String error) {
    return copyWith(errorMessage: error, successMessage: null);
  }

  /// Define estado de sucesso
  SettingsState withSuccess(String success) {
    return copyWith(successMessage: success, errorMessage: null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsState &&
        other.settings == settings &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage;
  }

  @override
  int get hashCode {
    return settings.hashCode ^
        isLoading.hashCode ^
        isInitialized.hashCode ^
        errorMessage.hashCode ^
        successMessage.hashCode;
  }
}

/// StateNotifier para gerenciar todas as configurações do app
class SettingsNotifier extends StateNotifier<SettingsState> {
  final ISettingsRepository _settingsRepository;
  final PlantisNotificationService _notificationService;
  final BackupService? _backupService;

  SettingsNotifier({
    required ISettingsRepository settingsRepository,
    required PlantisNotificationService notificationService,
    BackupService? backupService,
  })  : _settingsRepository = settingsRepository,
        _notificationService = notificationService,
        _backupService = backupService,
        super(SettingsState.initial());

  /// Inicializa o notifier carregando configurações
  Future<void> initialize() async {
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
    final result = await _settingsRepository.loadSettings();

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
      // Sincronizar permissões de notificação
      final hasPermissions = await _notificationService.areNotificationsEnabled();

      if (state.settings.notifications.permissionsGranted != hasPermissions) {
        await updateNotificationSettings(
          state.settings.notifications.copyWith(permissionsGranted: hasPermissions),
        );
      }

      // Sincronizar dados da conta
      await _syncAccountSettings();
    } catch (e) {
      debugPrint('Erro ao sincronizar com services: $e');
    }
  }

  /// Sincroniza configurações da conta
  Future<void> _syncAccountSettings() async {
    try {
      // Por enquanto, usar configurações padrão
      // TODO: Integrar com stream de usuário do AuthRepository quando necessário
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
      final result = await _settingsRepository.saveSettings(newSettings);

      result.fold(
        (Failure failure) => throw Exception(failure.message),
        (void _) {
          state = state.copyWith(
            settings: newSettings,
            isLoading: false,
          ).withSuccess('Configurações salvas com sucesso');

          // Aplicar efeitos cascata
          _applyCascadeEffects(newSettings);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false).withError('Erro ao salvar configurações: $e');
    }
  }

  /// Atualiza configurações específicas de notificações
  Future<void> updateNotificationSettings(NotificationSettingsEntity newSettings) async {
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

  // ==========================================================================
  // MÉTODOS ESPECÍFICOS PARA FACILITAR USO NAS PÁGINAS
  // ==========================================================================

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
    final updatedTaskTypes = Map<String, bool>.from(state.settings.notifications.taskTypeSettings);
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

  // ==========================================================================
  // MÉTODOS DE NOTIFICAÇÃO INTEGRADOS
  // ==========================================================================

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

  // ==========================================================================
  // MÉTODOS DE BACKUP INTEGRADOS (se disponível)
  // ==========================================================================

  /// Cria backup manual das configurações
  Future<void> createConfigurationBackup() async {
    final backupService = _backupService;
    if (backupService == null) {
      state = state.withError('Serviço de backup não disponível');
      return;
    }

    try {
      final exportResult = await _settingsRepository.exportSettings();

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
      final result = await _settingsRepository.resetToDefaults();

      result.fold(
        (Failure failure) => throw Exception(failure.message),
        (void _) async {
          final newSettings = SettingsEntity.defaults();
          state = state.copyWith(
            settings: newSettings,
            isLoading: false,
          ).withSuccess('Configurações resetadas com sucesso');

          // Reaplica configurações nos services
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
    // Por enquanto não há efeitos cascata específicos
    // TODO: Implementar quando necessário (e.g., notificar ThemeProvider)
  }
}

// =============================================================================
// PROVIDERS PRINCIPAIS
// =============================================================================

/// Provider do repositório de configurações (obtido via DI)
final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  // TODO: Integrar com GetIt ou criar factory
  throw UnimplementedError('SettingsRepository deve ser fornecido via DI');
});

/// Provider do serviço de notificações (obtido via DI)
final plantisNotificationServiceProvider = Provider<PlantisNotificationService>((ref) {
  // TODO: Integrar com GetIt ou criar factory
  throw UnimplementedError('PlantisNotificationService deve ser fornecido via DI');
});

/// Provider do serviço de backup (obtido via DI, opcional)
final backupServiceProvider = Provider<BackupService?>((ref) {
  // TODO: Integrar com GetIt ou criar factory
  return null; // Por enquanto opcional
});

/// Provider principal do SettingsNotifier
final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final notificationService = ref.watch(plantisNotificationServiceProvider);
  final backupService = ref.watch(backupServiceProvider);

  return SettingsNotifier(
    settingsRepository: settingsRepository,
    notificationService: notificationService,
    backupService: backupService,
  );
});

// =============================================================================
// PROVIDERS DERIVADOS PARA FACILITAR USO
// =============================================================================

/// Provider para SettingsEntity atual
final settingsProvider = Provider<SettingsEntity>((ref) {
  return ref.watch(settingsNotifierProvider).settings;
});

/// Provider para estado de carregamento
final settingsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(settingsNotifierProvider).isLoading;
});

/// Provider para verificar se está inicializado
final settingsInitializedProvider = Provider<bool>((ref) {
  return ref.watch(settingsNotifierProvider).isInitialized;
});

/// Provider para mensagem de erro
final settingsErrorProvider = Provider<String?>((ref) {
  return ref.watch(settingsNotifierProvider).errorMessage;
});

/// Provider para mensagem de sucesso
final settingsSuccessProvider = Provider<String?>((ref) {
  return ref.watch(settingsNotifierProvider).successMessage;
});

// =============================================================================
// PROVIDERS ESPECÍFICOS PARA CONFIGURAÇÕES
// =============================================================================

/// Provider para configurações de notificação
final notificationSettingsProvider = Provider<NotificationSettingsEntity>((ref) {
  return ref.watch(settingsProvider).notifications;
});

/// Provider para configurações de backup
final backupSettingsProvider = Provider<BackupSettingsEntity>((ref) {
  return ref.watch(settingsProvider).backup;
});

/// Provider para configurações de tema
final themeSettingsProvider = Provider<ThemeSettingsEntity>((ref) {
  return ref.watch(settingsProvider).theme;
});

/// Provider para configurações de conta
final accountSettingsProvider = Provider<AccountSettingsEntity>((ref) {
  return ref.watch(settingsProvider).account;
});

/// Provider para configurações do app
final appSettingsProvider = Provider<AppSettingsEntity>((ref) {
  return ref.watch(settingsProvider).app;
});

// =============================================================================
// PROVIDERS DERIVADOS PARA USO ESPECÍFICO
// =============================================================================

/// Provider para verificar se tem permissões de notificação
final hasNotificationPermissionsProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).permissionsGranted;
});

/// Provider para verificar se está em modo escuro
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeSettingsProvider).isDarkMode;
});

/// Provider para verificar se notificações estão habilitadas
final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).taskRemindersEnabled;
});

/// Provider para verificar se é plataforma web
final isWebPlatformProvider = Provider<bool>((ref) {
  return kIsWeb;
});

// =============================================================================
// PROVIDERS DE TEXTO E ICONS (CONVENIENTES)
// =============================================================================

/// Provider para texto de status das notificações
final notificationStatusTextProvider = Provider<String>((ref) {
  final isWeb = ref.watch(isWebPlatformProvider);
  final hasPermissions = ref.watch(hasNotificationPermissionsProvider);

  if (isWeb) {
    return 'Notificações não disponíveis na versão web';
  }
  if (!hasPermissions) {
    return 'Notificações desabilitadas. Habilite nas configurações do dispositivo.';
  }
  return 'Notificações habilitadas para este aplicativo';
});

/// Provider para cor de status das notificações
final notificationStatusColorProvider = Provider<Color>((ref) {
  final isWeb = ref.watch(isWebPlatformProvider);
  final hasPermissions = ref.watch(hasNotificationPermissionsProvider);

  if (isWeb) {
    return Colors.grey;
  }
  return hasPermissions ? Colors.green : Colors.red;
});

/// Provider para ícone de status das notificações
final notificationStatusIconProvider = Provider<IconData>((ref) {
  final isWeb = ref.watch(isWebPlatformProvider);
  final hasPermissions = ref.watch(hasNotificationPermissionsProvider);

  if (isWeb) {
    return Icons.web;
  }
  return hasPermissions ? Icons.notifications_active : Icons.notifications_off;
});

/// Provider para subtitle do tema
final themeSubtitleProvider = Provider<String>((ref) {
  final themeSettings = ref.watch(themeSettingsProvider);

  if (themeSettings.isDarkMode) {
    return 'Tema escuro ativo';
  } else if (themeSettings.isLightMode) {
    return 'Tema claro ativo';
  } else {
    return 'Seguir sistema';
  }
});