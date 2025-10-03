import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/plantis_notification_service.dart';

part 'notifications_settings_notifier.g.dart';

/// State model para notifications settings (imutável)
class NotificationsSettingsState {
  final bool areNotificationsEnabled;
  final bool taskRemindersEnabled;
  final bool overdueNotificationsEnabled;
  final bool dailySummaryEnabled;
  final int reminderMinutesBefore;
  final TimeOfDay dailySummaryTime;
  final Map<String, bool> taskTypeSettings;
  final bool isLoading;

  const NotificationsSettingsState({
    required this.areNotificationsEnabled,
    required this.taskRemindersEnabled,
    required this.overdueNotificationsEnabled,
    required this.dailySummaryEnabled,
    required this.reminderMinutesBefore,
    required this.dailySummaryTime,
    required this.taskTypeSettings,
    this.isLoading = false,
  });

  factory NotificationsSettingsState.initial() {
    return const NotificationsSettingsState(
      areNotificationsEnabled: false,
      taskRemindersEnabled: true,
      overdueNotificationsEnabled: true,
      dailySummaryEnabled: true,
      reminderMinutesBefore: 60,
      dailySummaryTime: TimeOfDay(hour: 8, minute: 0),
      taskTypeSettings: {
        'Regar': true,
        'Adubar': true,
        'Podar': true,
        'Replantar': true,
        'Limpar': true,
        'Pulverizar': true,
        'Sol': true,
        'Sombra': true,
      },
      isLoading: false,
    );
  }

  NotificationsSettingsState copyWith({
    bool? areNotificationsEnabled,
    bool? taskRemindersEnabled,
    bool? overdueNotificationsEnabled,
    bool? dailySummaryEnabled,
    int? reminderMinutesBefore,
    TimeOfDay? dailySummaryTime,
    Map<String, bool>? taskTypeSettings,
    bool? isLoading,
  }) {
    return NotificationsSettingsState(
      areNotificationsEnabled: areNotificationsEnabled ?? this.areNotificationsEnabled,
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      overdueNotificationsEnabled: overdueNotificationsEnabled ?? this.overdueNotificationsEnabled,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      taskTypeSettings: taskTypeSettings ?? this.taskTypeSettings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Verifica se deve mostrar notificação baseado nas configurações
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    if (!areNotificationsEnabled) return false;

    switch (notificationType) {
      case 'task_reminder':
        if (!taskRemindersEnabled) return false;
        if (taskType != null && !isTaskTypeEnabled(taskType)) return false;
        break;
      case 'task_overdue':
        if (!overdueNotificationsEnabled) return false;
        if (taskType != null && !isTaskTypeEnabled(taskType)) return false;
        break;
      case 'daily_summary':
        if (!dailySummaryEnabled) return false;
        break;
    }

    return true;
  }

  /// Verifica se um tipo de tarefa está habilitado
  bool isTaskTypeEnabled(String taskType) {
    return taskTypeSettings[taskType] ?? true;
  }

  /// Obter configurações como Map para persistência
  Map<String, dynamic> toMap() {
    return {
      'taskRemindersEnabled': taskRemindersEnabled,
      'overdueNotificationsEnabled': overdueNotificationsEnabled,
      'dailySummaryEnabled': dailySummaryEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'dailySummaryTime': {
        'hour': dailySummaryTime.hour,
        'minute': dailySummaryTime.minute,
      },
      'taskTypeSettings': taskTypeSettings,
    };
  }
}

// ============================================================================
// DEPENDENCY PROVIDERS
// ============================================================================

@riverpod
PlantisNotificationService notificationService(NotificationServiceRef ref) {
  return getIt<PlantisNotificationService>();
}

@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return getIt<SharedPreferences>();
}

// ============================================================================
// NOTIFICATIONS SETTINGS NOTIFIER
// ============================================================================

@riverpod
class NotificationsSettingsNotifier extends _$NotificationsSettingsNotifier {
  late final PlantisNotificationService _notificationService;
  late final SharedPreferences _prefs;

  // Chaves para SharedPreferences
  static const String _keyTaskReminders = 'notifications_task_reminders';
  static const String _keyOverdueNotifications = 'notifications_overdue';
  static const String _keyDailySummary = 'notifications_daily_summary';
  static const String _keyReminderMinutes = 'notifications_reminder_minutes';
  static const String _keyDailySummaryHour = 'notifications_daily_summary_hour';
  static const String _keyDailySummaryMinute = 'notifications_daily_summary_minute';
  static const String _keyTaskTypePrefix = 'notifications_task_type_';

  @override
  Future<NotificationsSettingsState> build() async {
    _notificationService = ref.read(notificationServiceProvider);
    _prefs = await ref.read(sharedPreferencesProvider.future);

    // Load settings
    return await _loadSettings();
  }

