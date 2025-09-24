import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import 'enhanced_plantis_notification_service.dart';
import 'plantis_notification_service.dart';

/// Backward-compatible wrapper for PlantisNotificationService
///
/// This service acts as a drop-in replacement for the legacy PlantisNotificationService
/// while using the Enhanced Notification Framework under the hood.
///
/// Usage: Simply replace PlantisNotificationService() with PlantisNotificationServiceV2()
/// in your dependency injection or service locator setup.
class PlantisNotificationServiceV2 implements PlantisNotificationService {
  static final PlantisNotificationServiceV2 _instance =
      PlantisNotificationServiceV2._internal();
  factory PlantisNotificationServiceV2() => _instance;
  PlantisNotificationServiceV2._internal();

  // Enhanced service that does the actual work
  final EnhancedPlantisNotificationService _enhancedService =
      EnhancedPlantisNotificationService();

  // Feature flag to control migration
  bool _useEnhancedFramework = true;

  // Legacy service for fallback (if needed)
  PlantisNotificationService? _legacyService;

  /// Configure whether to use enhanced framework or legacy service
  void setUseEnhancedFramework(bool useEnhanced) {
    _useEnhancedFramework = useEnhanced;

    if (!useEnhanced && _legacyService == null) {
      _legacyService = PlantisNotificationService();
    }
  }

