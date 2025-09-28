import 'package:core/core.dart';
import 'package:flutter/foundation.dart';


/// Plant care specific notification plugin for the Enhanced Notification Framework
class PlantCareNotificationPlugin extends NotificationPlugin {
  late IEnhancedNotificationRepository _repository;

  @override
  String get id => 'plant_care';

  @override
  String get name => 'Plant Care Notifications';

  @override
  String get version => '1.0.0';

  @override
  List<String> get supportedTemplates => [
    'watering_reminder',
    'fertilizing_reminder',
    'repotting_reminder',
    'pest_inspection_reminder',
    'cleaning_reminder',
    'general_care_reminder',
    'plant_care_overdue',
    'plant_health_alert',
    'watering_schedule_update',
    'seasonal_care_tip',
  ];

  @override
  Future<void> onRegister(IEnhancedNotificationRepository repository) async {
    _repository = repository;

    // Register all plant care templates
    await _registerPlantCareTemplates();

    if (kDebugMode) {
      debugPrint('🌱 PlantCareNotificationPlugin registered successfully');
    }
  }

  @override
  Future<void> onUnregister() async {
    // Cleanup any plugin-specific resources
    if (kDebugMode) {
      debugPrint('🌱 PlantCareNotificationPlugin unregistered');
    }
  }

