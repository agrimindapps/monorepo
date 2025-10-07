import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/performance_entity.dart';
import '../../domain/repositories/i_enhanced_notification_repository.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../shared/utils/logger.dart';
import '../helpers/notification_analytics_helper.dart';
import 'local_notification_service.dart';
import 'web_notification_service.dart';

/// Enhanced notification service implementation with plugin support
class EnhancedNotificationService implements IEnhancedNotificationRepository {
  static final EnhancedNotificationService _instance =
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();
  late final INotificationRepository _coreService;
  final Map<String, NotificationPlugin> _plugins = {};
  final Map<String, NotificationTemplate> _templates = {};
  late final NotificationAnalyticsHelper _analyticsHelper;
  bool _isInitialized = false;
  bool _testMode = false;
  EnhancedNotificationSettings _settings = const EnhancedNotificationSettings();
  final List<PerformanceTrackingEntry> _performanceData = [];

  /// Initializes the enhanced notification service
  @override
  Future<bool> initialize({
    List<NotificationChannelEntity>? defaultChannels,
    EnhancedNotificationSettings? settings,
  }) async {
    if (_isInitialized) return true;

    try {
      _coreService =
          kIsWeb ? WebNotificationService() : LocalNotificationService();
      final coreInitialized = await _coreService.initialize(
        defaultChannels: defaultChannels,
      );

      if (!coreInitialized) {
        return false;
      }
      _analyticsHelper = NotificationAnalyticsHelper();
      if (settings != null) {
        _settings = settings;
      }
      _coreService.setNotificationTapCallback(_handleNotificationTap);
      _coreService.setNotificationActionCallback(_handleNotificationAction);
      _isInitialized = true;

      if (_settings.enableDebugLogs) {
        Logger.debug('✅ EnhancedNotificationService initialized successfully');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error initializing EnhancedNotificationService: $e');
      }
      return false;
    }
  }

  @override
  Future<NotificationPermissionEntity> getPermissionStatus() async {
    return await _coreService.getPermissionStatus();
  }

  @override
  Future<NotificationPermissionEntity> requestPermission() async {
    return await _coreService.requestPermission();
  }

  @override
  Future<bool> openNotificationSettings() async {
    return await _coreService.openNotificationSettings();
  }

  @override
  Future<bool> createNotificationChannel(
    NotificationChannelEntity channel,
  ) async {
    return await _coreService.createNotificationChannel(channel);
  }

  @override
  Future<bool> deleteNotificationChannel(String channelId) async {
    return await _coreService.deleteNotificationChannel(channelId);
  }

  @override
  Future<List<NotificationChannelEntity>> getNotificationChannels() async {
    return await _coreService.getNotificationChannels();
  }

