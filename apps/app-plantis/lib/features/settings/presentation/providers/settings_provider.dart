import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/backup_service.dart';
import '../../../../core/services/plantis_notification_service.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';

/// Provider centralizado para gerenciar todas as configurações do app
class SettingsProvider extends ChangeNotifier {
  final ISettingsRepository _settingsRepository;
  final PlantisNotificationService _notificationService;
  final BackupService? _backupService;
  // Estado unificado
  SettingsEntity _settings = SettingsEntity.defaults();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _successMessage;

  SettingsProvider({
    required ISettingsRepository settingsRepository,
    required PlantisNotificationService notificationService,
    BackupService? backupService,
  }) : _settingsRepository = settingsRepository,
       _notificationService = notificationService,
       _backupService = backupService;

  // Getters
  SettingsEntity get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Getters específicos para facilitar uso nas páginas
  NotificationSettingsEntity get notificationSettings =>
      _settings.notifications;
  BackupSettingsEntity get backupSettings => _settings.backup;
  ThemeSettingsEntity get themeSettings => _settings.theme;
  AccountSettingsEntity get accountSettings => _settings.account;
  AppSettingsEntity get appSettings => _settings.app;

  // Estados derivados
  bool get hasPermissionsGranted => _settings.notifications.permissionsGranted;
  bool get isDarkMode => _settings.theme.isDarkMode;

  // Verificação de plataforma web
  bool get isWebPlatform => kIsWeb;

  // Getter simplificado para o switch de notificações
  bool get notificationsEnabled => _settings.notifications.taskRemindersEnabled;

  // Setter simplificado para o switch de notificações
  Future<void> setNotificationsEnabled(bool enabled) async {
    await toggleTaskReminders(enabled);
  }

  bool get isLightMode => _settings.theme.isLightMode;
  bool get followSystemTheme => _settings.theme.followSystemTheme;

  /// Inicializa o provider carregando configurações
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearMessages();