  @override
  Future<NotificationRequest?> processNotificationData(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Validate required plant care data
      if (!_validatePlantCareData(templateId, data)) {
        return null;
      }

      // Process template based on type
      switch (templateId) {
        case 'watering_reminder':
          return _createWateringReminder(data);
        case 'fertilizing_reminder':
          return _createFertilizingReminder(data);
        case 'repotting_reminder':
          return _createRepottingReminder(data);
        case 'pest_inspection_reminder':
          return _createPestInspectionReminder(data);
        case 'cleaning_reminder':
          return _createCleaningReminder(data);
        case 'general_care_reminder':
          return _createGeneralCareReminder(data);
        case 'plant_care_overdue':
          return _createOverdueCareNotification(data);
        case 'plant_health_alert':
          return _createHealthAlert(data);
        case 'watering_schedule_update':
          return _createScheduleUpdate(data);
        case 'seasonal_care_tip':
          return _createSeasonalTip(data);
        default:
          return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error processing plant care notification data: $e');
      }
      return null;
    }
  }

  @override
  Future<void> handleAction(String action, Map<String, dynamic> params) async {
    try {
      switch (action) {
        case 'notification_tapped':
          await _handleNotificationTap(params);
          break;
        case 'mark_watered':
          await _handleMarkWatered(params);
          break;
        case 'mark_fertilized':
          await _handleMarkFertilized(params);
          break;
        case 'snooze_reminder':
          await _handleSnoozeReminder(params);
          break;
        case 'reschedule_care':
          await _handleRescheduleCare(params);
          break;
        case 'view_plant_details':
          await _handleViewPlantDetails(params);
          break;
        case 'dismiss_notification':
          await _handleDismissNotification(params);
          break;
        default:
          if (kDebugMode) {
            debugPrint('⚠️ Unknown action: $action');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling plant care action: $e');
      }
    }
  }

  @override
  Future<List<String>> validateConfiguration() async {
    final errors = <String>[];

    // Validate that all templates are registered
    for (final templateId in supportedTemplates) {
      final template = await _repository.getTemplate(templateId);
      if (template == null) {
        errors.add('Template not registered: $templateId');
      }
    }

    // Validate repository is available
    try {
      await _repository.getGlobalSettings();
    } catch (e) {
      errors.add('Repository not available: $e');
    }

    return errors;
  }

  // Public API Methods

  /// Schedules a plant care reminder
  Future<bool> schedulePlantCareReminder({
    required String plantId,
    required String plantName,
    required String careType,
    required DateTime scheduledDate,
    String? customMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final templateId = _getCareTypeTemplate(careType);
      final data = {
        'plant_id': plantId,
        'plant_name': plantName,
        'care_type': careType,
        'scheduled_date': scheduledDate.toIso8601String(),
        'custom_message': customMessage,
        ...?additionalData,
      };

      return await _repository.scheduleFromTemplate(templateId, data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error scheduling plant care reminder: $e');
      }
      return false;
    }
  }

  /// Schedules recurring plant care notifications
  Future<bool> scheduleRecurringPlantCare({
    required String plantId,
    required String plantName,
    required String careType,
    required RecurrenceRule recurrence,
    DateTime? startDate,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final templateId = _getCareTypeTemplate(careType);
      final baseRequest = NotificationRequest(
        title: _getCareTypeTitle(careType),
        body: 'É hora de cuidar da sua $plantName',
        data: {
          'plant_id': plantId,
          'plant_name': plantName,
          'care_type': careType,
          ...?additionalData,
        },
        templateId: templateId,
        pluginId: id,
        channelId: 'plant_care',
      );

      final recurringRequest = RecurringNotificationRequest(
        baseNotification: baseRequest,
        recurrenceRule: recurrence,
        startDate: startDate ?? DateTime.now(),
      );

      return await _repository.scheduleRecurring(recurringRequest);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error scheduling recurring plant care: $e');
      }
      return false;
    }
  }

  /// Cancels all notifications for a specific plant
  Future<bool> cancelPlantNotifications(String plantId) async {
    try {
      final scheduledNotifications = await _repository
          .getScheduledNotifications(pluginId: id);

      final plantNotifications =
          scheduledNotifications
              .where((n) => n.data['plant_id'] == plantId)
              .map((n) => n.id)
              .toList();

      if (plantNotifications.isEmpty) {
        return true;
      }

      final result = await _repository.cancelBatch(plantNotifications);
      return result.successCount == plantNotifications.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cancelling plant notifications: $e');
      }
      return false;
    }
  }

  /// Gets all scheduled notifications for a plant
  Future<List<ScheduledNotification>> getPlantNotifications(
    String plantId,
  ) async {
    try {
      final scheduledNotifications = await _repository
          .getScheduledNotifications(pluginId: id);

      return scheduledNotifications
          .where((n) => n.data['plant_id'] == plantId)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting plant notifications: $e');
      }
      return [];
    }
  }

  /// Updates notification schedule for a plant
  Future<bool> updatePlantNotificationSchedule({
    required String plantId,
    required String careType,
    required DateTime newDate,
  }) async {
    try {
      final scheduledNotifications = await getPlantNotifications(plantId);
      final notification = scheduledNotifications.firstWhere(
        (n) => n.data['care_type'] == careType,
        orElse: () => throw StateError('Notification not found'),
      );

      final update = NotificationUpdate(
        id: notification.id,
        scheduledDate: newDate,
      );

      return await _repository.updateScheduledNotification(
        notification.id,
        update,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating plant notification schedule: $e');
      }
      return false;
    }
  }

  // Private Helper Methods

  Future<void> _registerPlantCareTemplates() async {
    final templates = [
      // Watering reminder template
      NotificationTemplate(
        id: 'watering_reminder',
        title: '💧 {{plant_name}} precisa de água!',
        body: 'Sua {{plant_name}} está com sede. {{custom_message}}',
        channelId: 'plant_care',
        priority: NotificationPriorityEntity.high,
        pluginId: id,
        requiredFields: ['plant_name', 'plant_id'],
        defaultData: {'custom_message': 'Que tal dar uma regadinha?'},
        actions: [
          const NotificationAction(
            id: 'mark_watered',
            title: 'Marquei como regada',
          ),
          const NotificationAction(
            id: 'snooze_reminder',
            title: 'Lembrar mais tarde',
          ),
          const NotificationAction(
            id: 'view_plant_details',
            title: 'Ver detalhes',
          ),
        ],
      ),

      // Fertilizing reminder template
      NotificationTemplate(
        id: 'fertilizing_reminder',
        title: '🌱 Hora de adubar {{plant_name}}!',
        body: 'Sua {{plant_name}} precisa de nutrientes. {{custom_message}}',
        channelId: 'plant_care',
        priority: NotificationPriorityEntity.defaultPriority,
        pluginId: id,
        requiredFields: ['plant_name', 'plant_id'],
        defaultData: {'custom_message': 'Vamos nutrir essa belezinha?'},
        actions: [
          const NotificationAction(
            id: 'mark_fertilized',
            title: 'Marquei como adubada',
          ),
          const NotificationAction(
            id: 'snooze_reminder',
            title: 'Lembrar mais tarde',
          ),
          const NotificationAction(
            id: 'view_plant_details',
            title: 'Ver detalhes',
          ),
        ],
      ),

      // Repotting reminder template
      NotificationTemplate(
        id: 'repotting_reminder',
        title: '🪴 {{plant_name}} precisa de vaso novo!',
        body:
            'Sua {{plant_name}} cresceu e precisa de mais espaço. {{custom_message}}',
        channelId: 'plant_care',
        priority: NotificationPriorityEntity.defaultPriority,
        pluginId: id,
        requiredFields: ['plant_name', 'plant_id'],
        defaultData: {
          'custom_message': 'Hora de dar mais espaço para crescer!',
        },
        actions: [
          const NotificationAction(id: 'reschedule_care', title: 'Reagendar'),
          const NotificationAction(
            id: 'view_plant_details',
            title: 'Ver detalhes',
          ),
        ],
      ),

      // Pest inspection reminder template
      NotificationTemplate(
        id: 'pest_inspection_reminder',
        title: '🔍 Verificar {{plant_name}}',
        body:
            'Hora de verificar se {{plant_name}} está saudável. {{custom_message}}',
        channelId: 'plant_care',
        priority: NotificationPriorityEntity.defaultPriority,
        pluginId: id,
        requiredFields: ['plant_name', 'plant_id'],
        defaultData: {'custom_message': 'Vamos verificar pragas e doenças?'},
        actions: [
          const NotificationAction(
            id: 'dismiss_notification',
            title: 'Verificado',
          ),
          const NotificationAction(
            id: 'view_plant_details',
            title: 'Ver detalhes',
          ),
        ],
      ),

      // General care reminder template
      NotificationTemplate(
        id: 'general_care_reminder',
        title: '🌿 Cuidar de {{plant_name}}',
        body: '{{custom_message}}',
        channelId: 'plant_care',
        priority: NotificationPriorityEntity.defaultPriority,
        pluginId: id,
        requiredFields: ['plant_name', 'plant_id', 'custom_message'],
        actions: [
          const NotificationAction(
            id: 'dismiss_notification',
            title: 'Concluído',
          ),
          const NotificationAction(
            id: 'snooze_reminder',
            title: 'Lembrar mais tarde',
          ),
          const NotificationAction(
            id: 'view_plant_details',
            title: 'Ver detalhes',
          ),
        ],
      ),

      // Overdue care notification template
      NotificationTemplate(
        id: 'plant_care_overdue',
        title: '⏰ {{plant_name}} precisa de atenção!',
        body:
            'A tarefa {{care_type}} está atrasada para {{plant_name}}. {{custom_message}}',
        channelId: 'plant_care_urgent',
        priority: NotificationPriorityEntity.high,
        pluginId: id,
        requiredFields: ['plant_name', 'plant_id', 'care_type'],
        defaultData: {'custom_message': 'Vamos cuidar dela agora?'},
        actions: [
          const NotificationAction(
            id: 'mark_watered',
            title: 'Marcar como feito',
          ),
          const NotificationAction(
            id: 'view_plant_details',
            title: 'Ver detalhes',
          ),
        ],
      ),
    ];

    // Register all templates
    for (final template in templates) {
      await _repository.registerTemplate(template);
    }

    if (kDebugMode) {
      debugPrint('🌱 Registered ${templates.length} plant care templates');
    }
  }

  bool _validatePlantCareData(String templateId, Map<String, dynamic> data) {
    // Common required fields
    if (!data.containsKey('plant_id') || !data.containsKey('plant_name')) {
      return false;
    }

    // Template-specific validations
    switch (templateId) {
      case 'plant_care_overdue':
        return data.containsKey('care_type');
      case 'general_care_reminder':
        return data.containsKey('custom_message');
      default:
        return true;
    }
  }

  NotificationRequest _createWateringReminder(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '💧 ${data['plant_name'] as String} precisa de água!',
      body:
          (data['custom_message'] as String?) ??
          'Sua ${data['plant_name'] as String} está com sede.',
      data: data,
      actions: [
        const NotificationAction(
          id: 'mark_watered',
          title: 'Marquei como regada',
        ),
        const NotificationAction(
          id: 'snooze_reminder',
          title: 'Lembrar mais tarde',
        ),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.high,
      templateId: 'watering_reminder',
      pluginId: id,
    );
  }

  NotificationRequest _createFertilizingReminder(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '🌱 Hora de adubar ${data['plant_name'] as String}!',
      body:
          (data['custom_message'] as String?) ??
          'Sua ${data['plant_name'] as String} precisa de nutrientes.',
      data: data,
      actions: [
        const NotificationAction(
          id: 'mark_fertilized',
          title: 'Marquei como adubada',
        ),
        const NotificationAction(
          id: 'snooze_reminder',
          title: 'Lembrar mais tarde',
        ),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.defaultPriority,
      templateId: 'fertilizing_reminder',
      pluginId: id,
    );
  }

  NotificationRequest _createRepottingReminder(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '🪴 ${data['plant_name'] as String} precisa de vaso novo!',
      body:
          (data['custom_message'] as String?) ??
          'Sua ${data['plant_name'] as String} cresceu e precisa de mais espaço.',
      data: data,
      actions: [
        const NotificationAction(id: 'reschedule_care', title: 'Reagendar'),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.defaultPriority,
      templateId: 'repotting_reminder',
      pluginId: id,
    );
  }

  NotificationRequest _createPestInspectionReminder(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '🔍 Verificar ${data['plant_name'] as String}',
      body:
          (data['custom_message'] as String?) ??
          'Hora de verificar se ${data['plant_name'] as String} está saudável.',
      data: data,
      actions: [
        const NotificationAction(
          id: 'dismiss_notification',
          title: 'Verificado',
        ),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.defaultPriority,
      templateId: 'pest_inspection_reminder',
      pluginId: id,
    );
  }

  NotificationRequest _createCleaningReminder(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '🧹 Limpar ${data['plant_name'] as String}',
      body:
          (data['custom_message'] as String?) ??
          'Hora de limpar as folhas da ${data['plant_name'] as String}.',
      data: data,
      actions: [
        const NotificationAction(id: 'dismiss_notification', title: 'Limpei'),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.low,
      templateId: 'cleaning_reminder',
      pluginId: id,
    );
  }

  NotificationRequest _createGeneralCareReminder(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '🌿 Cuidar de ${data['plant_name'] as String}',
      body:
          (data['custom_message'] as String?) ??
          'Hora de cuidar da ${data['plant_name'] as String}.',
      data: data,
      actions: [
        const NotificationAction(
          id: 'dismiss_notification',
          title: 'Concluído',
        ),
        const NotificationAction(
          id: 'snooze_reminder',
          title: 'Lembrar mais tarde',
        ),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.defaultPriority,
      templateId: 'general_care_reminder',
      pluginId: id,
    );
  }

  NotificationRequest _createOverdueCareNotification(
    Map<String, dynamic> data,
  ) {
    final careType = data['care_type'] as String;
    final careTypeDisplay = _getCareTypeDisplay(careType);

    return NotificationRequest(
      title: '⏰ ${data['plant_name'] as String} precisa de atenção!',
      body:
          (data['custom_message'] as String?) ??
          'A tarefa de $careTypeDisplay está atrasada para ${data['plant_name'] as String}.',
      data: data,
      actions: [
        const NotificationAction(
          id: 'mark_watered',
          title: 'Marcar como feito',
        ),
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
      ],
      channelId: 'plant_care_urgent',
      priority: NotificationPriorityEntity.high,
      templateId: 'plant_care_overdue',
      pluginId: id,
    );
  }

  NotificationRequest _createHealthAlert(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '🚨 Alerta de saúde - ${data['plant_name'] as String}',
      body:
          (data['custom_message'] as String?) ??
          'Sua ${data['plant_name'] as String} pode estar com problemas de saúde.',
      data: data,
      actions: [
        const NotificationAction(
          id: 'view_plant_details',
          title: 'Ver detalhes',
        ),
        const NotificationAction(id: 'dismiss_notification', title: 'OK'),
      ],
      channelId: 'plant_health_alerts',
      priority: NotificationPriorityEntity.max,
      templateId: 'plant_health_alert',
      pluginId: id,
    );
  }

  NotificationRequest _createScheduleUpdate(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '📅 Agenda atualizada - ${data['plant_name'] as String}',
      body:
          (data['custom_message'] as String?) ??
          'A agenda de cuidados da ${data['plant_name'] as String} foi atualizada.',
      data: data,
      actions: [
        const NotificationAction(id: 'view_plant_details', title: 'Ver agenda'),
        const NotificationAction(id: 'dismiss_notification', title: 'OK'),
      ],
      channelId: 'plant_care',
      priority: NotificationPriorityEntity.low,
      templateId: 'watering_schedule_update',
      pluginId: id,
    );
  }

  NotificationRequest _createSeasonalTip(Map<String, dynamic> data) {
    return NotificationRequest(
      title: '💡 Dica da estação',
      body:
          (data['custom_message'] as String?) ??
          'Dica especial para ${data['plant_name'] as String} nesta época do ano.',
      data: data,
      actions: [
        const NotificationAction(id: 'dismiss_notification', title: 'Entendi'),
      ],
      channelId: 'plant_tips',
      priority: NotificationPriorityEntity.low,
      templateId: 'seasonal_care_tip',
      pluginId: id,
    );
  }

  String _getCareTypeTemplate(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return 'watering_reminder';
      case 'fertilizing':
        return 'fertilizing_reminder';
      case 'repotting':
        return 'repotting_reminder';
      case 'pest_inspection':
        return 'pest_inspection_reminder';
      case 'cleaning':
        return 'cleaning_reminder';
      default:
        return 'general_care_reminder';
    }
  }

  String _getCareTypeTitle(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return '💧 Hora de regar!';
      case 'fertilizing':
        return '🌱 Hora de adubar!';
      case 'repotting':
        return '🪴 Trocar vaso';
      case 'pest_inspection':
        return '🔍 Verificar pragas';
      case 'cleaning':
        return '🧹 Limpar folhas';
      default:
        return '🌿 Cuidar da planta';
    }
  }

  String _getCareTypeDisplay(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return 'rega';
      case 'fertilizing':
        return 'adubação';
      case 'repotting':
        return 'replantio';
      case 'pest_inspection':
        return 'verificação de pragas';
      case 'cleaning':
        return 'limpeza';
      default:
        return 'cuidado geral';
    }
  }

  // Action Handlers

  Future<void> _handleNotificationTap(Map<String, dynamic> params) async {
    // TODO: Implement navigation to plant details
    // This would typically navigate to the specific plant's detail page
    if (kDebugMode) {
      debugPrint('🌱 Plant notification tapped: ${params['plant_id']}');
    }
  }

  Future<void> _handleMarkWatered(Map<String, dynamic> params) async {
    // TODO: Implement marking plant as watered
    // This would typically update the plant's last watered date
    if (kDebugMode) {
      debugPrint('🌱 Marked plant as watered: ${params['plant_id']}');
    }
  }

  Future<void> _handleMarkFertilized(Map<String, dynamic> params) async {
    // TODO: Implement marking plant as fertilized
    // This would typically update the plant's last fertilized date
    if (kDebugMode) {
      debugPrint('🌱 Marked plant as fertilized: ${params['plant_id']}');
    }
  }

  Future<void> _handleSnoozeReminder(Map<String, dynamic> params) async {
    try {
      // Reschedule notification for 1 hour later
      final plantId = params['plant_id'] as String;
      final careType = params['care_type'] as String;
      final newDate = DateTime.now().add(const Duration(hours: 1));

      await updatePlantNotificationSchedule(
        plantId: plantId,
        careType: careType,
        newDate: newDate,
      );

      if (kDebugMode) {
        debugPrint('🌱 Snoozed plant reminder: $plantId for 1 hour');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error snoozing reminder: $e');
      }
    }
  }

  Future<void> _handleRescheduleCare(Map<String, dynamic> params) async {
    // TODO: Implement rescheduling care task
    // This would typically open a date picker to reschedule
    if (kDebugMode) {
      debugPrint('🌱 Reschedule care requested: ${params['plant_id']}');
    }
  }

  Future<void> _handleViewPlantDetails(Map<String, dynamic> params) async {
    // TODO: Implement navigation to plant details
    // This would navigate to the plant's detail page
    if (kDebugMode) {
      debugPrint('🌱 View plant details requested: ${params['plant_id']}');
    }
  }

  Future<void> _handleDismissNotification(Map<String, dynamic> params) async {
    // Notification is automatically dismissed, just log the action
    if (kDebugMode) {
      debugPrint('🌱 Plant notification dismissed: ${params['plant_id']}');
    }
  }
}
