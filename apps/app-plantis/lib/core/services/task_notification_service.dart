import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../../features/tasks/domain/entities/task.dart' as task_entity;
import 'plantis_notification_service.dart';

class TaskNotificationService {
  static final TaskNotificationService _instance = TaskNotificationService._internal();
  factory TaskNotificationService() => _instance;
  TaskNotificationService._internal();

  final PlantisNotificationService _notificationService = PlantisNotificationService();
  
  /// Método temporário para compatibilidade - usar até definir regras de negócio
  Future<void> _showCompatibilityNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Usar o método básico do core até implementar a lógica específica
    final notificationRepository = (_notificationService as dynamic)._notificationRepository;
    final notification = NotificationHelper.createReminderNotification(
      appName: 'Plantis',
      id: id,
      title: title,
      body: body,
      payload: payload,
      color: 0xFF4CAF50,
    );
    await notificationRepository.showNotification(notification);
  }

  /// Agendar notificação para uma tarefa específica
  Future<void> scheduleTaskNotification(task_entity.Task task) async {
    try {
      // Verificar se as notificações estão habilitadas
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) return;

      // Calcular horário da notificação (1 hora antes do vencimento)
      final DateTime notificationTime = task.dueDate.subtract(const Duration(hours: 1));
      
      // Não agendar se já passou do horário
      if (notificationTime.isBefore(DateTime.now())) return;

      final String title = _getNotificationTitle(task);
      final String body = _getNotificationBody(task);
      final String payload = _createNotificationPayload(task, PlantisNotificationType.taskReminder);

      final int notificationId = _createNotificationId('${task.id}_reminder');

      await _showCompatibilityNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erro ao agendar notificação da tarefa: $e');
    }
  }

  /// Criar notificação para tarefa em atraso
  Future<void> scheduleOverdueNotification(task_entity.Task task) async {
    try {
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) return;

      final String title = 'Tarefa em Atraso! 🚨';
      final String body = '${task.title} para ${task.plantName} está atrasada';
      final String payload = _createNotificationPayload(task, PlantisNotificationType.overdueTask);

      final int notificationId = _createNotificationId('${task.id}_overdue');

      await _showCompatibilityNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erro ao criar notificação de atraso: $e');
    }
  }

  /// Agendar notificação diária com resumo das tarefas
  Future<void> scheduleDailySummaryNotification(List<task_entity.Task> todayTasks) async {
    try {
      final bool enabled = await _notificationService.areNotificationsEnabled();
      if (!enabled) return;

      if (todayTasks.isEmpty) return;

      final String title = 'Bom dia! 🌱';
      final String body = _getDailySummaryBody(todayTasks);
      final String payload = _createDailySummaryPayload(todayTasks);

      const int notificationId = 9999; // ID fixo para resumo diário

      await _showCompatibilityNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erro ao agendar resumo diário: $e');
    }
  }

  /// Cancelar notificação de uma tarefa específica
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      await _notificationService.cancelNotification('${taskId}_reminder');
      await _notificationService.cancelNotification('${taskId}_overdue');
    } catch (e) {
      debugPrint('Erro ao cancelar notificações da tarefa: $e');
    }
  }

  /// Cancelar todas as notificações de tarefas
  Future<void> cancelAllTaskNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      debugPrint('Erro ao cancelar todas as notificações: $e');
    }
  }

  /// Gerar título da notificação baseado na tarefa
  String _getNotificationTitle(task_entity.Task task) {
    switch (task.type) {
      case task_entity.TaskType.watering:
        return 'Hora de regar! 💧';
      case task_entity.TaskType.fertilizing:
        return 'Hora de adubar! 🌿';
      case task_entity.TaskType.pruning:
        return 'Hora da poda! ✂️';
      case task_entity.TaskType.repotting:
        return 'Hora do transplante! 🪴';
      case task_entity.TaskType.cleaning:
        return 'Hora da limpeza! 🧹';
      case task_entity.TaskType.spraying:
        return 'Hora da pulverização! 💨';
      case task_entity.TaskType.sunlight:
        return 'Hora do sol! ☀️';
      case task_entity.TaskType.shade:
        return 'Hora da sombra! 🌤️';
      case task_entity.TaskType.custom:
        return 'Lembrete de cuidado! 🌱';
    }
  }

  /// Gerar corpo da notificação baseado na tarefa
  String _getNotificationBody(task_entity.Task task) {
    String priorityEmoji = '';
    switch (task.priority) {
      case task_entity.TaskPriority.urgent:
        priorityEmoji = ' ⚡';
        break;
      case task_entity.TaskPriority.high:
        priorityEmoji = ' 🔴';
        break;
      case task_entity.TaskPriority.medium:
        priorityEmoji = ' 🟡';
        break;
      case task_entity.TaskPriority.low:
        priorityEmoji = ' 🟢';
        break;
    }

    return '${task.title} - ${task.plantName}$priorityEmoji';
  }

  /// Gerar corpo do resumo diário
  String _getDailySummaryBody(List<task_entity.Task> todayTasks) {
    final int totalTasks = todayTasks.length;
    final int urgentTasks = todayTasks
        .where((t) => t.priority == task_entity.TaskPriority.urgent)
        .length;

    if (totalTasks == 1) {
      return 'Você tem 1 tarefa para hoje: ${todayTasks.first.title}';
    } else if (urgentTasks > 0) {
      return 'Você tem $totalTasks tarefas hoje, $urgentTasks urgentes!';
    } else {
      return 'Você tem $totalTasks tarefas agendadas para hoje';
    }
  }

  /// Criar payload da notificação
  /// Criar ID único para notificação baseado em string
  int _createNotificationId(String identifier) {
    return identifier.hashCode.abs() % 2147483647;
  }

  String _createNotificationPayload(task_entity.Task task, PlantisNotificationType type) {
    final Map<String, dynamic> payload = {
      'type': type.value,
      'taskId': task.id,
      'plantId': task.plantId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(payload);
  }

  /// Criar payload do resumo diário
  String _createDailySummaryPayload(List<task_entity.Task> tasks) {
    final Map<String, dynamic> payload = {
      'type': PlantisNotificationType.dailyCareReminder.value,
      'taskIds': tasks.map((t) => t.id).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(payload);
  }

  /// Processar tap na notificação (para uso futuro)
  static void handleNotificationTap(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String type = data['type'] ?? '';
      
      switch (type) {
        case 'task_reminder':
        case 'task_overdue':
          final String taskId = data['taskId'] ?? '';
          debugPrint('Navegando para tarefa: $taskId');
          // Aqui você pode implementar navegação para detalhes da tarefa
          break;
        case 'daily_reminder':
          debugPrint('Navegando para lista de tarefas de hoje');
          // Aqui você pode implementar navegação para lista de tarefas do dia
          break;
      }
    } catch (e) {
      debugPrint('Erro ao processar tap na notificação: $e');
    }
  }

  /// Verificar e criar notificações para tarefas em atraso
  Future<void> checkOverdueTasks(List<task_entity.Task> allTasks) async {
    try {
      final DateTime now = DateTime.now();
      final List<task_entity.Task> overdueTasks = allTasks
          .where((task) => 
              task.status == task_entity.TaskStatus.pending && 
              task.dueDate.isBefore(now))
          .toList();

      for (final task in overdueTasks) {
        await scheduleOverdueNotification(task);
      }
    } catch (e) {
      debugPrint('Erro ao verificar tarefas em atraso: $e');
    }
  }

  /// Reagendar notificações após completar uma tarefa
  Future<void> rescheduleTaskNotifications(List<task_entity.Task> allTasks) async {
    try {
      // Cancelar todas as notificações existentes
      await cancelAllTaskNotifications();

      // Reagendar para tarefas pendentes
      final List<task_entity.Task> pendingTasks = allTasks
          .where((task) => task.status == task_entity.TaskStatus.pending)
          .toList();

      for (final task in pendingTasks) {
        await scheduleTaskNotification(task);
      }
    } catch (e) {
      debugPrint('Erro ao reagendar notificações: $e');
    }
  }
}