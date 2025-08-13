import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// Serviço de notificações específico do Plantis
class PlantisNotificationService {
  static final PlantisNotificationService _instance = PlantisNotificationService._internal();
  factory PlantisNotificationService() => _instance;
  PlantisNotificationService._internal();

  static const String _appName = 'Plantis';
  static const int _primaryColor = 0xFF4CAF50; // Verde plantas

  final INotificationRepository _notificationRepository = LocalNotificationService();
  bool _isInitialized = false;

  /// Inicializa o serviço de notificações do Plantis
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Inicializa timezone
      await NotificationHelper.initializeTimeZone();

      // Configura settings
      final settings = NotificationHelper.createDefaultSettings(
        defaultColor: _primaryColor,
      );
      (_notificationRepository as LocalNotificationService).configure(settings);

      // Cria canais padrão
      final defaultChannels = NotificationHelper.getDefaultChannels(
        appName: _appName,
        primaryColor: _primaryColor,
      );

      // Inicializa o serviço
      final result = await _notificationRepository.initialize(
        defaultChannels: defaultChannels,
      );

      // Define callbacks
      _notificationRepository.setNotificationTapCallback(_handleNotificationTap);
      _notificationRepository.setNotificationActionCallback(_handleNotificationAction);

      _isInitialized = result;
      return result;
    } catch (e) {
      debugPrint('❌ Error initializing Plantis notifications: $e');
      return false;
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final permission = await _notificationRepository.getPermissionStatus();
    return permission.isGranted;
  }

  /// Solicita permissão para notificações
  Future<bool> requestNotificationPermission() async {
    final permission = await _notificationRepository.requestPermission();
    return permission.isGranted;
  }

  /// Abre configurações de notificação
  Future<bool> openNotificationSettings() async {
    return await _notificationRepository.openNotificationSettings();
  }

  // ==========================================================================
  // MÉTODOS PREPARATÓRIOS - Para implementar quando definir as regras de negócio
  // ==========================================================================

  /// Mostra notificação de lembrete de tarefa
  /// TODO: Implementar quando definir regras de negócio para agendamento
  Future<void> showTaskReminderNotification({
    required String taskName,
    required String plantName,
    String? taskDescription,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('task_reminder_$taskName'),
      title: '🌱 Lembrete de Tarefa',
      body: '$taskName para $plantName${taskDescription != null ? ' - $taskDescription' : ''}',
      payload: jsonEncode({
        'type': 'task_reminder',
        'task_name': taskName,
        'plant_name': plantName,
        'task_description': taskDescription,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de tarefa atrasada
  /// TODO: Implementar quando definir regras de negócio para detecção de atraso
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    required int daysOverdue,
  }) async {
    final notification = NotificationHelper.createAlertNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('overdue_task_$taskName'),
      title: '🚨 Tarefa Atrasada!',
      body: '$taskName para $plantName está $daysOverdue dia${daysOverdue > 1 ? 's' : ''} atrasada.',
      payload: jsonEncode({
        'type': 'overdue_task',
        'task_name': taskName,
        'plant_name': plantName,
        'days_overdue': daysOverdue,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de nova planta adicionada
  /// TODO: Implementar quando necessário
  Future<void> showNewPlantNotification({
    required String plantName,
    required String plantType,
  }) async {
    final notification = NotificationHelper.createPromotionNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('new_plant_$plantName'),
      title: '🌿 Nova Planta Adicionada!',
      body: '$plantName ($plantType) foi adicionada com sucesso.',
      payload: jsonEncode({
        'type': 'new_plant',
        'plant_name': plantName,
        'plant_type': plantType,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Agenda lembrete diário de cuidados
  /// TODO: Implementar quando definir horário e regras de recorrência
  Future<void> scheduleDailyCareReminder({
    required String message,
    required Duration interval,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('daily_care_reminder'),
      title: '🌱 Lembrete de Cuidados',
      body: message,
      payload: jsonEncode({
        'type': 'daily_care_reminder',
        'message': message,
        'interval': interval.inHours,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.schedulePeriodicNotification(notification, interval);
  }

  /// Mostra notificação de dica de jardinagem
  /// TODO: Implementar quando tiver conteúdo de dicas
  Future<void> showGardeningTipNotification({
    required String tip,
    String? category,
  }) async {
    final notification = NotificationHelper.createPromotionNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('gardening_tip'),
      title: '💡 Dica de Jardinagem',
      body: tip,
      payload: jsonEncode({
        'type': 'gardening_tip',
        'tip': tip,
        'category': category,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Cancela notificação específica
  Future<bool> cancelNotification(String identifier) async {
    final id = _notificationRepository.generateNotificationId(identifier);
    return await _notificationRepository.cancelNotification(id);
  }

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications() async {
    return await _notificationRepository.cancelAllNotifications();
  }

  /// Lista notificações pendentes
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return await _notificationRepository.getPendingNotifications();
  }

  /// Verifica se uma notificação específica está agendada
  Future<bool> isNotificationScheduled(String identifier) async {
    final id = _notificationRepository.generateNotificationId(identifier);
    return await _notificationRepository.isNotificationScheduled(id);
  }

  /// Manipula tap em notificação
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      debugPrint('🔔 Plantis notification tapped: $type');

      // TODO: Implementar navegação específica quando definir as telas
      switch (type) {
        case 'task_reminder':
          _navigateToTaskDetails(data);
          break;
        case 'overdue_task':
          _navigateToTasksList(data);
          break;
        case 'new_plant':
          _navigateToPlantDetails(data);
          break;
        case 'daily_care_reminder':
          _navigateToTasksList(data);
          break;
        case 'gardening_tip':
          _navigateToTipsPage(data);
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  /// Manipula ação de notificação
  void _handleNotificationAction(String actionId, String? payload) {
    debugPrint('🔔 Plantis notification action: $actionId');

    switch (actionId) {
      case 'view_details':
        _handleNotificationTap(payload);
        break;
      case 'dismiss':
        // Apenas dismissar
        break;
      case 'remind_later':
        _handleRemindLater(payload);
        break;
    }
  }

  // ==========================================================================
  // MÉTODOS DE NAVEGAÇÃO - Para implementar quando definir as telas
  // ==========================================================================

  /// Navegar para detalhes da tarefa
  void _navigateToTaskDetails(Map<String, dynamic> data) {
    // TODO: Implementar navegação para detalhes da tarefa
    debugPrint('Navigate to task details: ${data['task_name']}');
  }

  /// Navegar para lista de tarefas
  void _navigateToTasksList(Map<String, dynamic> data) {
    // TODO: Implementar navegação para lista de tarefas
    debugPrint('Navigate to tasks list');
  }

  /// Navegar para detalhes da planta
  void _navigateToPlantDetails(Map<String, dynamic> data) {
    // TODO: Implementar navegação para detalhes da planta
    debugPrint('Navigate to plant details: ${data['plant_name']}');
  }

  /// Navegar para página de dicas
  void _navigateToTipsPage(Map<String, dynamic> data) {
    // TODO: Implementar navegação para página de dicas
    debugPrint('Navigate to tips page');
  }

  /// Reagendar lembrete
  void _handleRemindLater(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      // TODO: Implementar reagendamento quando definir regras de negócio
      switch (type) {
        case 'task_reminder':
          // Reagendar tarefa para 1 hora depois
          debugPrint('Reschedule task reminder: ${data['task_name']}');
          break;
        // Adicionar outros tipos conforme necessário
      }
    } catch (e) {
      debugPrint('❌ Error rescheduling notification: $e');
    }
  }
}

/// Tipos de notificação do Plantis
enum PlantisNotificationType {
  taskReminder('task_reminder'),
  overdueTask('overdue_task'),
  newPlant('new_plant'),
  dailyCareReminder('daily_care_reminder'),
  gardeningTip('gardening_tip');

  const PlantisNotificationType(this.value);
  final String value;
}