  /// Carregar configurações
  Future<NotificationsSettingsState> _loadSettings() async {
    try {
      // Verificar permissões
      final areNotificationsEnabled = await _notificationService.areNotificationsEnabled();

      // Carregar configurações salvas
      final taskRemindersEnabled = _prefs.getBool(_keyTaskReminders) ?? true;
      final overdueNotificationsEnabled = _prefs.getBool(_keyOverdueNotifications) ?? true;
      final dailySummaryEnabled = _prefs.getBool(_keyDailySummary) ?? true;
      final reminderMinutesBefore = _prefs.getInt(_keyReminderMinutes) ?? 60;

      final hour = _prefs.getInt(_keyDailySummaryHour) ?? 8;
      final minute = _prefs.getInt(_keyDailySummaryMinute) ?? 0;
      final dailySummaryTime = TimeOfDay(hour: hour, minute: minute);

      // Carregar configurações por tipo de tarefa
      final taskTypeSettings = <String, bool>{
        'Regar': true,
        'Adubar': true,
        'Podar': true,
        'Replantar': true,
        'Limpar': true,
        'Pulverizar': true,
        'Sol': true,
        'Sombra': true,
      };

      for (final key in taskTypeSettings.keys) {
        taskTypeSettings[key] = _prefs.getBool(_keyTaskTypePrefix + key) ?? true;
      }

      return NotificationsSettingsState(
        areNotificationsEnabled: areNotificationsEnabled,
        taskRemindersEnabled: taskRemindersEnabled,
        overdueNotificationsEnabled: overdueNotificationsEnabled,
        dailySummaryEnabled: dailySummaryEnabled,
        reminderMinutesBefore: reminderMinutesBefore,
        dailySummaryTime: dailySummaryTime,
        taskTypeSettings: taskTypeSettings,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Erro ao carregar configurações de notificações: $e');
      return NotificationsSettingsState.initial();
    }
  }

  /// Alternar lembretes de tarefas
  Future<void> toggleTaskReminders(bool value) async {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();

    state = AsyncValue.data(currentState.copyWith(
      taskRemindersEnabled: value,
    ));

    await _prefs.setBool(_keyTaskReminders, value);
  }

  /// Alternar notificações de atraso
  Future<void> toggleOverdueNotifications(bool value) async {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();

    state = AsyncValue.data(currentState.copyWith(
      overdueNotificationsEnabled: value,
    ));

    await _prefs.setBool(_keyOverdueNotifications, value);
  }

  /// Alternar resumo diário
  Future<void> toggleDailySummary(bool value) async {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();

    state = AsyncValue.data(currentState.copyWith(
      dailySummaryEnabled: value,
    ));

    await _prefs.setBool(_keyDailySummary, value);
  }

  /// Definir minutos de antecedência
  Future<void> setReminderMinutesBefore(int minutes) async {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();

    state = AsyncValue.data(currentState.copyWith(
      reminderMinutesBefore: minutes,
    ));

    await _prefs.setInt(_keyReminderMinutes, minutes);
  }

  /// Definir horário do resumo diário
  Future<void> setDailySummaryTime(TimeOfDay time) async {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();

    state = AsyncValue.data(currentState.copyWith(
      dailySummaryTime: time,
    ));

    await _prefs.setInt(_keyDailySummaryHour, time.hour);
    await _prefs.setInt(_keyDailySummaryMinute, time.minute);
  }

  /// Alternar configuração por tipo de tarefa
  Future<void> toggleTaskType(String taskType, bool value) async {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();
    final updatedTaskTypes = Map<String, bool>.from(currentState.taskTypeSettings);
    updatedTaskTypes[taskType] = value;

    state = AsyncValue.data(currentState.copyWith(
      taskTypeSettings: updatedTaskTypes,
    ));

    await _prefs.setBool(_keyTaskTypePrefix + taskType, value);
  }

  /// Abrir configurações do sistema
  Future<void> openNotificationSettings() async {
    await _notificationService.openNotificationSettings();
  }

  /// Enviar notificação de teste
  Future<void> sendTestNotification() async {
    await _notificationService.showTaskReminderNotification(
      taskName: 'Teste de Notificação',
      plantName: 'Planta de Teste',
      taskType: 'test',
    );
  }

  /// Limpar todas as notificações
  Future<void> clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Verificar se um tipo de tarefa está habilitado
  bool isTaskTypeEnabled(String taskType) {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();
    return currentState.isTaskTypeEnabled(taskType);
  }

  /// Verificar se deve mostrar notificação baseado nas configurações
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    final currentState = state.valueOrNull ?? NotificationsSettingsState.initial();
    return currentState.shouldShowNotification(notificationType, taskType: taskType);
  }
}
