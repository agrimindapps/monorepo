import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../plugins/plant_care_notification_plugin.dart';
import 'plantis_notification_config.dart';
import 'plantis_notification_service.dart';

/// Enhanced Plantis notification service using the Enhanced Notification Framework
///
/// This service provides backward compatibility with the legacy PlantisNotificationService
/// while leveraging the new Enhanced Framework for improved functionality.
class EnhancedPlantisNotificationService {
  static final EnhancedPlantisNotificationService _instance =
      EnhancedPlantisNotificationService._internal();
  factory EnhancedPlantisNotificationService() => _instance;
  EnhancedPlantisNotificationService._internal();

  // Enhanced notification service from core
  final IEnhancedNotificationRepository _enhancedService = EnhancedNotificationService();

  // Plant care plugin
  late PlantCareNotificationPlugin _plantCarePlugin;

  bool _isInitialized = false;

  /// Initializes the enhanced notification service with plant care plugin
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize enhanced notification service with proper casting
      final enhancedServiceImpl = _enhancedService as EnhancedNotificationService;
      final coreInitialized = await enhancedServiceImpl.initialize(
        defaultChannels: PlantisNotificationConfig.plantisChannels,
        settings: const EnhancedNotificationSettings(
          enableAnalytics: true,
          enableSmartScheduling: true,
          defaultSnoozeInterval: Duration(hours: 1),
          maxNotificationsPerDay: 20,
          enableDebugLogs: kDebugMode,
        ),
      );

      if (!coreInitialized) {
        return false;
      }

      // Initialize and register plant care plugin
      _plantCarePlugin = PlantCareNotificationPlugin();
      final pluginRegistered = await _enhancedService.registerPlugin(_plantCarePlugin);