  @override
  Future<bool> showNotification(NotificationEntity notification) async {
    if (_testMode) {
      if (_settings.enableDebugLogs) {
        Logger.debug(
          '🧪 Test mode: Would show notification: ${notification.title}',
        );
      }
      return true;
    }

    final start = DateTime.now();
    try {
      final result = await _coreService.showNotification(notification);
      if (_settings.enableAnalytics && result) {
        await _trackEvent(
          NotificationEvent(
            type: NotificationEventType.delivered,
            notificationId: notification.id,
            timestamp: DateTime.now(),
          ),
        );
      }

      _trackPerformance('showNotification', start);
      return result;
    } catch (e) {
      _trackPerformance('showNotification', start, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> scheduleNotification(NotificationEntity notification) async {
    if (_testMode) {
      if (_settings.enableDebugLogs) {
        Logger.debug(
          '🧪 Test mode: Would schedule notification: ${notification.title}',
        );
      }
      return true;
    }

    final start = DateTime.now();
    try {
      final result = await _coreService.scheduleNotification(notification);
      if (_settings.enableAnalytics && result) {
        await _trackEvent(
          NotificationEvent(
            type: NotificationEventType.scheduled,
            notificationId: notification.id,
            timestamp: DateTime.now(),
          ),
        );
      }

      _trackPerformance('scheduleNotification', start);
      return result;
    } catch (e) {
      _trackPerformance('scheduleNotification', start, error: e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> schedulePeriodicNotification(
    NotificationEntity notification,
    Duration repeatInterval,
  ) async {
    return await _coreService.schedulePeriodicNotification(
      notification,
      repeatInterval,
    );
  }

  @override
  Future<bool> cancelNotification(int notificationId) async {
    final result = await _coreService.cancelNotification(notificationId);
    if (_settings.enableAnalytics && result) {
      await _trackEvent(
        NotificationEvent(
          type: NotificationEventType.cancelled,
          notificationId: notificationId,
          timestamp: DateTime.now(),
        ),
      );
    }

    return result;
  }

  @override
  Future<bool> cancelAllNotifications() async {
    return await _coreService.cancelAllNotifications();
  }

  @override
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return await _coreService.getPendingNotifications();
  }

  @override
  Future<List<PendingNotificationEntity>> getActiveNotifications() async {
    return await _coreService.getActiveNotifications();
  }

  @override
  void setNotificationTapCallback(void Function(String? payload) callback) {
    _coreService.setNotificationTapCallback(callback);
  }

  @override
  void setNotificationActionCallback(
    void Function(String actionId, String? payload) callback,
  ) {
    _coreService.setNotificationActionCallback(callback);
  }

  @override
  Future<bool> isNotificationScheduled(int notificationId) async {
    return await _coreService.isNotificationScheduled(notificationId);
  }

  @override
  int generateNotificationId(String identifier) {
    return _coreService.generateNotificationId(identifier);
  }

  @override
  int dateTimeToTimestamp(DateTime dateTime) {
    return _coreService.dateTimeToTimestamp(dateTime);
  }

  @override
  DateTime timestampToDateTime(int timestamp) {
    return _coreService.timestampToDateTime(timestamp);
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    return await _coreService.canScheduleExactNotifications();
  }

  @override
  Future<bool> requestExactNotificationPermission() async {
    return await _coreService.requestExactNotificationPermission();
  }

  @override
  Future<bool> registerPlugin(NotificationPlugin plugin) async {
    try {
      if (_plugins.containsKey(plugin.id)) {
        if (_settings.enableDebugLogs) {
          Logger.debug('⚠️ Plugin ${plugin.id} is already registered');
        }
        return false;
      }

      await plugin.onRegister(this);
      _plugins[plugin.id] = plugin;

      if (_settings.enableDebugLogs) {
        Logger.debug('✅ Registered plugin: ${plugin.id} (${plugin.name})');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error registering plugin ${plugin.id}: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> unregisterPlugin(String pluginId) async {
    try {
      final plugin = _plugins[pluginId];
      if (plugin == null) {
        return false;
      }

      await plugin.onUnregister();
      _plugins.remove(pluginId);
      _templates.removeWhere((key, template) => template.pluginId == pluginId);

      if (_settings.enableDebugLogs) {
        Logger.debug('✅ Unregistered plugin: $pluginId');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error unregistering plugin $pluginId: $e');
      }
      return false;
    }
  }

  @override
  T? getPlugin<T extends NotificationPlugin>(String pluginId) {
    final plugin = _plugins[pluginId];
    if (plugin is T) {
      return plugin;
    }
    return null;
  }

  @override
  List<NotificationPlugin> getRegisteredPlugins() {
    return _plugins.values.toList();
  }

  @override
  Future<bool> registerTemplate(NotificationTemplate template) async {
    try {
      _templates[template.id] = template;

      if (_settings.enableDebugLogs) {
        Logger.debug('✅ Registered template: ${template.id}');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error registering template ${template.id}: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> unregisterTemplate(String templateId) async {
    try {
      final removed = _templates.remove(templateId);

      if (removed != null && _settings.enableDebugLogs) {
        Logger.debug('✅ Unregistered template: $templateId');
      }

      return removed != null;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error unregistering template $templateId: $e');
      }
      return false;
    }
  }

  @override
  Future<NotificationTemplate?> getTemplate(String templateId) async {
    return _templates[templateId];
  }

  @override
  Future<List<NotificationTemplate>> getAllTemplates() async {
    return _templates.values.toList();
  }

  @override
  Future<bool> scheduleFromTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    final start = DateTime.now();

    try {
      final template = _templates[templateId];
      if (template == null) {
        throw ArgumentError('Template not found: $templateId');
      }
      for (final field in template.requiredFields) {
        if (!data.containsKey(field) &&
            !template.defaultData.containsKey(field)) {
          throw ArgumentError('Required field missing: $field');
        }
      }
      final plugin =
          template.pluginId != null ? _plugins[template.pluginId] : null;
      NotificationRequest? request;

      if (plugin != null) {
        request = await plugin.processNotificationData(templateId, data);
      }
      request ??= NotificationRequest.fromTemplate(template, data);
      final notification = _convertRequestToEntity(request);
      final result = await scheduleNotification(notification);

      _trackPerformance('scheduleFromTemplate', start);
      return result;
    } catch (e) {
      _trackPerformance('scheduleFromTemplate', start, error: e.toString());
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error scheduling from template $templateId: $e');
      }
      return false;
    }
  }

  @override
  Future<List<NotificationResult>> scheduleBatch(
    List<NotificationRequest> requests,
  ) async {
    final start = DateTime.now();
    final results = <NotificationResult>[];

    try {
      const batchSize = 10;
      for (int i = 0; i < requests.length; i += batchSize) {
        final endIndex =
            (i + batchSize < requests.length) ? i + batchSize : requests.length;

        final batch = requests.sublist(i, endIndex);
        final batchResults = await _processBatch(batch);
        results.addAll(batchResults);
        if (endIndex < requests.length) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }

      _trackPerformance('scheduleBatch', start);
      return results;
    } catch (e) {
      _trackPerformance('scheduleBatch', start, error: e.toString());
      while (results.length < requests.length) {
        results.add(NotificationResult.failure(e.toString()));
      }

      return results;
    }
  }

  @override
  Future<BatchCancelResult> cancelBatch(List<int> ids) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final id in ids) {
      try {
        final success = await cancelNotification(id);
        if (success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('Failed to cancel notification $id');
        }
      } catch (e) {
        failureCount++;
        errors.add('Error cancelling notification $id: $e');
      }
    }

    return BatchCancelResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  @override
  Future<List<NotificationResult>> updateBatch(
    List<NotificationUpdate> updates,
  ) async {
    final results = <NotificationResult>[];

    for (final update in updates) {
      try {
        final cancelled = await cancelNotification(update.id);
        if (!cancelled) {
          results.add(
            NotificationResult.failure(
              'Failed to cancel notification ${update.id}',
            ),
          );
          continue;
        }
        results.add(NotificationResult.success(update.id.toString()));
      } catch (e) {
        results.add(
          NotificationResult.failure(
            'Error updating notification ${update.id}: $e',
          ),
        );
      }
    }

    return results;
  }

  @override
  Future<bool> scheduleRecurring(RecurringNotificationRequest request) async {
    throw UnimplementedError('Recurring notifications not yet implemented');
  }

  @override
  Future<bool> scheduleConditional(
    ConditionalNotificationRequest request,
  ) async {
    throw UnimplementedError('Conditional notifications not yet implemented');
  }

  @override
  Future<bool> scheduleSmartReminder(SmartReminderRequest request) async {
    throw UnimplementedError('Smart reminders not yet implemented');
  }

  @override
  Future<List<ScheduledNotification>> getScheduledNotifications({
    String? pluginId,
    String? templateId,
    DateRange? dateRange,
  }) async {
    final pendingNotifications = await getPendingNotifications();
    final scheduledNotifications = <ScheduledNotification>[];

    for (final pending in pendingNotifications) {
      try {
        final payload =
            pending.payload != null
                ? jsonDecode(pending.payload!) as Map<String, dynamic>
                : <String, dynamic>{};
        if (pluginId != null && payload['pluginId'] != pluginId) continue;
        if (templateId != null && payload['templateId'] != templateId) continue;

        scheduledNotifications.add(
          ScheduledNotification(
            id: pending.id,
            title: pending.title,
            body: pending.body,
            scheduledDate: DateTime.now(),
            templateId: payload['templateId'] as String?,
            pluginId: payload['pluginId'] as String?,
            data: payload,
          ),
        );
      } catch (e) {
        continue;
      }
    }

    return scheduledNotifications;
  }

  @override
  Future<bool> updateScheduledNotification(
    int id,
    NotificationUpdate update,
  ) async {
    try {
      await cancelNotification(id);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<NotificationHistory> getNotificationHistory(DateRange range) async {
    return await _analyticsHelper.getNotificationHistory(range);
  }

  @override
  Future<void> trackNotificationEvent(NotificationEvent event) async {
    await _trackEvent(event);
  }

  @override
  Future<NotificationAnalytics> getAnalytics(
    DateRange range, {
    String? pluginId,
  }) async {
    return await _analyticsHelper.getAnalytics(range, pluginId: pluginId);
  }

  @override
  Future<UserEngagementMetrics> getUserEngagement(
    String userId,
    DateRange range,
  ) async {
    return await _analyticsHelper.getUserEngagement(userId, range);
  }

  @override
  Future<void> updateGlobalSettings(
    EnhancedNotificationSettings settings,
  ) async {
    _settings = settings;

    if (_settings.enableDebugLogs) {
      Logger.debug('✅ Updated global notification settings');
    }
  }

  @override
  Future<EnhancedNotificationSettings> getGlobalSettings() async {
    return _settings;
  }

  @override
  Future<void> updatePluginSettings(
    String pluginId,
    Map<String, dynamic> settings,
  ) async {
    _settings = EnhancedNotificationSettings(
      pluginSettings: {..._settings.pluginSettings, pluginId: settings},
    );
  }

  @override
  Future<void> enableTestMode(bool enabled) async {
    _testMode = enabled;

    if (_settings.enableDebugLogs) {
      Logger.debug('🧪 Test mode ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  @override
  Future<List<NotificationValidationResult>> validateConfiguration() async {
    final results = <NotificationValidationResult>[];
    for (final plugin in _plugins.values) {
      try {
        final pluginErrors = await plugin.validateConfiguration();
        results.add(
          NotificationValidationResult(
            component: 'Plugin: ${plugin.name}',
            isValid: pluginErrors.isEmpty,
            errors: pluginErrors,
          ),
        );
      } catch (e) {
        results.add(
          NotificationValidationResult(
            component: 'Plugin: ${plugin.name}',
            isValid: false,
            errors: ['Validation failed: $e'],
          ),
        );
      }
    }
    for (final template in _templates.values) {
      final templateErrors = <String>[];
      if (template.title.isEmpty) {
        templateErrors.add('Template title cannot be empty');
      }

      if (template.body.isEmpty) {
        templateErrors.add('Template body cannot be empty');
      }

      results.add(
        NotificationValidationResult(
          component: 'Template: ${template.id}',
          isValid: templateErrors.isEmpty,
          errors: templateErrors,
        ),
      );
    }

    return results;
  }

  @override
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    final now = DateTime.now();
    final schedulingTimes = _performanceData
        .where((entry) => entry.operation == 'scheduleNotification')
        .map((entry) => entry.duration);

    return PerformanceMetrics(
      timestamp: now,
      fps: 60.0,
      memoryUsage: const MemoryUsage(
        usedMemory: 0,
        totalMemory: 0,
        availableMemory: 0,
      ),
      cpuUsage: 0.0,
      batteryLevel: null, // Optional
      networkLatency: null, // Optional
      renderTime:
          schedulingTimes.isNotEmpty
              ? Duration(
                milliseconds:
                    schedulingTimes.fold(0, (a, b) => a + b.inMilliseconds) ~/
                    schedulingTimes.length,
              )
              : Duration.zero,
      frameDrops: 0, // Optional
    );
  }

  Future<List<NotificationResult>> _processBatch(
    List<NotificationRequest> batch,
  ) async {
    final results = <NotificationResult>[];

    for (final request in batch) {
      try {
        final notification = _convertRequestToEntity(request);
        final success = await scheduleNotification(notification);

        if (success) {
          results.add(NotificationResult.success(notification.id.toString()));
        } else {
          results.add(
            NotificationResult.failure('Failed to schedule notification'),
          );
        }
      } catch (e) {
        results.add(NotificationResult.failure(e.toString()));
      }
    }

    return results;
  }

  NotificationEntity _convertRequestToEntity(NotificationRequest request) {
    final id =
        request.id != null
            ? int.tryParse(request.id!) ?? DateTime.now().millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch;

    return NotificationEntity(
      id: id,
      title: request.title,
      body: request.body,
      payload: jsonEncode({
        'templateId': request.templateId,
        'pluginId': request.pluginId,
        ...request.data,
      }),
      channelId: request.channelId,
      scheduledDate: request.scheduledDate,
      priority: request.priority,
      actions:
          request.actions
              .map(
                (action) => NotificationActionEntity(
                  id: action.id,
                  title: action.title,
                  icon: action.icon,
                ),
              )
              .toList(),
    );
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final pluginId = data['pluginId'] as String?;

        if (pluginId != null && _plugins.containsKey(pluginId)) {
          _plugins[pluginId]!.handleAction('notification_tapped', data);
        }
        if (_settings.enableAnalytics) {
          _trackEvent(
            NotificationEvent(
              type: NotificationEventType.clicked,
              notificationId: data['notificationId'] as int? ?? 0,
              timestamp: DateTime.now(),
              templateId: data['templateId'] as String?,
              pluginId: pluginId,
            ),
          );
        }
      } catch (e) {
        if (_settings.enableDebugLogs) {
          Logger.debug('❌ Error handling notification tap: $e');
        }
      }
    }
  }

  void _handleNotificationAction(String actionId, String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final pluginId = data['pluginId'] as String?;

        if (pluginId != null && _plugins.containsKey(pluginId)) {
          _plugins[pluginId]!.handleAction(actionId, data);
        }
        if (_settings.enableAnalytics) {
          _trackEvent(
            NotificationEvent(
              type: NotificationEventType.clicked,
              notificationId: data['notificationId'] as int? ?? 0,
              timestamp: DateTime.now(),
              templateId: data['templateId'] as String?,
              pluginId: pluginId,
              metadata: {'actionId': actionId},
            ),
          );
        }
      } catch (e) {
        if (_settings.enableDebugLogs) {
          Logger.debug('❌ Error handling notification action: $e');
        }
      }
    }
  }

  Future<void> _trackEvent(NotificationEvent event) async {
    if (!_settings.enableAnalytics) return;

    try {
      await _analyticsHelper.trackEvent(event);
    } catch (e) {
      if (_settings.enableDebugLogs) {
        Logger.debug('❌ Error tracking analytics event: $e');
      }
    }
  }

  void _trackPerformance(String operation, DateTime start, {String? error}) {
    final duration = DateTime.now().difference(start);

    _performanceData.add(
      PerformanceTrackingEntry(
        operation: operation,
        duration: duration,
        timestamp: start,
        error: error,
      ),
    );
    if (_performanceData.length > 1000) {
      _performanceData.removeRange(0, 500);
    }
  }
}

/// Performance tracking entry
class PerformanceTrackingEntry {
  /// The operation being tracked
  final String operation;

  /// Duration of the operation
  final Duration duration;

  /// Timestamp when the operation started
  final DateTime timestamp;

  /// Error message if the operation failed
  final String? error;

  /// Creates a performance tracking entry
  const PerformanceTrackingEntry({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.error,
  });
}
