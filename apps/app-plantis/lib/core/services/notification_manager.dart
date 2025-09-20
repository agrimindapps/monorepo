import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../di/injection_container.dart';
import 'interfaces/i_task_notification_manager.dart';
import 'interfaces/i_plant_notification_manager.dart';
import 'interfaces/i_notification_permission_manager.dart';
import 'interfaces/i_notification_schedule_manager.dart';
import 'plantis_notification_service.dart';

/// Gerenciador centralizado de notificações do Plantis
/// Implementa interfaces segregadas seguindo o princípio ISP
class NotificationManager implements 
    ITaskNotificationManager,
    IPlantNotificationManager,
    INotificationPermissionManager,
    INotificationScheduleManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  static NotificationManager get instance => _instance;

  PlantisNotificationService? _notificationService;
  bool _isInitialized = false;

  /// Inicializa o sistema completo de notificações
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Obtém o serviço do DI
      _notificationService = sl<PlantisNotificationService>();

      // Inicializa o serviço de notificações
      final result = await _notificationService!.initialize();

      if (result) {
        // Programa todas as notificações iniciais
        await _notificationService!.initializeAllNotifications();

        // Verifica tarefas atrasadas na inicialização
        await _notificationService!.checkAndNotifyOverdueTasks();

        _isInitialized = true;
        debugPrint('✅ NotificationManager initialized successfully');
        return true;
      } else {
        debugPrint('❌ Failed to initialize PlantisNotificationService');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error initializing NotificationManager: $e');
      return false;
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (_notificationService == null) return false;
    return await _notificationService!.areNotificationsEnabled();
  }

  /// Solicita permissão para notificações
  Future<bool> requestPermissions() async {
    if (_notificationService == null) return false;
    return await _notificationService!.requestPermission();
  }

  /// Abre configurações de notificação do sistema
  Future<bool> openNotificationSettings() async {
    if (_notificationService == null) return false;
    return await _notificationService!.openNotificationSettings();
  }

  /// Agenda notificação para uma tarefa
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    required String plantName,
    String? taskDescription,
    String? plantId,
    DateTime? dueDate,
  }) async {
    if (_notificationService == null) return;

    await _notificationService!.scheduleTaskReminder(
      taskId: taskId,
      taskName: taskName,
      plantName: plantName,
      taskDescription: taskDescription,
      plantId: plantId,
      dueDate: dueDate,
    );
  }

  /// Cancela notificações de uma tarefa
  Future<void> cancelTaskNotifications(String taskId) async {
    if (_notificationService == null) return;
    await _notificationService!.cancelTaskNotifications(taskId);
  }

  /// Mostra notificação instantânea de nova planta
  Future<void> showNewPlantNotification({
    required String plantName,
    required String plantType,
  }) async {
    if (_notificationService == null) return;

    await _notificationService!.showNewPlantNotification(
      plantName: plantName,
      plantType: plantType,
    );
  }

  /// Mostra notificação instantânea de tarefa atrasada
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    required int daysOverdue,
  }) async {
    if (_notificationService == null) return;

    await _notificationService!.showOverdueTaskNotification(
      taskName: taskName,
      plantName: plantName,
    );
  }

  /// Programa lembretes diários de cuidados
  @override
  Future<void> scheduleDailyCareReminders() async {
    if (_notificationService == null) return;
    await _notificationService!.scheduleDailyCareForAllPlants();
  }

  /// Verifica e notifica tarefas atrasadas
  @override
  Future<void> checkOverdueTasks() async {
    if (_notificationService == null) return;
    await _notificationService!.checkAndNotifyOverdueTasks();
  }

  /// Cancela todas as notificações
  @override
  Future<bool> cancelAllNotifications() async {
    if (_notificationService == null) return false;
    return await _notificationService!.cancelAllNotifications();
  }

  /// Lista todas as notificações pendentes
  @override
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    if (_notificationService == null) return [];
    return await _notificationService!.getPendingNotifications();
  }

  /// Verifica se uma notificação específica está agendada
  @override
  Future<bool> isNotificationScheduled(String identifier) async {
    if (_notificationService == null) return false;
    // Assumir que o identifier é no formato plantId_careType
    final parts = identifier.split('_');
    if (parts.length >= 2) {
      final plantId = parts[0];
      final careType = parts.sublist(1).join('_');
      return await _notificationService!.isPlantNotificationScheduled(plantId, careType);
    }
    return false;
  }
}
