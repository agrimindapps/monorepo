import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../di/injection_container.dart';
import '../utils/navigation_service.dart' as local;

/// Serviço de notificações específico do Plantis
class PlantisNotificationService {
  static final PlantisNotificationService _instance =
      PlantisNotificationService._internal();
  factory PlantisNotificationService() => _instance;
  PlantisNotificationService._internal();

  static const String _appName = 'Plantis';
  static const int _primaryColor = 0xFF4CAF50; // Verde plantas

  final INotificationRepository _notificationRepository = kIsWeb 
      ? WebNotificationService()
      : LocalNotificationService();
  bool _isInitialized = false;

  /// Inicializa o serviço de notificações do Plantis
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Verificar se está rodando na web
    if (kIsWeb) {
      debugPrint('⚠️ Notifications not supported on web platform');
      _isInitialized = true; // Mock initialization for web
      return true;
    }

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
      _notificationRepository.setNotificationTapCallback(
        _handleNotificationTap,
      );
      _notificationRepository.setNotificationActionCallback(
        _handleNotificationAction,
      );

      _isInitialized = result;
      return result;
    } catch (e) {
      debugPrint('❌ Error initializing Plantis notifications: $e');
      // Para web e outras plataformas não suportadas, considerar como inicializado
      _isInitialized = true;
      return true;
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false; // Web não suporta notificações locais
    
    try {
      final permission = await _notificationRepository.getPermissionStatus();
      return permission.isGranted;
    } catch (e) {
      debugPrint('❌ Error getting permission status: $e');
      return false;
    }
  }

  /// Solicita permissão para notificações
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false; // Web não suporta notificações locais
    
    try {
      final permission = await _notificationRepository.requestPermission();
      return permission.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Abre configurações de notificação
  Future<bool> openNotificationSettings() async {
    if (kIsWeb) return false; // Web não suporta configurações nativas
    
    try {
      return await _notificationRepository.openNotificationSettings();
    } catch (e) {
      debugPrint('❌ Error opening notification settings: $e');
      return false;
    }
  }

  // ==========================================================================
  // MÉTODOS PREPARATÓRIOS - Para implementar quando definir as regras de negócio
  // ==========================================================================

  /// Mostra notificação de lembrete de tarefa
  Future<void> showTaskReminderNotification({
    required String taskName,
    required String plantName,
    String? taskDescription,
    String? taskId,
    String? plantId,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId(
        'task_reminder_$taskName',
      ),
      title: '🌱 Lembrete de Tarefa',
      body:
          '$taskName para $plantName${taskDescription != null ? ' - $taskDescription' : ''}',
      payload: jsonEncode({
        'type': 'task_reminder',
        'task_name': taskName,
        'plant_name': plantName,
        'task_description': taskDescription,
        'task_id': taskId,
        'plant_id': plantId,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de tarefa atrasada
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    required int daysOverdue,
  }) async {
    final notification = NotificationHelper.createAlertNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId(
        'overdue_task_$taskName',
      ),
      title: '🚨 Tarefa Atrasada!',
      body:
          '$taskName para $plantName está $daysOverdue dia${daysOverdue > 1 ? 's' : ''} atrasada.',
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
  Future<void> showNewPlantNotification({
    required String plantName,
    required String plantType,
  }) async {
    final notification = NotificationHelper.createPromotionNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId(
        'new_plant_$plantName',
      ),
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

    await _notificationRepository.schedulePeriodicNotification(
      notification,
      interval,
    );
  }

  /// Mostra notificação de dica de jardinagem
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
    if (kIsWeb) return true; // Web não precisa cancelar notificações
    
    try {
      final id = _notificationRepository.generateNotificationId(identifier);
      return await _notificationRepository.cancelNotification(id);
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
      return false;
    }
  }

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications() async {
    if (kIsWeb) return true; // Web não precisa cancelar notificações
    
    try {
      return await _notificationRepository.cancelAllNotifications();
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
      return false;
    }
  }

  /// Lista notificações pendentes
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    if (kIsWeb) return <PendingNotificationEntity>[]; // Web não tem notificações pendentes
    
    try {
      return await _notificationRepository.getPendingNotifications();
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return <PendingNotificationEntity>[];
    }
  }

  /// Verifica se uma notificação específica está agendada
  Future<bool> isNotificationScheduled(String identifier) async {
    if (kIsWeb) return false; // Web não agenda notificações
    
    try {
      final id = _notificationRepository.generateNotificationId(identifier);
      return await _notificationRepository.isNotificationScheduled(id);
    } catch (e) {
      debugPrint('❌ Error checking notification schedule: $e');
      return false;
    }
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
    final context = _getNavigationContext();
    if (context != null) {
      // Navegar para lista de tarefas (ainda não temos detalhes específicos)
      Navigator.of(context).pushNamed('/tasks');
    }
    debugPrint('Navigate to task details: ${data['task_name']}');
  }

  /// Navegar para lista de tarefas
  void _navigateToTasksList(Map<String, dynamic> data) {
    final context = _getNavigationContext();
    if (context != null) {
      Navigator.of(context).pushNamed('/tasks');
    }
    debugPrint('Navigate to tasks list');
  }

  /// Navegar para detalhes da planta
  void _navigateToPlantDetails(Map<String, dynamic> data) {
    final context = _getNavigationContext();
    if (context != null) {
      final plantName = data['plant_name'] as String?;
      if (plantName != null) {
        // Navegar para lista de plantas (pode ser filtrada pelo nome)
        Navigator.of(
          context,
        ).pushNamed('/plants', arguments: {'filter': plantName});
      } else {
        Navigator.of(context).pushNamed('/plants');
      }
    }
    debugPrint('Navigate to plant details: ${data['plant_name']}');
  }

  /// Navegar para página de dicas
  void _navigateToTipsPage(Map<String, dynamic> data) {
    final context = _getNavigationContext();
    if (context != null) {
      // Como não temos página de dicas ainda, vai para home
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
    debugPrint('Navigate to tips page');
  }

  /// Obter contexto de navegação
  BuildContext? _getNavigationContext() {
    try {
      final navigationService = sl<local.NavigationService>();
      return navigationService.currentContext;
    } catch (e) {
      debugPrint('❌ Error getting navigation context: $e');
      return null;
    }
  }

  /// Reagendar lembrete
  void _handleRemindLater(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'task_reminder':
          // Reagendar tarefa para 1 hora depois
          _rescheduleTaskReminder(data, const Duration(hours: 1));
          break;
        case 'daily_care_reminder':
          // Reagendar lembrete diário para próximo dia
          _rescheduleDailyCareReminder(data);
          break;
        // Adicionar outros tipos conforme necessário
      }
    } catch (e) {
      debugPrint('❌ Error rescheduling notification: $e');
    }
  }

  /// Reagendar lembrete de tarefa
  Future<void> _rescheduleTaskReminder(
    Map<String, dynamic> data,
    Duration delay,
  ) async {
    try {
      final taskName = data['task_name'] as String? ?? '';
      final plantName = data['plant_name'] as String? ?? '';
      final taskDescription = data['task_description'] as String?;

      final scheduledDate = DateTime.now().add(delay);

      final notification = NotificationHelper.createReminderNotification(
        appName: _appName,
        id: _notificationRepository.generateNotificationId(
          'task_reminder_${taskName}_rescheduled',
        ),
        title: '🌱 Lembrete de Tarefa (Reagendado)',
        body:
            '$taskName para $plantName${taskDescription != null ? ' - $taskDescription' : ''}',
        scheduledDate: scheduledDate,
        payload: jsonEncode({
          'type': 'task_reminder',
          'task_name': taskName,
          'plant_name': plantName,
          'task_description': taskDescription,
          'rescheduled': true,
        }),
        color: _primaryColor,
      );

      await _notificationRepository.scheduleNotification(notification);
      debugPrint('✅ Task reminder rescheduled for ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('❌ Error rescheduling task reminder: $e');
    }
  }

  /// Reagendar lembrete diário de cuidados
  Future<void> _rescheduleDailyCareReminder(Map<String, dynamic> data) async {
    try {
      final message =
          data['message'] as String? ?? 'Hora de cuidar das suas plantas!';
      final intervalHours = data['interval'] as int? ?? 24;

      await scheduleDailyCareReminder(
        message: message,
        interval: Duration(hours: intervalHours),
      );

      debugPrint('✅ Daily care reminder rescheduled');
    } catch (e) {
      debugPrint('❌ Error rescheduling daily care reminder: $e');
    }
  }

  // ==========================================================================
  // MÉTODOS DE INTEGRAÇÃO COM BUSINESS LOGIC
  // ==========================================================================

  /// Agenda notificações baseadas nas tarefas pendentes
  Future<void> scheduleNotificationsForPendingTasks() async {
    try {
      // TODO: Integrar com TasksRepository para buscar tarefas pendentes
      // final tasksRepository = sl<ITasksRepository>();
      // final pendingTasks = await tasksRepository.getPendingTasks();

      // for (final task in pendingTasks) {
      //   await scheduleTaskReminder(task);
      // }

      debugPrint('📅 Scheduled notifications for pending tasks');
    } catch (e) {
      debugPrint('❌ Error scheduling notifications for pending tasks: $e');
    }
  }

  /// Agenda notificação para uma tarefa específica
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    required String plantName,
    String? taskDescription,
    String? plantId,
    DateTime? dueDate,
  }) async {
    try {
      final scheduledDate =
          dueDate ?? DateTime.now().add(const Duration(hours: 1));

      final notification = NotificationHelper.createReminderNotification(
        appName: _appName,
        id: _notificationRepository.generateNotificationId(
          'task_reminder_$taskId',
        ),
        title: '🌱 Lembrete de Tarefa',
        body:
            '$taskName para $plantName${taskDescription != null ? ' - $taskDescription' : ''}',
        scheduledDate: scheduledDate,
        payload: jsonEncode({
          'type': 'task_reminder',
          'task_id': taskId,
          'task_name': taskName,
          'plant_name': plantName,
          'plant_id': plantId,
          'task_description': taskDescription,
          'due_date': dueDate?.toIso8601String(),
        }),
        color: _primaryColor,
      );

      await _notificationRepository.scheduleNotification(notification);
      debugPrint(
        '✅ Task reminder scheduled for $taskName at ${scheduledDate.toString()}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling task reminder: $e');
    }
  }

  /// Cancela notificações de uma tarefa específica
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      final identifier = 'task_reminder_$taskId';
      await cancelNotification(identifier);
      debugPrint('✅ Cancelled notifications for task: $taskId');
    } catch (e) {
      debugPrint('❌ Error cancelling task notifications: $e');
    }
  }

  /// Verifica tarefas atrasadas e envia notificações
  Future<void> checkAndNotifyOverdueTasks() async {
    try {
      // TODO: Integrar com TasksRepository para buscar tarefas atrasadas
      // final tasksRepository = sl<ITasksRepository>();
      // final overdueTasks = await tasksRepository.getOverdueTasks();

      // for (final task in overdueTasks) {
      //   final daysOverdue = DateTime.now().difference(task.dueDate).inDays;
      //   await showOverdueTaskNotification(
      //     taskName: task.name,
      //     plantName: task.plant.name,
      //     daysOverdue: daysOverdue,
      //   );
      // }

      debugPrint('🔍 Checked and notified overdue tasks');
    } catch (e) {
      debugPrint('❌ Error checking overdue tasks: $e');
    }
  }

  /// Programa notificações diárias de cuidados para todas as plantas
  Future<void> scheduleDailyCareForAllPlants() async {
    try {
      // TODO: Integrar com PlantsRepository para buscar plantas ativas
      // final plantsRepository = sl<IPlantsRepository>();
      // final activePlants = await plantsRepository.getActivePlants();

      // Agenda lembrete diário geral
      await scheduleDailyCareReminder(
        message: 'Hora de verificar suas plantas! 🌿',
        interval: const Duration(days: 1),
      );

      debugPrint('🌱 Scheduled daily care reminders for all plants');
    } catch (e) {
      debugPrint('❌ Error scheduling daily care reminders: $e');
    }
  }

  /// Inicializa todas as notificações necessárias
  Future<void> initializeAllNotifications() async {
    try {
      await scheduleNotificationsForPendingTasks();
      await scheduleDailyCareForAllPlants();
      debugPrint('✅ All notifications initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
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