    try {
      await _loadSettings();
      await _syncWithServices();
      _isInitialized = true;
    } catch (e) {
      _setError('Erro ao inicializar configurações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega configurações do repositório
  Future<void> _loadSettings() async {
    final result = await _settingsRepository.loadSettings();

    result.fold(
      (Failure failure) =>
          _setError('Erro ao carregar configurações: ${failure.message}'),
      (SettingsEntity settings) {
        _settings = settings;
        _clearError();
      },
    );
  }

  /// Sincroniza com services externos
  Future<void> _syncWithServices() async {
    try {
      // Sincronizar permissões de notificação
      final hasPermissions =
          await _notificationService.areNotificationsEnabled();

      if (_settings.notifications.permissionsGranted != hasPermissions) {
        await updateNotificationSettings(
          _settings.notifications.copyWith(permissionsGranted: hasPermissions),
        );
      }

      // Sincronizar dados da conta
      await _syncAccountSettings();
    } catch (e) {
      debugPrint('Erro ao sincronizar com services: $e');
    }
  }

  /// Sincroniza configurações da conta com AuthRepository
  Future<void> _syncAccountSettings() async {
    try {
      // Por enquanto, usar configurações padrão
      // TODO: Integrar com stream de usuário do AuthRepository quando necessário
      final accountSettings = AccountSettingsEntity.defaults();

      if (_settings.account != accountSettings) {
        await updateAccountSettings(accountSettings);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar conta: $e');
    }
  }

  /// Atualiza configurações completas
  Future<void> updateSettings(SettingsEntity newSettings) async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _settingsRepository.saveSettings(newSettings);

      result.fold(
        (Failure failure) =>
            _setError('Erro ao salvar configurações: ${failure.message}'),
        (void _) {
          _settings = newSettings;
          _setSuccess('Configurações salvas com sucesso');

          // Sincronizar com services externos
          _applyCascadeEffects(newSettings);
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza configurações específicas de notificações
  Future<void> updateNotificationSettings(
    NotificationSettingsEntity newSettings,
  ) async {
    final updatedSettings = _settings.copyWith(notifications: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de backup
  Future<void> updateBackupSettings(BackupSettingsEntity newSettings) async {
    final updatedSettings = _settings.copyWith(backup: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas de tema
  Future<void> updateThemeSettings(ThemeSettingsEntity newSettings) async {
    final updatedSettings = _settings.copyWith(theme: newSettings);
    await updateSettings(updatedSettings);

    // Aplicar tema imediatamente
    _applyThemeChanges(newSettings);
  }

  /// Atualiza configurações específicas de conta
  Future<void> updateAccountSettings(AccountSettingsEntity newSettings) async {
    final updatedSettings = _settings.copyWith(account: newSettings);
    await updateSettings(updatedSettings);
  }

  /// Atualiza configurações específicas do app
  Future<void> updateAppSettings(AppSettingsEntity newSettings) async {
    final updatedSettings = _settings.copyWith(app: newSettings);
    await updateSettings(updatedSettings);
  }

  // Métodos específicos para facilitar uso nas páginas

  /// Toggle para lembretes de tarefas
  Future<void> toggleTaskReminders(bool enabled) async {
    final newSettings = _settings.notifications.copyWith(
      taskRemindersEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para notificações de atraso
  Future<void> toggleOverdueNotifications(bool enabled) async {
    final newSettings = _settings.notifications.copyWith(
      overdueNotificationsEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para resumo diário
  Future<void> toggleDailySummary(bool enabled) async {
    final newSettings = _settings.notifications.copyWith(
      dailySummaryEnabled: enabled,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define minutos de antecedência para lembretes
  Future<void> setReminderMinutesBefore(int minutes) async {
    final newSettings = _settings.notifications.copyWith(
      reminderMinutesBefore: minutes,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define horário do resumo diário
  Future<void> setDailySummaryTime(TimeOfDay time) async {
    final newSettings = _settings.notifications.copyWith(
      dailySummaryTime: time,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Toggle para tipo específico de tarefa
  Future<void> toggleTaskType(String taskType, bool enabled) async {
    final updatedTaskTypes = Map<String, bool>.from(
      _settings.notifications.taskTypeSettings,
    );
    updatedTaskTypes[taskType] = enabled;

    final newSettings = _settings.notifications.copyWith(
      taskTypeSettings: updatedTaskTypes,
    );
    await updateNotificationSettings(newSettings);
  }

  /// Define modo de tema
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final newSettings = _settings.theme.copyWith(
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
    // Aplicar mudanças de tema
    if (_settings.theme != newSettings.theme) {
      _applyThemeChanges(newSettings.theme);
    }
  }

  /// Aplica mudanças de tema no ThemeProvider
  void _applyThemeChanges(ThemeSettingsEntity themeSettings) {
    // A aplicação de temas agora é feita através dos providers Riverpod
    // Este método é mantido para compatibilidade mas não implementa nada
  }

  // Métodos de notificação integrados

  /// Abre configurações do sistema para notificações
  Future<void> openNotificationSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      _setError('Erro ao abrir configurações: $e');
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
      _setSuccess('Notificação de teste enviada!');
    } catch (e) {
      _setError('Erro ao enviar notificação: $e');
    }
  }

  /// Limpa todas as notificações
  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      _setSuccess('Todas as notificações foram canceladas');
    } catch (e) {
      _setError('Erro ao limpar notificações: $e');
    }
  }

  /// Verifica se deve mostrar notificação
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    return _settings.notifications.shouldShowNotification(
      notificationType,
      taskType: taskType,
    );
  }

  /// Verifica se tipo de tarefa está habilitado
  bool isTaskTypeEnabled(String taskType) {
    return _settings.notifications.isTaskTypeEnabled(taskType);
  }

  // Métodos de backup integrados (se disponível)

  /// Cria backup manual das configurações
  Future<void> createConfigurationBackup() async {
    final backupService = _backupService;
    if (backupService == null) {
      _setError('Serviço de backup não disponível');
      return;
    }

    try {
      final exportResult = await _settingsRepository.exportSettings();

      exportResult.fold(
        (Failure failure) =>
            _setError('Erro ao exportar configurações: ${failure.message}'),
        (Map<String, dynamic> data) =>
            _setSuccess('Configurações incluídas no próximo backup'),
      );
    } catch (e) {
      _setError('Erro ao preparar backup: $e');
    }
  }

  /// Reseta todas as configurações
  Future<void> resetAllSettings() async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _settingsRepository.resetToDefaults();

      result.fold(
        (Failure failure) =>
            _setError('Erro ao resetar configurações: ${failure.message}'),
        (void _) async {
          _settings = SettingsEntity.defaults();
          _setSuccess('Configurações resetadas com sucesso');

          // Reaplica configurações nos services
          await _syncWithServices();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recarrega configurações
  Future<void> refresh() async {
    await _loadSettings();
    await _syncWithServices();
    notifyListeners();
  }

  /// Limpa mensagens de erro/sucesso
  void clearMessages() {
    _clearMessages();
  }

  // Métodos privados de gerenciamento de estado

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String success) {
    _successMessage = success;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

/// Extension para helpers de texto e cores de status
extension SettingsProviderExtensions on SettingsProvider {
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
    if (isDarkMode) {
      return 'Tema escuro ativo';
    } else if (isLightMode) {
      return 'Tema claro ativo';
    } else {
      return 'Seguir sistema';
    }
  }
}
