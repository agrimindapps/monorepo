import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/plantis_notification_service.dart';
import '../../../../core/providers/core_di_providers.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';

part 'settings_notifier.g.dart';

/// State model para settings (imutável)
class SettingsState {
  final SettingsEntity settings;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final DeviceEntity? currentDevice;
  final List<DeviceEntity> connectedDevices;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.currentDevice,
    this.connectedDevices = const [],
  });

  factory SettingsState.initial() {
    return SettingsState(
      settings: SettingsEntity.defaults(),
      isLoading: false,
      isInitialized: false,
      connectedDevices: const [],
    );
  }

  SettingsState copyWith({
    SettingsEntity? settings,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    DeviceEntity? currentDevice,
    List<DeviceEntity>? connectedDevices,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearDevice = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      currentDevice: clearDevice ? null : (currentDevice ?? this.currentDevice),
      connectedDevices: connectedDevices ?? this.connectedDevices,
    );
  }

  NotificationSettingsEntity get notificationSettings => settings.notifications;
  BackupSettingsEntity get backupSettings => settings.backup;
  ThemeSettingsEntity get themeSettings => settings.theme;
  AccountSettingsEntity get accountSettings => settings.account;
  AppSettingsEntity get appSettings => settings.app;
  bool get hasPermissionsGranted => settings.notifications.permissionsGranted;
  bool get isDarkMode => settings.theme.isDarkMode;
  bool get isLightMode => settings.theme.isLightMode;
  bool get followSystemTheme => settings.theme.followSystemTheme;
  bool get notificationsEnabled => settings.notifications.taskRemindersEnabled;
  bool get isWebPlatform => kIsWeb;

  // Device management getters
  int get deviceCount => connectedDevices.length;
  int get activeDeviceCount => connectedDevices.where((d) => d.isActive).length;
  bool get hasDevices => connectedDevices.isNotEmpty;
  String get deviceCountText => '$activeDeviceCount/${connectedDevices.length} dispositivos';

  String get currentDeviceInfo {
    if (currentDevice == null) return 'Dispositivo atual desconhecido';
    return '${currentDevice!.name} (${currentDevice!.platform})';
  }

  List<Map<String, String>> get connectedDevicesInfo {
    return connectedDevices.map((device) {
      return {
        'uuid': device.uuid,
        'name': device.name,
        'model': device.model,
        'platform': device.platform,
        'lastActive': _formatLastActive(device.lastActiveAt),
        'isCurrent': (currentDevice?.uuid == device.uuid).toString(),
        'isActive': device.isActive.toString(),
      };
    }).toList();
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return '${difference.inMinutes}m atrás';
    if (difference.inDays < 1) return '${difference.inHours}h atrás';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}sem atrás';
    return '${(difference.inDays / 30).floor()}m atrás';
  }
}

@riverpod
Future<SettingsLocalDataSource> settingsLocalDataSource(Ref ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsLocalDataSource(prefs: prefs);
}

@riverpod
Future<ISettingsRepository> settingsRepository(Ref ref) async {
  final localDataSource = await ref.watch(settingsLocalDataSourceProvider.future);
  return SettingsRepository(localDataSource: localDataSource);
}