  @override
  Future<bool> initialize() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.initialize();
    } else {
      return await _legacyService!.initialize();
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.areNotificationsEnabled();
    } else {
      return await _legacyService!.areNotificationsEnabled();
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.requestPermission();
    } else {
      return await _legacyService!.requestPermission();
    }
  }

  @override
  Future<bool> openSettings() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.openSettings();
    } else {
      return await _legacyService!.openSettings();
    }
  }

  @override
  Future<bool> openNotificationSettings() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.openNotificationSettings();
    } else {
      return await _legacyService!.openNotificationSettings();
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.requestNotificationPermission();
    } else {
      return await _legacyService!.requestNotificationPermission();
    }
  }

  @override
  Future<void> initializeAllNotifications() async {
    if (_useEnhancedFramework) {
      await _enhancedService.initializeAllNotifications();
    } else {
      await _legacyService!.initializeAllNotifications();
    }
  }

  @override
  Future<void> checkAndNotifyOverdueTasks() async {
    if (_useEnhancedFramework) {
      await _enhancedService.checkAndNotifyOverdueTasks();
    } else {
      await _legacyService!.checkAndNotifyOverdueTasks();
    }
  }

  @override
  Future<bool> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    DateTime? dueDate,
    String? taskDescription,
    String? plantName,
    String? plantId,
  }) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.scheduleTaskReminder(
        taskId: taskId,
        taskName: taskName,
        dueDate: dueDate,
        taskDescription: taskDescription,
        plantName: plantName,
        plantId: plantId,
      );
    } else {
      return await _legacyService!.scheduleTaskReminder(
        taskId: taskId,
        taskName: taskName,
        dueDate: dueDate,
        taskDescription: taskDescription,
        plantName: plantName,
        plantId: plantId,
      );
    }
  }

  @override
  Future<void> cancelTaskNotifications(String taskId) async {
    if (_useEnhancedFramework) {
      await _enhancedService.cancelTaskNotifications(taskId);
    } else {
      await _legacyService!.cancelTaskNotifications(taskId);
    }
  }

  @override
  Future<void> showNewPlantNotification({
    required String plantName,
    String? plantType,
    String? message,
  }) async {
    if (_useEnhancedFramework) {
      await _enhancedService.showNewPlantNotification(
        plantName: plantName,
        plantType: plantType,
        message: message,
      );
    } else {
      await _legacyService!.showNewPlantNotification(
        plantName: plantName,
        plantType: plantType,
        message: message,
      );
    }
  }

  @override
  Future<void> showOverdueTaskNotification({
    required String taskName,
    required String plantName,
    String? taskType,
  }) async {
    if (_useEnhancedFramework) {
      await _enhancedService.showOverdueTaskNotification(
        taskName: taskName,
        plantName: plantName,
        taskType: taskType,
      );
    } else {
      await _legacyService!.showOverdueTaskNotification(
        taskName: taskName,
        plantName: plantName,
        taskType: taskType,
      );
    }
  }

  @override
  Future<void> scheduleDailyCareForAllPlants() async {
    if (_useEnhancedFramework) {
      await _enhancedService.scheduleDailyCareForAllPlants();
    } else {
      await _legacyService!.scheduleDailyCareForAllPlants();
    }
  }

  @override
  Future<bool> isNotificationScheduled({
    required String plantId,
    required String careType,
  }) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.isNotificationScheduled(
        plantId: plantId,
        careType: careType,
      );
    } else {
      return await _legacyService!.isNotificationScheduled(
        plantId: plantId,
        careType: careType,
      );
    }
  }

  @override
  Future<bool> scheduleDirectNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.scheduleDirectNotification(
        notificationId: notificationId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      );
    } else {
      return await _legacyService!.scheduleDirectNotification(
        notificationId: notificationId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      );
    }
  }

  @override
  Future<bool> cancelNotification(int notificationId) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.cancelNotification(notificationId);
    } else {
      return await _legacyService!.cancelNotification(notificationId);
    }
  }

  @override
  Future<void> showTaskReminderNotification({
    required String taskName,
    required String plantName,
    String? taskType,
  }) async {
    if (_useEnhancedFramework) {
      await _enhancedService.showTaskReminderNotification(
        taskName: taskName,
        plantName: plantName,
        taskType: taskType,
      );
    } else {
      await _legacyService!.showTaskReminderNotification(
        taskName: taskName,
        plantName: plantName,
        taskType: taskType,
      );
    }
  }

  @override
  Future<bool> schedulePlantCareNotification({
    required String plantId,
    required String plantName,
    required String careType,
    required DateTime scheduledDate,
    String? customMessage,
  }) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.schedulePlantCareNotification(
        plantId: plantId,
        plantName: plantName,
        careType: careType,
        scheduledDate: scheduledDate,
        customMessage: customMessage,
      );
    } else {
      return await _legacyService!.schedulePlantCareNotification(
        plantId: plantId,
        plantName: plantName,
        careType: careType,
        scheduledDate: scheduledDate,
        customMessage: customMessage,
      );
    }
  }

  @override
  Future<bool> showNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? extraData,
  }) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.showNotification(
        title: title,
        body: body,
        type: type,
        extraData: extraData,
      );
    } else {
      return await _legacyService!.showNotification(
        title: title,
        body: body,
        type: type,
        extraData: extraData,
      );
    }
  }

  @override
  Future<bool> cancelPlantNotification(String plantId, String careType) async {
    if (_useEnhancedFramework) {
      // Enhanced service has a different method signature
      return await _enhancedService.updatePlantNotificationSchedule(
        plantId: plantId,
        careType: careType,
        newDate: DateTime.now().subtract(const Duration(days: 1)), // Cancel by setting to past
      );
    } else {
      return await _legacyService!.cancelPlantNotification(plantId, careType);
    }
  }

  @override
  Future<bool> cancelAllPlantNotifications(String plantId) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.cancelPlantNotifications(plantId);
    } else {
      return await _legacyService!.cancelAllPlantNotifications(plantId);
    }
  }

  @override
  Future<bool> cancelAllNotifications() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.cancelAllNotifications();
    } else {
      return await _legacyService!.cancelAllNotifications();
    }
  }

  @override
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.getPendingNotifications();
    } else {
      return await _legacyService!.getPendingNotifications();
    }
  }

  @override
  Future<List<PendingNotificationEntity>> getPlantNotifications(String plantId) async {
    if (_useEnhancedFramework) {
      // Convert ScheduledNotification to PendingNotificationEntity for compatibility
      final scheduledNotifications = await _enhancedService.getPlantNotifications(plantId);

      return scheduledNotifications.map((scheduled) => PendingNotificationEntity(
        id: scheduled.id,
        title: scheduled.title,
        body: scheduled.body,
        payload: jsonEncode(scheduled.data),
      )).toList();
    } else {
      return await _legacyService!.getPlantNotifications(plantId);
    }
  }

  @override
  Future<bool> isPlantNotificationScheduled(String plantId, String careType) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.isPlantNotificationScheduled(plantId, careType);
    } else {
      return await _legacyService!.isPlantNotificationScheduled(plantId, careType);
    }
  }

  // Enhanced-only methods (not in legacy interface)

  /// Migrates from legacy service to enhanced framework
  Future<MigrationResult> migrateFromLegacy() async {
    if (_legacyService == null) {
      _legacyService = PlantisNotificationService();
      await _legacyService!.initialize();
    }

    final result = await _enhancedService.migrateFromLegacyService(_legacyService!);

    if (result.isSuccessful) {
      _useEnhancedFramework = true;
      if (kDebugMode) {
        debugPrint('✅ Successfully migrated to Enhanced Framework: ${result.summary}');
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ Migration failed: ${result.summary}');
        for (final error in result.globalErrors) {
          debugPrint('   - $error');
        }
      }
    }

    return result;
  }

  /// Gets enhanced analytics (only available with enhanced framework)
  Future<NotificationAnalytics?> getAnalytics({DateRange? dateRange}) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.getPlantNotificationAnalytics(dateRange: dateRange);
    }
    return null;
  }

  /// Schedules recurring plant care (only available with enhanced framework)
  Future<bool> scheduleRecurringCare({
    required String plantId,
    required String plantName,
    required String careType,
    required RecurrenceRule recurrence,
    DateTime? startDate,
  }) async {
    if (_useEnhancedFramework) {
      return await _enhancedService.scheduleRecurringPlantCare(
        plantId: plantId,
        plantName: plantName,
        careType: careType,
        recurrence: recurrence,
        startDate: startDate,
      );
    }
    return false;
  }

  /// Validates configuration (only available with enhanced framework)
  Future<List<NotificationValidationResult>> validateConfiguration() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.validateConfiguration();
    }
    return [];
  }

  /// Gets performance metrics (only available with enhanced framework)
  Future<PerformanceMetrics?> getPerformanceMetrics() async {
    if (_useEnhancedFramework) {
      return await _enhancedService.getPerformanceMetrics();
    }
    return null;
  }

  // Feature flags and configuration

  /// Returns true if using enhanced framework
  bool get isUsingEnhancedFramework => _useEnhancedFramework;

  /// Returns enhanced service instance (only if using enhanced framework)
  EnhancedPlantisNotificationService? get enhancedService =>
      _useEnhancedFramework ? _enhancedService : null;

  /// Returns legacy service instance (only if available)
  PlantisNotificationService? get legacyService => _legacyService;

  // Accessing properties that don't exist in the interface but might be used
  // This uses noSuchMethod to handle legacy code that might access private fields

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Log attempted access to unknown methods/properties
    if (kDebugMode) {
      debugPrint('⚠️ Attempted to access ${invocation.memberName} on PlantisNotificationServiceV2');
      debugPrint('   This might be legacy code accessing private fields.');
    }

    // Try to delegate to legacy service if it exists
    if (!_useEnhancedFramework && _legacyService != null) {
      try {
        return _legacyService!.noSuchMethod(invocation);
      } catch (e) {
        // Legacy service also doesn't have this method
      }
    }

    // Default noSuchMethod behavior
    return super.noSuchMethod(invocation);
  }

  // Internal accessor used by legacy code (if needed)
  INotificationRepository get _notificationService {
    if (_useEnhancedFramework) {
      // Return the enhanced service's underlying repository
      // Note: This is a hack for backward compatibility
      // In practice, you'd need to expose this through the enhanced service
      throw UnimplementedError(
        'Direct access to _notificationService is not supported in Enhanced Framework. '
        'Use the public API methods instead.'
      );
    } else {
      // Access through public interface instead of private field
      throw UnimplementedError(
        'Direct access to internal notification service is deprecated. '
        'Use the public API methods instead.'
      );
    }
  }
}

// Extension methods for easier migration
extension PlantisNotificationServiceV2Extensions on PlantisNotificationServiceV2 {
  /// Automatically migrates to enhanced framework if not already using it
  Future<bool> autoMigrate() async {
    if (!isUsingEnhancedFramework) {
      final result = await migrateFromLegacy();
      return result.isSuccessful;
    }
    return true;
  }

  /// Enables enhanced features with validation
  Future<bool> enableEnhancedFeatures() async {
    if (await autoMigrate()) {
      final validation = await validateConfiguration();
      final hasErrors = validation.any((result) => !result.isValid);

      if (hasErrors && kDebugMode) {
        debugPrint('⚠️ Enhanced features enabled with validation warnings:');
        for (final result in validation.where((r) => !r.isValid)) {
          debugPrint('   ${result.component}: ${result.errors.join(', ')}');
        }
      }

      return !hasErrors;
    }
    return false;
  }
}