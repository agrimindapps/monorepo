import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_enhanced_notification_repository.dart';
import '../../domain/repositories/i_notification_repository.dart';

/// Helper class for migrating from legacy notification services to Enhanced Framework
class NotificationMigrationHelper {
  final IEnhancedNotificationRepository _enhancedService;
  final INotificationRepository _legacyService;

  NotificationMigrationHelper(this._enhancedService, this._legacyService);

  /// Migrates all pending notifications from legacy service to enhanced service
  ///
  /// Returns migration result with success/failure details
  Future<MigrationResult> migrateAllNotifications() async {
    final result = MigrationResult();

    try {
      if (kDebugMode) {
        debugPrint('🚀 Starting notification migration...');
      }
      final pendingNotifications = await _legacyService.getPendingNotifications();

      if (kDebugMode) {
        debugPrint('📋 Found ${pendingNotifications.length} notifications to migrate');
      }
      for (final notification in pendingNotifications) {
        await _migrateNotification(notification, result);
      }

      if (kDebugMode) {
        debugPrint('✅ Migration completed: ${result.summary}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Migration failed: $e');
      }

      result.addGlobalError('Migration process failed: $e');
      return result;
    }
  }

  /// Migrates a specific notification
  ///
  /// [notification] - Legacy notification to migrate
  /// [result] - Migration result to update
  Future<void> _migrateNotification(
    PendingNotificationEntity notification,
    MigrationResult result,
  ) async {
    try {
      Map<String, dynamic> legacyData = {};
      if (notification.payload != null) {
        try {
          legacyData = jsonDecode(notification.payload!) as Map<String, dynamic>;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to parse payload for notification ${notification.id}: $e');
          }
        }
      }
      final enhancedNotification = NotificationEntity(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        payload: _createEnhancedPayload(legacyData),
        channelId: legacyData['channelId'] as String? ?? 'default',
        priority: _mapLegacyPriority(legacyData),
        importance: _mapLegacyImportance(legacyData),
        scheduledDate: _extractScheduledDate(legacyData),
      );
      final success = await _enhancedService.scheduleNotification(enhancedNotification);

      if (success) {
        result.addSuccess(notification.id, 'Successfully migrated notification');
        await _legacyService.cancelNotification(notification.id);
      } else {
        result.addFailure(notification.id, 'Failed to schedule in enhanced service');
      }
    } catch (e) {
      result.addFailure(notification.id, 'Migration error: $e');
    }
  }

  /// Creates enhanced payload from legacy data
  ///
  /// [legacyData] - Legacy notification data
  /// Returns enhanced payload as JSON string
  String _createEnhancedPayload(Map<String, dynamic> legacyData) {
    final enhancedData = <String, dynamic>{
      'migratedFrom': 'legacy',
      'migrationDate': DateTime.now().toIso8601String(),
      'legacyData': legacyData,
    };
    if (legacyData.containsKey('plantId')) {
      enhancedData['entityId'] = legacyData['plantId'];
      enhancedData['entityType'] = 'plant';
      enhancedData['pluginId'] = 'plant_care';
    } else if (legacyData.containsKey('taskId')) {
      enhancedData['entityId'] = legacyData['taskId'];
      enhancedData['entityType'] = 'task';
      enhancedData['pluginId'] = 'task_management';
    } else if (legacyData.containsKey('vehicleId')) {
      enhancedData['entityId'] = legacyData['vehicleId'];
      enhancedData['entityType'] = 'vehicle';
      enhancedData['pluginId'] = 'vehicle_maintenance';
    }

    return jsonEncode(enhancedData);
  }

  /// Maps legacy priority to enhanced priority
  ///
  /// [legacyData] - Legacy data that may contain priority info
  /// Returns enhanced priority entity
  NotificationPriorityEntity _mapLegacyPriority(Map<String, dynamic> legacyData) {
    final priorityStr = legacyData['priority'] as String?;

    switch (priorityStr?.toLowerCase()) {
      case 'high':
        return NotificationPriorityEntity.high;
      case 'low':
        return NotificationPriorityEntity.low;
      case 'max':
        return NotificationPriorityEntity.max;
      case 'min':
        return NotificationPriorityEntity.min;
      default:
        return NotificationPriorityEntity.defaultPriority;
    }
  }

  /// Maps legacy importance to enhanced importance
  ///
  /// [legacyData] - Legacy data that may contain importance info
  /// Returns enhanced importance entity
  NotificationImportanceEntity _mapLegacyImportance(Map<String, dynamic> legacyData) {
    final importanceStr = legacyData['importance'] as String?;

    switch (importanceStr?.toLowerCase()) {
      case 'high':
        return NotificationImportanceEntity.high;
      case 'low':
        return NotificationImportanceEntity.low;
      case 'max':
        return NotificationImportanceEntity.max;
      case 'min':
        return NotificationImportanceEntity.min;
      case 'none':
        return NotificationImportanceEntity.none;
      default:
        return NotificationImportanceEntity.defaultImportance;
    }
  }

  /// Extracts scheduled date from legacy data
  ///
  /// [legacyData] - Legacy data that may contain scheduled date
  /// Returns scheduled date or null if not found
  DateTime? _extractScheduledDate(Map<String, dynamic> legacyData) {
    final scheduledStr = legacyData['scheduledDate'] as String?;
    if (scheduledStr != null) {
      try {
        return DateTime.parse(scheduledStr);
      } catch (e) {
        return null;
      }
    }

    final timestampMs = legacyData['scheduledTimestamp'] as int?;
    if (timestampMs != null) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(timestampMs);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Validates that migration was successful
  ///
  /// [result] - Migration result to validate
  /// Returns validation result
  Future<MigrationValidationResult> validateMigration(MigrationResult result) async {
    final validationResult = MigrationValidationResult();

    try {
      final enhancedNotifications = await _enhancedService.getPendingNotifications();
      final legacyNotifications = await _legacyService.getPendingNotifications();

      validationResult.enhancedNotificationCount = enhancedNotifications.length;
      validationResult.legacyNotificationCount = legacyNotifications.length;
      for (final successId in result.successIds) {
        final hasInEnhanced = enhancedNotifications.any((n) => n.id == successId);
        final hasInLegacy = legacyNotifications.any((n) => n.id == successId);

        if (hasInEnhanced && !hasInLegacy) {
          validationResult.addValidNotification(successId);
        } else if (!hasInEnhanced && hasInLegacy) {
          validationResult.addMigrationError(successId, 'Notification not found in enhanced service');
        } else if (hasInEnhanced && hasInLegacy) {
          validationResult.addMigrationWarning(successId, 'Notification exists in both services');
        } else {
          validationResult.addMigrationError(successId, 'Notification missing from both services');
        }
      }

      validationResult.isValid = validationResult.errors.isEmpty;

      if (kDebugMode) {
        debugPrint('🔍 Migration validation completed: ${validationResult.summary}');
      }

      return validationResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Migration validation failed: $e');
      }

      validationResult.addGlobalError('Validation failed: $e');
      return validationResult;
    }
  }

  /// Rolls back migration by restoring notifications to legacy service
  ///
  /// [result] - Original migration result
  /// Returns rollback result
  Future<RollbackResult> rollbackMigration(MigrationResult result) async {
    final rollbackResult = RollbackResult();

    if (kDebugMode) {
      debugPrint('🔄 Starting migration rollback...');
    }

    for (final successId in result.successIds) {
      try {
        final enhancedNotifications = await _enhancedService.getPendingNotifications();
        final notification = enhancedNotifications.firstWhereOrNull((n) => n.id == successId);

        if (notification != null) {
          Map<String, dynamic> legacyData = {};
          if (notification.payload != null) {
            try {
              final enhancedPayload = jsonDecode(notification.payload!) as Map<String, dynamic>;
              legacyData = enhancedPayload['legacyData'] as Map<String, dynamic>? ?? {};
            } catch (e) {
              legacyData = {
                'title': notification.title,
                'body': notification.body,
              };
            }
          }
          final legacyNotification = NotificationEntity(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            payload: jsonEncode(legacyData),
            channelId: legacyData['channelId'] as String? ?? 'default',
          );
          final success = await _legacyService.scheduleNotification(legacyNotification);

          if (success) {
            await _enhancedService.cancelNotification(successId);
            rollbackResult.addSuccess(successId);
          } else {
            rollbackResult.addFailure(successId, 'Failed to restore to legacy service');
          }
        } else {
          rollbackResult.addFailure(successId, 'Notification not found in enhanced service');
        }
      } catch (e) {
        rollbackResult.addFailure(successId, 'Rollback error: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('🔄 Rollback completed: ${rollbackResult.summary}');
    }

    return rollbackResult;
  }
}

/// Result of notification migration operation
class MigrationResult {
  final List<int> _successIds = [];
  final Map<int, String> _failures = {};
  final List<String> _globalErrors = [];

  /// IDs of successfully migrated notifications
  List<int> get successIds => List.unmodifiable(_successIds);

  /// Map of failed notification IDs to error messages
  Map<int, String> get failures => Map.unmodifiable(_failures);

  /// Global migration errors
  List<String> get globalErrors => List.unmodifiable(_globalErrors);

  /// Total number of successful migrations
  int get successCount => _successIds.length;

  /// Total number of failed migrations
  int get failureCount => _failures.length;

  /// Total number of migration attempts
  int get totalCount => successCount + failureCount;

  /// Success rate as percentage
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;

  /// Human-readable summary
  String get summary =>
      'Success: $successCount, Failures: $failureCount, Rate: ${(successRate * 100).toStringAsFixed(1)}%';

  /// Whether migration was completely successful
  bool get isSuccessful => failureCount == 0 && globalErrors.isEmpty;

  /// Adds a successful migration
  void addSuccess(int notificationId, String message) {
    _successIds.add(notificationId);
  }

  /// Adds a failed migration
  void addFailure(int notificationId, String error) {
    _failures[notificationId] = error;
  }

  /// Adds a global migration error
  void addGlobalError(String error) {
    _globalErrors.add(error);
  }
}

/// Result of migration validation
class MigrationValidationResult {
  final List<int> _validNotifications = [];
  final Map<int, String> _errors = {};
  final Map<int, String> _warnings = {};
  final List<String> _globalErrors = [];

  bool isValid = false;
  int enhancedNotificationCount = 0;
  int legacyNotificationCount = 0;

  /// Successfully validated notifications
  List<int> get validNotifications => List.unmodifiable(_validNotifications);

  /// Validation errors per notification
  Map<int, String> get errors => Map.unmodifiable(_errors);

  /// Validation warnings per notification
  Map<int, String> get warnings => Map.unmodifiable(_warnings);

  /// Global validation errors
  List<String> get globalErrors => List.unmodifiable(_globalErrors);

  /// Human-readable summary
  String get summary =>
      'Valid: ${validNotifications.length}, Errors: ${errors.length}, Warnings: ${warnings.length}';

  void addValidNotification(int notificationId) {
    _validNotifications.add(notificationId);
  }

  void addMigrationError(int notificationId, String error) {
    _errors[notificationId] = error;
  }

  void addMigrationWarning(int notificationId, String warning) {
    _warnings[notificationId] = warning;
  }

  void addGlobalError(String error) {
    _globalErrors.add(error);
  }
}

/// Result of migration rollback operation
class RollbackResult {
  final List<int> _successIds = [];
  final Map<int, String> _failures = {};

  /// IDs of successfully rolled back notifications
  List<int> get successIds => List.unmodifiable(_successIds);

  /// Map of failed rollback IDs to error messages
  Map<int, String> get failures => Map.unmodifiable(_failures);

  /// Total number of successful rollbacks
  int get successCount => _successIds.length;

  /// Total number of failed rollbacks
  int get failureCount => _failures.length;

  /// Total number of rollback attempts
  int get totalCount => successCount + failureCount;

  /// Success rate as percentage
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;

  /// Human-readable summary
  String get summary =>
      'Rollback Success: $successCount, Failures: $failureCount, Rate: ${(successRate * 100).toStringAsFixed(1)}%';

  /// Whether rollback was completely successful
  bool get isSuccessful => failureCount == 0;

  void addSuccess(int notificationId) {
    _successIds.add(notificationId);
  }

  void addFailure(int notificationId, String error) {
    _failures[notificationId] = error;
  }
}

/// Extension for firstWhereOrNull functionality
extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}