@riverpod
PlantisNotificationService plantisNotificationService(
  Ref ref,
) {
  return PlantisNotificationService();
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late final ISettingsRepository _settingsRepository;
  late final PlantisNotificationService _notificationService;

  @override
  Future<SettingsState> build() async {
    _settingsRepository = await ref.watch(settingsRepositoryProvider.future);
    _notificationService = ref.read(plantisNotificationServiceProvider);
    return await _initialize();
  }

  /// Inicializa o provider carregando configurações
  Future<SettingsState> _initialize() async {
    try {
      await _loadSettings();
      await _syncWithServices();
      await _loadDeviceInfo();

      final currentState = state.value ?? SettingsState.initial();
      return currentState.copyWith(isInitialized: true);
    } catch (e) {
      return SettingsState.initial().copyWith(
        errorMessage: 'Erro ao inicializar configurações: $e',
        isInitialized: false,
      );
    }
  }

  /// Carrega configurações do repositório
  Future<void> _loadSettings() async {
    final result = await _settingsRepository.loadSettings();

    result.fold(
      (Failure failure) {
        state = AsyncValue.data(
          (state.value ?? SettingsState.initial()).copyWith(
            errorMessage: 'Erro ao carregar configurações: ${failure.message}',
          ),
        );
      },
      (SettingsEntity settings) {
        state = AsyncValue.data(
          (state.value ?? SettingsState.initial()).copyWith(
            settings: settings,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Sincroniza com services externos
  Future<void> _syncWithServices() async {
    try {
      final currentState = state.value ?? SettingsState.initial();
      final hasPermissions =
          await _notificationService.areNotificationsEnabled();

      if (currentState.settings.notifications.permissionsGranted !=
          hasPermissions) {
        await updateNotificationSettings(
          currentState.settings.notifications.copyWith(
            permissionsGranted: hasPermissions,
          ),
        );
      }
      await _syncAccountSettings();
    } catch (e) {
      debugPrint('Erro ao sincronizar com services: $e');
    }
  }

  /// Sincroniza configurações da conta com AuthRepository
  Future<void> _syncAccountSettings() async {
    try {
      final accountSettings = AccountSettingsEntity.defaults();
      final currentState = state.value ?? SettingsState.initial();

      if (currentState.settings.account != accountSettings) {
        await updateAccountSettings(accountSettings);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar conta: $e');
    }
  }

  /// Atualiza configurações completas
  Future<void> updateSettings(SettingsEntity newSettings) async {
    state = AsyncValue.data(
      (state.value ?? SettingsState.initial()).copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await _settingsRepository.saveSettings(newSettings);

      result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            (state.value ?? SettingsState.initial()).copyWith(
              errorMessage: 'Erro ao salvar configurações: ${failure.message}',
              isLoading: false,
            ),
          );
        },
        (void _) {
          state = AsyncValue.data(
            (state.value ?? SettingsState.initial()).copyWith(
              settings: newSettings,
              successMessage: 'Configurações salvas com sucesso',
              isLoading: false,
            ),
          );
          _applyCascadeEffects(newSettings);
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          errorMessage: 'Erro inesperado: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Atualiza configurações específicas de notificações
  Future<void> updateNotificationSettings(
    NotificationSettingsEntity newSettings,
  ) async {
    final currentState = state.value ?? SettingsState.initial();
    final updatedSettings = currentState.settings.copyWith(
      notifications: newSettings,
    );
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de backup
  Future<void> updateBackupSettings(BackupSettingsEntity newSettings) async {
    final currentState = state.value ?? SettingsState.initial();
    final updatedSettings = currentState.settings.copyWith(backup: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de tema
  Future<void> updateThemeSettings(ThemeSettingsEntity newSettings) async {
    final currentState = state.value ?? SettingsState.initial();
    final updatedSettings = currentState.settings.copyWith(theme: newSettings);
    await updateSettings(updatedSettings);
    _applyThemeChanges(newSettings);
  }

  /// Atualiza configurações específicas de conta
  Future<void> updateAccountSettings(AccountSettingsEntity newSettings) async {
    final currentState = state.value ?? SettingsState.initial();
    final updatedSettings = currentState.settings.copyWith(
      account: newSettings,
    );
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas do app
  Future<void> updateAppSettings(AppSettingsEntity newSettings) async {
    final currentState = state.value ?? SettingsState.initial();
    final updatedSettings = currentState.settings.copyWith(app: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Toggle para lembretes de tarefas
  Future<void> toggleTaskReminders(bool enabled) async {
    final currentState = state.value ?? SettingsState.initial();
    final newSettings = currentState.settings.notifications.copyWith(
      taskRemindersEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para notificações de atraso
  Future<void> toggleOverdueNotifications(bool enabled) async {
    final currentState = state.value ?? SettingsState.initial();
    final newSettings = currentState.settings.notifications.copyWith(
      overdueNotificationsEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para resumo diário
  Future<void> toggleDailySummary(bool enabled) async {
    final currentState = state.value ?? SettingsState.initial();
    final newSettings = currentState.settings.notifications.copyWith(
      dailySummaryEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define minutos de antecedência para lembretes
  Future<void> setReminderMinutesBefore(int minutes) async {
    final currentState = state.value ?? SettingsState.initial();
    final newSettings = currentState.settings.notifications.copyWith(
      reminderMinutesBefore: minutes,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define horário do resumo diário
  Future<void> setDailySummaryTime(TimeOfDay time) async {
    final currentState = state.value ?? SettingsState.initial();
    final newSettings = currentState.settings.notifications.copyWith(
      dailySummaryTime: time,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para tipo específico de tarefa
  Future<void> toggleTaskType(String taskType, bool enabled) async {
    final currentState = state.value ?? SettingsState.initial();
    final updatedTaskTypes = Map<String, bool>.from(
      currentState.settings.notifications.taskTypeSettings,
    );
    updatedTaskTypes[taskType] = enabled;

    final newSettings = currentState.settings.notifications.copyWith(
      taskTypeSettings: updatedTaskTypes,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define modo de tema
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final currentState = state.value ?? SettingsState.initial();
    final newSettings = currentState.settings.theme.copyWith(
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

  /// Aplica efeitos cascata quando configurações mudam
  void _applyCascadeEffects(SettingsEntity newSettings) {
    final currentState = state.value ?? SettingsState.initial();
    if (currentState.settings.theme != newSettings.theme) {
      _applyThemeChanges(newSettings.theme);
    }
  }

  /// Aplica mudanças de tema no ThemeProvider
  void _applyThemeChanges(ThemeSettingsEntity themeSettings) {}

  /// Abre configurações do sistema para notificações
  Future<void> openNotificationSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          errorMessage: 'Erro ao abrir configurações: $e',
        ),
      );
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

      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          successMessage: 'Notificação de teste enviada!',
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          errorMessage: 'Erro ao enviar notificação: $e',
        ),
      );
    }
  }

  /// Limpa todas as notificações
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();

      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          successMessage: 'Todas as notificações foram canceladas',
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          errorMessage: 'Erro ao limpar notificações: $e',
        ),
      );
    }
  }

  /// Verifica se deve mostrar notificação
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    final currentState = state.value ?? SettingsState.initial();
    return currentState.settings.notifications.shouldShowNotification(
      notificationType,
      taskType: taskType,
    );
  }

  /// Verifica se tipo de tarefa está habilitado
  bool isTaskTypeEnabled(String taskType) {
    final currentState = state.value ?? SettingsState.initial();
    return currentState.settings.notifications.isTaskTypeEnabled(taskType);
  }

  /// Cria backup manual das configurações
  Future<void> createConfigurationBackup() async {
    try {
      final exportResult = await _settingsRepository.exportSettings();

      exportResult.fold(
        (Failure failure) {
          state = AsyncValue.data(
            (state.value ?? SettingsState.initial()).copyWith(
              errorMessage:
                  'Erro ao exportar configurações: ${failure.message}',
            ),
          );
        },
        (Map<String, dynamic> data) {
          state = AsyncValue.data(
            (state.value ?? SettingsState.initial()).copyWith(
              successMessage: 'Configurações incluídas no próximo backup',
            ),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          errorMessage: 'Erro ao preparar backup: $e',
        ),
      );
    }
  }

  /// Reseta todas as configurações
  Future<void> resetAllSettings() async {
    state = AsyncValue.data(
      (state.value ?? SettingsState.initial()).copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await _settingsRepository.resetToDefaults();

      await result.fold(
        (Failure failure) async {
          state = AsyncValue.data(
            (state.value ?? SettingsState.initial()).copyWith(
              errorMessage: 'Erro ao resetar configurações: ${failure.message}',
              isLoading: false,
            ),
          );
        },
        (void _) async {
          state = AsyncValue.data(
            SettingsState.initial().copyWith(
              settings: SettingsEntity.defaults(),
              successMessage: 'Configurações resetadas com sucesso',
              isLoading: false,
            ),
          );
          await _syncWithServices();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        (state.value ?? SettingsState.initial()).copyWith(
          errorMessage: 'Erro inesperado: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Recarrega configurações
  Future<void> refresh() async {
    await _loadSettings();
    await _syncWithServices();
    await _loadDeviceInfo();
  }

  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    state = AsyncValue.data(
      (state.value ?? SettingsState.initial()).copyWith(
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  // ============================================================================
  // DEVICE MANAGEMENT METHODS
  // ============================================================================

  /// Carrega informações de dispositivos do usuário
  /// Nota: Implementação futura quando o userId puder ser obtido do auth state
  Future<void> _loadDeviceInfo() async {
    try {
      // TODO: Implementar carregamento de dispositivos
      // Requer obter userId do auth state/provider
      if (kDebugMode) {
        debugPrint('ℹ️ Settings: Device loading não implementado ainda');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Settings: Erro ao carregar dispositivos - $e');
      }
    }
  }

  /// Revoga um dispositivo específico
  /// Nota: Implementação futura quando o userId puder ser obtido do auth state
  Future<void> revokeDevice(String deviceUuid) async {
    if (kDebugMode) {
      debugPrint('ℹ️ Settings: Device revoke não implementado ainda - $deviceUuid');
    }
  }

  /// Revoga todos os outros dispositivos exceto o atual
  /// Nota: Implementação futura
  Future<void> revokeAllOtherDevices() async {
    if (kDebugMode) {
      debugPrint('ℹ️ Settings: Revoke all devices não implementado ainda');
    }
  }

  /// Recarrega lista de dispositivos
  /// Nota: Implementação futura
  Future<void> refreshDevices() async {
    await _loadDeviceInfo();
  }
}

@riverpod
SettingsEntity currentSettingsValue(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.settings,
        loading: () => SettingsEntity.defaults(),
        error: (_, __) => SettingsEntity.defaults(),
      );
}

@riverpod
NotificationSettingsEntity notificationSettings(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.notificationSettings,
        loading: () => NotificationSettingsEntity.defaults(),
        error: (_, __) => NotificationSettingsEntity.defaults(),
      );
}

@riverpod
BackupSettingsEntity backupSettings(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.backupSettings,
        loading: () => BackupSettingsEntity.defaults(),
        error: (_, __) => BackupSettingsEntity.defaults(),
      );
}

@riverpod
ThemeSettingsEntity themeSettings(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.themeSettings,
        loading: () => ThemeSettingsEntity.defaults(),
        error: (_, __) => ThemeSettingsEntity.defaults(),
      );
}

@riverpod
AccountSettingsEntity accountSettings(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.accountSettings,
        loading: () => AccountSettingsEntity.defaults(),
        error: (_, __) => AccountSettingsEntity.defaults(),
      );
}

@riverpod
bool notificationsEnabled(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.notificationsEnabled,
        loading: () => true,
        error: (_, __) => true,
      );
}

@riverpod
bool isDarkMode(Ref ref) {
  return ref
      .watch(settingsNotifierProvider)
      .when(
        data: (state) => state.isDarkMode,
        loading: () => false,
        error: (_, __) => false,
      );
}

/// Extension para helpers de texto e cores de status
extension SettingsStateExtensions on SettingsState {
  /// Texto para exibir status das notificações
  String get notificationStatusText {
    if (isWebPlatform) {
      return 'Notificações não disponíveis na versão web';
    }
    if (!hasPermissionsGranted) {
      return 'Notificações desabilitadas. Habilite nas configurações do dispositivo.';
    }
    return 'Notificações habilitadas para este aplicativo';
  }

  /// Cor para status das notificações
  Color get notificationStatusColor {
    if (isWebPlatform) {
      return Colors.grey;
    }
    return hasPermissionsGranted ? Colors.green : Colors.red;
  }

  /// Ícone para status das notificações
  IconData get notificationStatusIcon {
    if (isWebPlatform) {
      return Icons.web;
    }
    return hasPermissionsGranted
        ? Icons.notifications_active
        : Icons.notifications_off;
  }

  /// Texto para subtitle do tema
  String get themeSubtitle {
    if (this.isDarkMode) {
      return 'Tema escuro ativo';
    } else if (isLightMode) {
      return 'Tema claro ativo';
    } else {
      return 'Seguir sistema';
    }
  }
}

// LEGACY ALIAS
final settingsNotifierProvider = settingsProvider;