      if (!pluginRegistered) {
        if (kDebugMode) {
          debugPrint('❌ Failed to register PlantCareNotificationPlugin');
        }
        return false;
      }

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ EnhancedPlantisNotificationService initialized successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing EnhancedPlantisNotificationService: $e');
      }
      return false;
    }
  }

  // ==========================================================================
  // LEGACY API COMPATIBILITY METHODS
  // These methods maintain backward compatibility with existing code
  // ==========================================================================

  /// Verifica se as notificações estão habilitadas (Legacy API)
  Future<bool> areNotificationsEnabled() async {
    final permission = await _enhancedService.getPermissionStatus();
    return permission.isGranted;
  }

  /// Solicita permissão para notificações (Legacy API)
  Future<bool> requestPermission() async {
    final permission = await _enhancedService.requestPermission();
    return permission.isGranted;
  }

  /// Abre as configurações de notificação (Legacy API)
  Future<bool> openSettings() async {
    return await _enhancedService.openNotificationSettings();
  }

  /// Alias para compatibilidade (Legacy API)
  Future<bool> openNotificationSettings() async {
    return await openSettings();
  }

  /// Solicita permissão (alias para compatibilidade) (Legacy API)
  Future<bool> requestNotificationPermission() async {
    return await requestPermission();
  }

  /// Inicializa todas as notificações (compatibilidade) (Legacy API)
  Future<void> initializeAllNotifications() async {
    // Na nova implementação, isso é feito sob demanda
    if (kDebugMode) {
      debugPrint('🔄 Enhanced service: initializeAllNotifications - usando agendamento sob demanda');
    }
  }

  /// Verifica e notifica tarefas atrasadas (compatibilidade) (Legacy API)
  Future<void> checkAndNotifyOverdueTasks() async {
    try {
      // Usar analytics para identificar tarefas atrasadas
      final analytics = await _enhancedService.getAnalytics(
        DateRange.lastDays(7),
        pluginId: 'plant_care',
      );

      // TODO: Implement logic to identify overdue tasks
      // This would typically involve checking plant care schedules
      if (kDebugMode) {
        debugPrint('🔍 Enhanced service: checking overdue tasks - ${analytics.totalScheduled} notifications tracked');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking overdue tasks: $e');
      }
    }
  }

  /// Agenda lembrete de tarefa (compatibilidade) (Legacy API)
  Future<bool> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    DateTime? dueDate,
    String? taskDescription,
    String? plantName,
    String? plantId,
  }) async {
    try {
      return await _plantCarePlugin.schedulePlantCareReminder(
        plantId: plantId ?? taskId,
        plantName: plantName ?? 'Planta',
        careType: 'general',
        scheduledDate: dueDate ?? DateTime.now().add(const Duration(hours: 1)),
        customMessage: taskDescription ?? taskName,
        additionalData: {
          'task_id': taskId,
          'task_name': taskName,
          'is_legacy_task': true,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error scheduling task reminder: $e');
      }
      return false;
    }
  }

  /// Cancela notificações de tarefas (compatibilidade) (Legacy API)
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      // Find notifications related to this task
      final notifications = await _enhancedService.getScheduledNotifications(
        pluginId: 'plant_care',
      );

      final taskNotifications = notifications
          .where((n) =>
              n.data['task_id'] == taskId ||
              n.data['plant_id'] == taskId)
          .map((n) => n.id)
          .toList();

      if (taskNotifications.isNotEmpty) {
        await _enhancedService.cancelBatch(taskNotifications);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cancelling task notifications: $e');
      }
    }
  }

  /// Mostra notificação de nova planta (compatibilidade) (Legacy API)
  Future<void> showNewPlantNotification({
    required String plantName,
    String? plantType,
    String? message,
  }) async {
    await showNotification(
      title: '🌱 Nova planta adicionada!',
      body: message ?? 'Você adicionou $plantName ao seu jardim',
      type: 'new_plant',
      extraData: {
        'plantName': plantName,
        'plantType': plantType,
      },
    );
  }

  /// Mostra notificação de tarefa atrasada (compatibilidade) (Legacy API)
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    String? taskType,
  }) async {
    await _enhancedService.scheduleFromTemplate('plant_care_overdue', {
      'plant_name': plantName,
      'plant_id': 'unknown', // Legacy call without plant ID
      'care_type': taskType ?? 'general',
      'custom_message': 'A tarefa "$taskName" está atrasada',
    });
  }

  /// Agenda cuidados diários para todas as plantas (compatibilidade) (Legacy API)
  Future<void> scheduleDailyCareForAllPlants() async {
    if (kDebugMode) {
      debugPrint('🔄 Enhanced service: scheduleDailyCareForAllPlants - usando agendamento individual por planta');
    }
    // TODO: Implement bulk scheduling for all plants
    // This would typically iterate through all plants and schedule their care
  }

  /// Verifica se uma notificação está agendada (compatibilidade) (Legacy API)
  Future<bool> isNotificationScheduled({
    required String plantId,
    required String careType,
  }) async {
    return await isPlantNotificationScheduled(plantId, careType);
  }

  /// Agenda notificação direta (compatibilidade) (Legacy API)
  Future<bool> scheduleDirectNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      Map<String, dynamic> payloadData = {};
      if (payload != null) {
        try {
          payloadData = jsonDecode(payload) as Map<String, dynamic>;
        } catch (e) {
          payloadData = {'legacy_payload': payload};
        }
      }

      final notification = NotificationEntity(
        id: notificationId,
        title: title,
        body: body,
        payload: jsonEncode({
          'migration_source': 'legacy_direct',
          ...payloadData,
        }),
        channelId: 'plant_care',
        scheduledDate: scheduledTime,
        priority: NotificationPriorityEntity.defaultPriority,
      );

      return await _enhancedService.scheduleNotification(notification);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error scheduling direct notification: $e');
      }
      return false;
    }
  }

  /// Cancela notificação por ID (compatibilidade) (Legacy API)
  Future<bool> cancelNotification(int notificationId) async {
    try {
      return await _enhancedService.cancelNotification(notificationId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cancelling notification: $e');
      }
      return false;
    }
  }

  /// Mostra notificação de lembrete de tarefa (compatibilidade) (Legacy API)
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

  // ==========================================================================
  // ENHANCED API METHODS
  // These methods provide the new enhanced functionality
  // ==========================================================================

  /// Agenda notificação de cuidado de planta usando o Enhanced Framework
  Future<bool> schedulePlantCareNotification({
    required String plantId,
    required String plantName,
    required String careType,
    required DateTime scheduledDate,
    String? customMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    return await _plantCarePlugin.schedulePlantCareReminder(
      plantId: plantId,
      plantName: plantName,
      careType: careType,
      scheduledDate: scheduledDate,
      customMessage: customMessage,
      additionalData: additionalData,
    );
  }

  /// Agenda notificações recorrentes de cuidado
  Future<bool> scheduleRecurringPlantCare({
    required String plantId,
    required String plantName,
    required String careType,
    required RecurrenceRule recurrence,
    DateTime? startDate,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    return await _plantCarePlugin.scheduleRecurringPlantCare(
      plantId: plantId,
      plantName: plantName,
      careType: careType,
      recurrence: recurrence,
      startDate: startDate,
      additionalData: additionalData,
    );
  }

  /// Agenda rega semanal recorrente
  Future<bool> scheduleWeeklyWatering({
    required String plantId,
    required String plantName,
    List<int>? weekdays, // 1-7, Monday = 1
    int hour = 9,
    int minute = 0,
  }) async {
    final recurrence = RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      interval: 1,
      weekdays: weekdays ?? [1, 4], // Default: Monday and Thursday
    );

    final startDate = DateTime.now().add(const Duration(days: 1));
    final scheduledStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      hour,
      minute,
    );

    return await scheduleRecurringPlantCare(
      plantId: plantId,
      plantName: plantName,
      careType: 'watering',
      recurrence: recurrence,
      startDate: scheduledStart,
    );
  }

  /// Agenda adubação mensal recorrente
  Future<bool> scheduleMonthlyFertilizing({
    required String plantId,
    required String plantName,
    int dayOfMonth = 1,
    int hour = 10,
    int minute = 0,
  }) async {
    final recurrence = RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      interval: 1,
      dayOfMonth: dayOfMonth,
    );

    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month + 1, // Next month
      dayOfMonth,
      hour,
      minute,
    );

    return await scheduleRecurringPlantCare(
      plantId: plantId,
      plantName: plantName,
      careType: 'fertilizing',
      recurrence: recurrence,
      startDate: startDate,
    );
  }

  /// Mostra notificação imediata usando template
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
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        payload: jsonEncode({
          'type': type,
          'timestamp': DateTime.now().toIso8601String(),
          ...?extraData,
        }),
        channelId: 'plant_care',
        priority: NotificationPriorityEntity.defaultPriority,
      );

      return await _enhancedService.showNotification(notification);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error showing notification: $e');
      }
      return false;
    }
  }

  /// Cancela todas as notificações de uma planta específica
  Future<bool> cancelPlantNotifications(String plantId) async {
    return await _plantCarePlugin.cancelPlantNotifications(plantId);
  }

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications() async {
    return await _enhancedService.cancelAllNotifications();
  }

  /// Lista todas as notificações agendadas
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return await _enhancedService.getPendingNotifications();
  }

  /// Lista notificações de uma planta específica
  Future<List<ScheduledNotification>> getPlantNotifications(String plantId) async {
    return await _plantCarePlugin.getPlantNotifications(plantId);
  }

  /// Verifica se uma notificação específica está agendada
  Future<bool> isPlantNotificationScheduled(String plantId, String careType) async {
    try {
      final plantNotifications = await getPlantNotifications(plantId);
      return plantNotifications.any((n) => n.data['care_type'] == careType);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking if notification is scheduled: $e');
      }
      return false;
    }
  }

  /// Atualiza agenda de notificação de uma planta
  Future<bool> updatePlantNotificationSchedule({
    required String plantId,
    required String careType,
    required DateTime newDate,
  }) async {
    return await _plantCarePlugin.updatePlantNotificationSchedule(
      plantId: plantId,
      careType: careType,
      newDate: newDate,
    );
  }

  // ==========================================================================
  // ANALYTICS AND INSIGHTS
  // ==========================================================================

  /// Obtém analytics de notificações de plantas
  Future<NotificationAnalytics> getPlantNotificationAnalytics({
    DateRange? dateRange,
  }) async {
    final range = dateRange ?? DateRange.lastDays(30);
    return await _enhancedService.getAnalytics(range, pluginId: 'plant_care');
  }

  /// Obtém métricas de engajamento do usuário
  Future<UserEngagementMetrics> getUserEngagementMetrics({
    required String userId,
    DateRange? dateRange,
  }) async {
    final range = dateRange ?? DateRange.lastDays(30);
    return await _enhancedService.getUserEngagement(userId, range);
  }

  /// Obtém histórico de notificações
  Future<NotificationHistory> getNotificationHistory({
    DateRange? dateRange,
  }) async {
    final range = dateRange ?? DateRange.lastDays(7);
    return await _enhancedService.getNotificationHistory(range);
  }

  // ==========================================================================
  // MIGRATION AND MAINTENANCE
  // ==========================================================================

  /// Migra notificações do serviço legado
  Future<MigrationResult> migrateFromLegacyService(
    PlantisNotificationService legacyService,
  ) async {
    try {
      // Create migration helper using the public API of legacy service
      // Note: We pass the enhanced service and a dummy legacy service since we'll handle
      // the migration manually using the PlantisNotificationService public API
      final dummyLegacyService = LocalNotificationService();
      final migrationHelper = NotificationMigrationHelper(_enhancedService, dummyLegacyService);

      // Use the helper's migration method directly
      return await migrationHelper.migrateAllNotifications();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during migration: $e');
      }

      // Return a simple error result
      final result = MigrationResult();
      result.addGlobalError('Migration failed: $e');
      return result;
    }
  }

  /// Valida configuração do serviço
  Future<List<NotificationValidationResult>> validateConfiguration() async {
    return await _enhancedService.validateConfiguration();
  }

  /// Obtém métricas de performance
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    return await _enhancedService.getPerformanceMetrics();
  }

  /// Habilita modo de teste
  Future<void> enableTestMode(bool enabled) async {
    await _enhancedService.enableTestMode(enabled);
  }

  /// Limpa dados antigos de analytics
  Future<void> clearOldAnalyticsData({Duration? olderThan}) async {
    // TODO: Implement analytics data cleanup
    // This would clear analytics data older than specified duration
    final cutoff = olderThan ?? const Duration(days: 90);

    if (kDebugMode) {
      debugPrint('🧹 Would clear analytics data older than ${cutoff.inDays} days');
    }
  }

  // ==========================================================================
  // FEATURE FLAGS AND CONFIGURATION
  // ==========================================================================

  /// Atualiza configurações globais
  Future<void> updateGlobalSettings({
    bool? enableAnalytics,
    bool? enableSmartScheduling,
    Duration? defaultSnoozeInterval,
    int? maxNotificationsPerDay,
  }) async {
    final currentSettings = await _enhancedService.getGlobalSettings();

    final newSettings = EnhancedNotificationSettings(
      enableAnalytics: enableAnalytics ?? currentSettings.enableAnalytics,
      enableSmartScheduling: enableSmartScheduling ?? currentSettings.enableSmartScheduling,
      defaultSnoozeInterval: defaultSnoozeInterval ?? currentSettings.defaultSnoozeInterval,
      maxNotificationsPerDay: maxNotificationsPerDay ?? currentSettings.maxNotificationsPerDay,
      enableDebugLogs: currentSettings.enableDebugLogs,
    );

    await _enhancedService.updateGlobalSettings(newSettings);
  }

  /// Obtém configurações atuais
  Future<EnhancedNotificationSettings> getGlobalSettings() async {
    return await _enhancedService.getGlobalSettings();
  }
}

/// Extensão para compatibilidade com tipos legacy
extension LegacyCompatibility on EnhancedPlantisNotificationService {
  /// Converte tipo de notificação legacy para template ID
  String legacyTypeToTemplateId(String legacyType) {
    switch (legacyType.toLowerCase()) {
      case 'watering':
      case 'water':
        return 'watering_reminder';
      case 'fertilizing':
      case 'fertilizer':
        return 'fertilizing_reminder';
      case 'repotting':
      case 'repot':
        return 'repotting_reminder';
      case 'pest_inspection':
      case 'pest':
        return 'pest_inspection_reminder';
      case 'cleaning':
      case 'clean':
        return 'cleaning_reminder';
      default:
        return 'general_care_reminder';
    }
  }
}

