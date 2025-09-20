import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/plantis_notification_service.dart';

class NotificationsSettingsProvider extends ChangeNotifier {
  final PlantisNotificationService _notificationService;
  final SharedPreferences _prefs;

  NotificationsSettingsProvider({
    required PlantisNotificationService notificationService,
    required SharedPreferences prefs,
  }) : _notificationService = notificationService,
       _prefs = prefs;

  // Estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado das permissões
  bool _areNotificationsEnabled = false;
  bool get areNotificationsEnabled => _areNotificationsEnabled;

  // Configurações gerais
  bool _taskRemindersEnabled = true;
  bool _overdueNotificationsEnabled = true;
  bool _dailySummaryEnabled = true;

  bool get taskRemindersEnabled => _taskRemindersEnabled;
  bool get overdueNotificationsEnabled => _overdueNotificationsEnabled;
  bool get dailySummaryEnabled => _dailySummaryEnabled;

  // Configurações de tempo
  int _reminderMinutesBefore = 60;
  TimeOfDay _dailySummaryTime = const TimeOfDay(hour: 8, minute: 0);

  int get reminderMinutesBefore => _reminderMinutesBefore;
  TimeOfDay get dailySummaryTime => _dailySummaryTime;

  // Configurações por tipo de tarefa
  final Map<String, bool> _taskTypeSettings = {
    'Regar': true,
    'Adubar': true,
    'Podar': true,
    'Replantar': true,
    'Limpar': true,
    'Pulverizar': true,
    'Sol': true,
    'Sombra': true,
  };

  Map<String, bool> get taskTypeSettings => Map.unmodifiable(_taskTypeSettings);

  // Chaves para SharedPreferences
  static const String _keyTaskReminders = 'notifications_task_reminders';
  static const String _keyOverdueNotifications = 'notifications_overdue';
  static const String _keyDailySummary = 'notifications_daily_summary';
  static const String _keyReminderMinutes = 'notifications_reminder_minutes';
  static const String _keyDailySummaryHour = 'notifications_daily_summary_hour';
  static const String _keyDailySummaryMinute =
      'notifications_daily_summary_minute';
  static const String _keyTaskTypePrefix = 'notifications_task_type_';

  /// Carregar configurações
  Future<void> loadSettings() async {
    _setLoading(true);

    try {
      // Verificar permissões
      _areNotificationsEnabled =
          await _notificationService.areNotificationsEnabled();

      // Carregar configurações salvas
      _taskRemindersEnabled = _prefs.getBool(_keyTaskReminders) ?? true;
      _overdueNotificationsEnabled =
          _prefs.getBool(_keyOverdueNotifications) ?? true;
      _dailySummaryEnabled = _prefs.getBool(_keyDailySummary) ?? true;
      _reminderMinutesBefore = _prefs.getInt(_keyReminderMinutes) ?? 60;

      final hour = _prefs.getInt(_keyDailySummaryHour) ?? 8;
      final minute = _prefs.getInt(_keyDailySummaryMinute) ?? 0;
      _dailySummaryTime = TimeOfDay(hour: hour, minute: minute);

      // Carregar configurações por tipo de tarefa
      for (final key in _taskTypeSettings.keys) {
        _taskTypeSettings[key] =
            _prefs.getBool(_keyTaskTypePrefix + key) ?? true;
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações de notificações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Alternar lembretes de tarefas
  Future<void> toggleTaskReminders(bool value) async {
    _taskRemindersEnabled = value;
    await _prefs.setBool(_keyTaskReminders, value);
    notifyListeners();
  }

  /// Alternar notificações de atraso
  Future<void> toggleOverdueNotifications(bool value) async {
    _overdueNotificationsEnabled = value;
    await _prefs.setBool(_keyOverdueNotifications, value);
    notifyListeners();
  }

  /// Alternar resumo diário
  Future<void> toggleDailySummary(bool value) async {
    _dailySummaryEnabled = value;
    await _prefs.setBool(_keyDailySummary, value);
    notifyListeners();
  }

  /// Definir minutos de antecedência
  Future<void> setReminderMinutesBefore(int minutes) async {
    _reminderMinutesBefore = minutes;
    await _prefs.setInt(_keyReminderMinutes, minutes);
    notifyListeners();
  }

  /// Definir horário do resumo diário
  Future<void> setDailySummaryTime(TimeOfDay time) async {
    _dailySummaryTime = time;
    await _prefs.setInt(_keyDailySummaryHour, time.hour);
    await _prefs.setInt(_keyDailySummaryMinute, time.minute);
    notifyListeners();
  }

  /// Alternar configuração por tipo de tarefa
  Future<void> toggleTaskType(String taskType, bool value) async {
    _taskTypeSettings[taskType] = value;
    await _prefs.setBool(_keyTaskTypePrefix + taskType, value);
    notifyListeners();
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
    return _taskTypeSettings[taskType] ?? true;
  }

  /// Verificar se deve mostrar notificação baseado nas configurações
  bool shouldShowNotification(String notificationType, {String? taskType}) {
    if (!_areNotificationsEnabled) return false;

    switch (notificationType) {
      case 'task_reminder':
        if (!_taskRemindersEnabled) return false;
        if (taskType != null && !isTaskTypeEnabled(taskType)) return false;
        break;
      case 'task_overdue':
        if (!_overdueNotificationsEnabled) return false;
        if (taskType != null && !isTaskTypeEnabled(taskType)) return false;
        break;
      case 'daily_summary':
        if (!_dailySummaryEnabled) return false;
        break;
    }

    return true;
  }

  /// Obter configurações como Map para persistência
  Map<String, dynamic> toMap() {
    return {
      'taskRemindersEnabled': _taskRemindersEnabled,
      'overdueNotificationsEnabled': _overdueNotificationsEnabled,
      'dailySummaryEnabled': _dailySummaryEnabled,
      'reminderMinutesBefore': _reminderMinutesBefore,
      'dailySummaryTime': {
        'hour': _dailySummaryTime.hour,
        'minute': _dailySummaryTime.minute,
      },
      'taskTypeSettings': _taskTypeSettings,
    };
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
