import 'dart:convert';
import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import 'plantis_notification_config.dart';

/// Serviço de notificações do Plantis usando o core LocalNotificationService
class PlantisNotificationService {
  static final PlantisNotificationService _instance =
      PlantisNotificationService._internal();
  factory PlantisNotificationService() => _instance;
  PlantisNotificationService._internal();
  final INotificationRepository _notificationService =
      kIsWeb ? WebNotificationService() : LocalNotificationService();

  bool _isInitialized = false;

  /// Inicializa o serviço de notificações do Plantis
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _notificationService.initialize(
        defaultChannels: PlantisNotificationConfig.plantisChannels,
      );

      if (_isInitialized) {
        _notificationService.setNotificationTapCallback(_onNotificationTapped);
        _notificationService.setNotificationActionCallback(
          _onNotificationAction,
        );
      }

      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inicializar PlantisNotificationService: $e');
      }
      return false;
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final permission = await _notificationService.getPermissionStatus();
    return permission.isGranted;
  }

  /// Solicita permissão para notificações
  Future<bool> requestPermission() async {
    final permission = await _notificationService.requestPermission();
    return permission.isGranted;
  }

  /// Abre as configurações de notificação
  Future<bool> openSettings() async {
    return await _notificationService.openNotificationSettings();
  }

  /// Alias para compatibilidade
  Future<bool> openNotificationSettings() async {
    return await openSettings();
  }

  /// Solicita permissão (alias para compatibilidade)
  Future<bool> requestNotificationPermission() async {
    return await requestPermission();
  }

  /// Inicializa todas as notificações (compatibilidade)
  Future<void> initializeAllNotifications() async {
    if (kDebugMode) {
      print(
        'PlantisNotificationService: initializeAllNotifications - usando agendamento sob demanda',
      );
    }
  }

  /// Verifica e notifica tarefas atrasadas (compatibilidade)
  Future<void> checkAndNotifyOverdueTasks() async {
    if (kDebugMode) {
      print(
        'PlantisNotificationService: checkAndNotifyOverdueTasks - delegado para TaskNotificationService',
      );
    }
  }

  /// Agenda lembrete de tarefa (compatibilidade)
  Future<bool> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    DateTime? dueDate,
    String? taskDescription,
    String? plantName,
    String? plantId,
  }) async {
    return await schedulePlantCareNotification(
      plantId: plantId ?? taskId, // Usar plantId se disponível, senão taskId
      plantName: plantName ?? 'Planta',
      careType: 'general',
      scheduledDate: dueDate ?? DateTime.now().add(const Duration(hours: 1)),
      customMessage: taskDescription ?? taskName,
    );
  }

  /// Cancela notificações de tarefas (compatibilidade)
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      final id = _notificationService.generateNotificationId(taskId);
      await _notificationService.cancelNotification(id);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cancelar notificação de tarefa: $e');
      }
    }
  }

  /// Mostra notificação de nova planta (compatibilidade)
  Future<void> showNewPlantNotification({
    required String plantName,
    String? plantType,
    String? message,
  }) async {
    await showNotification(
      title: '🌱 Nova planta adicionada!',
      body: message ?? 'Você adicionou $plantName ao seu jardim',
      type: 'new_plant',
      extraData: {'plantName': plantName, 'plantType': plantType},
    );
  }

  /// Mostra notificação de tarefa atrasada (compatibilidade)
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    String? taskType,
  }) async {
    await showNotification(
      title: '⏰ Tarefa atrasada!',
      body: '$taskName para $plantName está atrasada',
      type: 'overdue_task',
      extraData: {
        'taskName': taskName,
        'plantName': plantName,
        'taskType': taskType,
      },
    );
  }

  /// Agenda cuidados diários para todas as plantas (compatibilidade)
  Future<void> scheduleDailyCareForAllPlants() async {
    if (kDebugMode) {
      print(
        'PlantisNotificationService: scheduleDailyCareForAllPlants - usando agendamento individual por planta',
      );
    }
  }

  /// Verifica se uma notificação está agendada (compatibilidade)
  Future<bool> isNotificationScheduled({
    required String plantId,
    required String careType,
  }) async {
    return await isPlantNotificationScheduled(plantId, careType);
  }

  /// Agenda notificação direta (compatibilidade)
  Future<bool> scheduleDirectNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      final notification = PlantisNotificationConfig.createGeneralNotification(
        id: notificationId,
        title: title,
        body: body,
        extraData: payload != null ? {'payload': payload} : null,
      );
      final scheduledNotification = NotificationEntity(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        payload: notification.payload,
        channelId: notification.channelId,
        scheduledDate: scheduledTime,
        priority: notification.priority,
      );

      return await _notificationService.scheduleNotification(
        scheduledNotification,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao agendar notificação direta: $e');
      }
      return false;
    }
  }

  /// Cancela notificação por ID (compatibilidade)
  Future<bool> cancelNotification(int notificationId) async {
    try {
      return await _notificationService.cancelNotification(notificationId);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cancelar notificação: $e');
      }
      return false;
    }
  }

  /// Mostra notificação de lembrete de tarefa (compatibilidade)
  Future<void> showTaskReminderNotification({
    required String taskName,
    required String plantName,
    String? taskType,
  }) async {
    await showNotification(
      title: '📋 Lembrete de tarefa',
      body: '$taskName para $plantName',
      type: 'task_reminder',
      extraData: {
        'taskName': taskName,
        'plantName': plantName,
        'taskType': taskType,
      },
    );
  }

  /// Agenda notificação de cuidado de planta
  Future<bool> schedulePlantCareNotification({
    required String plantId,
    required String plantName,
    required String careType,
    required DateTime scheduledDate,
    String? customMessage,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final id = _notificationService.generateNotificationId(
        '${plantId}_$careType',
      );

      final title = _getCareTypeTitle(careType);
      final body = customMessage ?? 'É hora de cuidar da sua $plantName';

      final notification =
          PlantisNotificationConfig.createPlantCareNotification(
            id: id,
            title: title,
            body: body,
            careType: careType,
            plantId: plantId,
            plantName: plantName,
            scheduledDate: scheduledDate,
          );

      return await _notificationService.scheduleNotification(notification);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao agendar notificação de cuidado: $e');
      }
      return false;
    }
  }

  /// Mostra notificação imediata
  Future<bool> showNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? extraData,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final id = DateTime.now().millisecondsSinceEpoch;

      final notification = PlantisNotificationConfig.createGeneralNotification(
        id: id,
        title: title,
        body: body,
        extraData: extraData,
      );

      return await _notificationService.showNotification(notification);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao mostrar notificação: $e');
      }
      return false;
    }
  }

  /// Cancela notificação específica de planta
  Future<bool> cancelPlantNotification(String plantId, String careType) async {
    try {
      final id = _notificationService.generateNotificationId(
        '${plantId}_$careType',
      );
      return await _notificationService.cancelNotification(id);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cancelar notificação: $e');
      }
      return false;
    }
  }

  /// Cancela todas as notificações de uma planta
  Future<bool> cancelAllPlantNotifications(String plantId) async {
    try {
      final pendingNotifications =
          await _notificationService.getPendingNotifications();
      bool allCancelled = true;

      for (final notification in pendingNotifications) {
        if (notification.payload != null) {
          try {
            final payloadData = jsonDecode(notification.payload!);
            if (payloadData is Map<String, dynamic> &&
                payloadData.containsKey('plantId') &&
                payloadData['plantId'] == plantId) {
              final cancelled = await _notificationService.cancelNotification(
                notification.id,
              );
              if (!cancelled) allCancelled = false;
            }
          } catch (e) {
          }
        }
      }

      return allCancelled;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cancelar notificações da planta: $e');
      }
      return false;
    }
  }

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications() async {
    return await _notificationService.cancelAllNotifications();
  }

  /// Lista todas as notificações agendadas
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }

  /// Lista notificações de uma planta específica
  Future<List<PendingNotificationEntity>> getPlantNotifications(
    String plantId,
  ) async {
    try {
      final allNotifications =
          await _notificationService.getPendingNotifications();

      return allNotifications.where((notification) {
        if (notification.payload != null) {
          try {
            final payloadData = jsonDecode(notification.payload!);
            return payloadData is Map<String, dynamic> &&
                payloadData.containsKey('plantId') &&
                payloadData['plantId'] == plantId;
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar notificações da planta: $e');
      }
      return [];
    }
  }

  /// Verifica se uma notificação específica está agendada
  Future<bool> isPlantNotificationScheduled(
    String plantId,
    String careType,
  ) async {
    try {
      final id = _notificationService.generateNotificationId(
        '${plantId}_$careType',
      );
      return await _notificationService.isNotificationScheduled(id);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar notificação agendada: $e');
      }
      return false;
    }
  }

  /// Callback quando notificação é tocada
  void _onNotificationTapped(String? payload) {
    if (payload != null && kDebugMode) {
      print('Notificação tocada: $payload');
    }
  }

  /// Callback quando ação de notificação é executada
  void _onNotificationAction(String actionId, String? payload) {
    if (kDebugMode) {
      print('Ação de notificação: $actionId, payload: $payload');
    }

    switch (actionId) {
      case 'mark_done':
        _handleMarkDoneAction(payload);
        break;
      case 'snooze':
        _handleSnoozeAction(payload);
        break;
    }
  }

  /// Marca tarefa como concluída
  void _handleMarkDoneAction(String? payload) {
    if (kDebugMode) {
      print('Marcando tarefa como concluída: $payload');
    }
  }

  /// Adia notificação por 1 hora
  void _handleSnoozeAction(String? payload) {
    if (kDebugMode) {
      print('Adiando notificação: $payload');
    }
  }

  /// Obtém título baseado no tipo de cuidado
  String _getCareTypeTitle(String careType) {
    switch (careType) {
      case 'watering':
        return '💧 Hora de regar!';
      case 'fertilizing':
        return '🌱 Hora de adubar!';
      case 'pruning':
        return '✂️ Hora de podar!';
      case 'pest_inspection':
        return '🔍 Verificar pragas';
      case 'cleaning':
        return '🧹 Limpar folhas';
      case 'repotting':
        return '🪴 Trocar vaso';
      default:
        return '🌿 Cuidar da planta';
    }
  }
}

/// Enum para compatibilidade com código existente
enum PlantisNotificationType {
  taskReminder('task_reminder'),
  overdueTask('overdue_task'),
  newPlant('new_plant'),
  dailyCareReminder('daily_care_reminder'),
  gardeningTip('gardening_tip');

  const PlantisNotificationType(this.value);
  final String value;
}
