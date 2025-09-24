import '../entities/notification_entity.dart';
import '../entities/performance_entity.dart';
import 'i_notification_repository.dart';

/// Enhanced notification repository interface with plugin support and advanced features
///
/// This interface extends the base INotificationRepository with:
/// - Plugin system for app-specific notification logic
/// - Template engine for notification templating
/// - Batch operations for performance
/// - Advanced scheduling (recurring, conditional)
/// - Analytics and insights
/// - Configuration management
abstract class IEnhancedNotificationRepository extends INotificationRepository {
  // Plugin Management

  /// Registers a notification plugin
  ///
  /// [plugin] - The plugin instance to register
  /// Returns true if registration was successful
  Future<bool> registerPlugin(NotificationPlugin plugin);

  /// Unregisters a plugin by ID
  ///
  /// [pluginId] - ID of the plugin to unregister
  /// Returns true if unregistration was successful
  Future<bool> unregisterPlugin(String pluginId);

  /// Gets a registered plugin by ID and type
  ///
  /// [pluginId] - ID of the plugin to retrieve
  /// Returns the plugin instance or null if not found
  T? getPlugin<T extends NotificationPlugin>(String pluginId);

  /// Lists all registered plugins
  ///
  /// Returns list of all currently registered plugins
  List<NotificationPlugin> getRegisteredPlugins();

  // Template Management

  /// Registers a notification template
  ///
  /// [template] - The template to register
  /// Returns true if registration was successful
  Future<bool> registerTemplate(NotificationTemplate template);

  /// Unregisters a template by ID
  ///
  /// [templateId] - ID of the template to unregister
  /// Returns true if unregistration was successful
  Future<bool> unregisterTemplate(String templateId);

  /// Gets a template by ID
  ///
  /// [templateId] - ID of the template to retrieve
  /// Returns the template or null if not found
  Future<NotificationTemplate?> getTemplate(String templateId);

  /// Lists all registered templates
  ///
  /// Returns list of all registered templates
  Future<List<NotificationTemplate>> getAllTemplates();

  /// Schedules a notification from template
  ///
  /// [templateId] - ID of the template to use
  /// [data] - Data to bind to template variables
  /// Returns true if scheduling was successful
  Future<bool> scheduleFromTemplate(String templateId, Map<String, dynamic> data);

  // Batch Operations

  /// Schedules multiple notifications in batch
  ///
  /// [requests] - List of notification requests to schedule
  /// Returns list of results for each request
  Future<List<NotificationResult>> scheduleBatch(List<NotificationRequest> requests);

  /// Cancels multiple notifications by IDs
  ///
  /// [ids] - List of notification IDs to cancel
  /// Returns batch cancel result with success/failure counts
  Future<BatchCancelResult> cancelBatch(List<int> ids);

  /// Updates multiple notifications in batch
  ///
  /// [updates] - List of notification updates to apply
  /// Returns list of results for each update
  Future<List<NotificationResult>> updateBatch(List<NotificationUpdate> updates);

  // Advanced Scheduling

  /// Schedules a recurring notification
  ///
  /// [request] - Recurring notification configuration
  /// Returns true if scheduling was successful
  Future<bool> scheduleRecurring(RecurringNotificationRequest request);

  /// Schedules a conditional notification
  ///
  /// [request] - Conditional notification configuration
  /// Returns true if scheduling was successful
  Future<bool> scheduleConditional(ConditionalNotificationRequest request);

  /// Schedules a smart reminder with adaptive timing
  ///
  /// [request] - Smart reminder configuration
  /// Returns true if scheduling was successful
  Future<bool> scheduleSmartReminder(SmartReminderRequest request);

  // Notification Management

  /// Gets scheduled notifications with optional filters
  ///
  /// [pluginId] - Filter by plugin ID (optional)
  /// [templateId] - Filter by template ID (optional)
  /// [dateRange] - Filter by date range (optional)
  /// Returns list of scheduled notifications matching filters
  Future<List<ScheduledNotification>> getScheduledNotifications({
    String? pluginId,
    String? templateId,
    DateRange? dateRange,
  });

  /// Updates a scheduled notification
  ///
  /// [id] - Notification ID to update
  /// [update] - Update data to apply
  /// Returns true if update was successful
  Future<bool> updateScheduledNotification(int id, NotificationUpdate update);

  /// Gets notification history
  ///
  /// [range] - Date range to query
  /// Returns notification history for the specified range
  Future<NotificationHistory> getNotificationHistory(DateRange range);

  // Analytics and Insights

  /// Tracks a notification event for analytics
  ///
  /// [event] - The event to track
  Future<void> trackNotificationEvent(NotificationEvent event);

  /// Gets notification analytics
  ///
  /// [range] - Date range for analytics
  /// [pluginId] - Filter by plugin ID (optional)
  /// Returns analytics data for the specified range and filter
  Future<NotificationAnalytics> getAnalytics(DateRange range, {String? pluginId});

  /// Gets user engagement metrics
  ///
  /// [userId] - User ID to analyze
  /// [range] - Date range for analysis
  /// Returns engagement metrics for the user
  Future<UserEngagementMetrics> getUserEngagement(String userId, DateRange range);

  // Configuration and Settings

  /// Updates global notification settings
  ///
  /// [settings] - New settings to apply
  Future<void> updateGlobalSettings(EnhancedNotificationSettings settings);

  /// Gets current global settings
  ///
  /// Returns current global notification settings
  Future<EnhancedNotificationSettings> getGlobalSettings();

  /// Updates plugin-specific settings
  ///
  /// [pluginId] - ID of the plugin to update settings for
  /// [settings] - Settings data to apply
  Future<void> updatePluginSettings(String pluginId, Map<String, dynamic> settings);

  // Testing and Development

  /// Enables/disables test mode
  ///
  /// [enabled] - Whether to enable test mode
  /// Test mode prevents actual notification delivery
  Future<void> enableTestMode(bool enabled);

  /// Validates the current configuration
  ///
  /// Returns list of validation results
  Future<List<NotificationValidationResult>> validateConfiguration();

  /// Gets performance metrics
  ///
  /// Returns current performance metrics
  Future<PerformanceMetrics> getPerformanceMetrics();
}

// Core Data Models

/// Base class for notification plugins
abstract class NotificationPlugin {
  /// Unique identifier for this plugin
  String get id;

  /// Human-readable name for this plugin
  String get name;

  /// Version of this plugin
  String get version => '1.0.0';

  /// List of template IDs this plugin supports
  List<String> get supportedTemplates;

  /// Called when plugin is registered with the repository
  ///
  /// [repository] - The repository instance this plugin is registered with
  Future<void> onRegister(IEnhancedNotificationRepository repository);

  /// Called when plugin is unregistered
  Future<void> onUnregister();

  /// Process plugin-specific notification data
  ///
  /// [templateId] - ID of the template being processed
  /// [data] - Template data to process
  /// Returns processed notification request or null if not handled
  Future<NotificationRequest?> processNotificationData(
    String templateId,
    Map<String, dynamic> data,
  );

  /// Handle plugin-specific actions
  ///
  /// [action] - Action identifier
  /// [params] - Action parameters
  Future<void> handleAction(String action, Map<String, dynamic> params);

  /// Validate plugin configuration
  ///
  /// Returns list of validation issues (empty if valid)
  Future<List<String>> validateConfiguration();
}

/// Notification template with data binding support
class NotificationTemplate {
  /// Unique template identifier
  final String id;

  /// Template title with variable placeholders
  final String title;

  /// Template body with variable placeholders
  final String body;

  /// Default data values for template variables
  final Map<String, dynamic> defaultData;

  /// Actions available for this template
  final List<NotificationAction> actions;

  /// Recurrence rule for recurring notifications
  final RecurrenceRule? recurrence;

  /// Required fields that must be provided in data
  final List<String> requiredFields;

  /// Channel ID for notifications created from this template
  final String channelId;

  /// Priority for notifications created from this template
  final NotificationPriorityEntity priority;

  /// Plugin ID that owns this template
  final String? pluginId;

  /// Metadata for additional template configuration
  final Map<String, dynamic> metadata;

  const NotificationTemplate({
    required this.id,
    required this.title,
    required this.body,
    this.defaultData = const {},
    this.actions = const [],
    this.recurrence,
    this.requiredFields = const [],
    this.channelId = 'default',
    this.priority = NotificationPriorityEntity.defaultPriority,
    this.pluginId,
    this.metadata = const {},
  });

  /// Creates a copy of this template with updated fields
  NotificationTemplate copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? defaultData,
    List<NotificationAction>? actions,
    RecurrenceRule? recurrence,
    List<String>? requiredFields,
    String? channelId,
    NotificationPriorityEntity? priority,
    String? pluginId,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      defaultData: defaultData ?? this.defaultData,
      actions: actions ?? this.actions,
      recurrence: recurrence ?? this.recurrence,
      requiredFields: requiredFields ?? this.requiredFields,
      channelId: channelId ?? this.channelId,
      priority: priority ?? this.priority,
      pluginId: pluginId ?? this.pluginId,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Notification request for scheduling
class NotificationRequest {
  final String? id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final List<NotificationAction> actions;
  final NotificationPriorityEntity priority;
  final String channelId;
  final DateTime? scheduledDate;
  final RecurrenceRule? recurrence;
  final ConditionalRule? conditional;
  final String? templateId;
  final String? pluginId;
  final Map<String, dynamic> metadata;

  const NotificationRequest({
    this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
    this.actions = const [],
    this.priority = NotificationPriorityEntity.defaultPriority,
    this.channelId = 'default',
    this.scheduledDate,
    this.recurrence,
    this.conditional,
    this.templateId,
    this.pluginId,
    this.metadata = const {},
  });

  /// Creates a notification request from a template
  factory NotificationRequest.fromTemplate(
    NotificationTemplate template,
    Map<String, dynamic> data,
  ) {
    final mergedData = {...template.defaultData, ...data};

    return NotificationRequest(
      title: _processTemplate(template.title, mergedData),
      body: _processTemplate(template.body, mergedData),
      actions: template.actions,
      priority: template.priority,
      channelId: template.channelId,
      recurrence: template.recurrence,
      templateId: template.id,
      pluginId: template.pluginId,
      data: mergedData,
      metadata: template.metadata,
    );
  }

  /// Process template string with data binding
  static String _processTemplate(String template, Map<String, dynamic> data) {
    String result = template;
    data.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }
}

/// Result of a notification operation
class NotificationResult {
  final bool success;
  final String? notificationId;
  final String? error;
  final Map<String, dynamic> metadata;

  const NotificationResult({
    required this.success,
    this.notificationId,
    this.error,
    this.metadata = const {},
  });

  /// Creates a successful result
  factory NotificationResult.success(String notificationId) {
    return NotificationResult(
      success: true,
      notificationId: notificationId,
    );
  }

  /// Creates a failure result
  factory NotificationResult.failure(String error) {
    return NotificationResult(
      success: false,
      error: error,
    );
  }
}

/// Result of batch cancel operation
class BatchCancelResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;

  const BatchCancelResult({
    required this.successCount,
    required this.failureCount,
    this.errors = const [],
  });

  /// Total number of operations
  int get totalCount => successCount + failureCount;

  /// Success rate as percentage
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
}

/// Update data for notifications
class NotificationUpdate {
  final int id;
  final String? title;
  final String? body;
  final DateTime? scheduledDate;
  final Map<String, dynamic>? data;
  final bool? enabled;

  const NotificationUpdate({
    required this.id,
    this.title,
    this.body,
    this.scheduledDate,
    this.data,
    this.enabled,
  });
}

/// Recurring notification configuration
class RecurringNotificationRequest {
  final NotificationRequest baseNotification;
  final RecurrenceRule recurrenceRule;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxOccurrences;

  const RecurringNotificationRequest({
    required this.baseNotification,
    required this.recurrenceRule,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
  });
}

/// Conditional notification configuration
class ConditionalNotificationRequest {
  final NotificationRequest baseNotification;
  final ConditionalRule conditionalRule;
  final DateTime startDate;
  final DateTime? endDate;

  const ConditionalNotificationRequest({
    required this.baseNotification,
    required this.conditionalRule,
    required this.startDate,
    this.endDate,
  });
}

/// Smart reminder configuration
class SmartReminderRequest {
  final NotificationRequest baseNotification;
  final Duration baseInterval;
  final List<Duration> adaptiveIntervals;
  final int maxReminders;

  const SmartReminderRequest({
    required this.baseNotification,
    required this.baseInterval,
    this.adaptiveIntervals = const [],
    this.maxReminders = 3,
  });
}

/// Recurrence rule for recurring notifications
class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final List<int>? weekdays;
  final int? dayOfMonth;
  final List<int>? monthsOfYear;
  final Duration? reminderOffset;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.weekdays,
    this.dayOfMonth,
    this.monthsOfYear,
    this.reminderOffset,
  });
}

/// Conditional rule for conditional notifications
class ConditionalRule {
  final String conditionId;
  final Map<String, dynamic> parameters;
  final Duration checkInterval;
  final int maxChecks;
  final ConditionOperator operator;

  const ConditionalRule({
    required this.conditionId,
    this.parameters = const {},
    this.checkInterval = const Duration(hours: 1),
    this.maxChecks = 24,
    this.operator = ConditionOperator.and,
  });
}

/// Scheduled notification information
class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String? templateId;
  final String? pluginId;
  final Map<String, dynamic> data;
  final bool isRecurring;
  final bool isConditional;
  final bool enabled;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.templateId,
    this.pluginId,
    this.data = const {},
    this.isRecurring = false,
    this.isConditional = false,
    this.enabled = true,
  });
}

/// Date range for queries
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// Creates a date range for the last N days
  factory DateRange.lastDays(int days) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return DateRange(startDate: start, endDate: end);
  }

  /// Creates a date range for the last month
  factory DateRange.lastMonth() {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - 1, end.day);
    return DateRange(startDate: start, endDate: end);
  }
}

/// Notification history data
class NotificationHistory {
  final List<NotificationHistoryEntry> entries;
  final int totalCount;
  final DateRange dateRange;

  const NotificationHistory({
    required this.entries,
    required this.totalCount,
    required this.dateRange,
  });
}

/// Single notification history entry
class NotificationHistoryEntry {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final DateTime? deliveredDate;
  final DateTime? clickedDate;
  final String? templateId;
  final String? pluginId;
  final NotificationEventType status;

  const NotificationHistoryEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.deliveredDate,
    this.clickedDate,
    this.templateId,
    this.pluginId,
    required this.status,
  });
}

/// Notification event for analytics
class NotificationEvent {
  final NotificationEventType type;
  final int notificationId;
  final DateTime timestamp;
  final String? templateId;
  final String? pluginId;
  final Map<String, dynamic> metadata;

  const NotificationEvent({
    required this.type,
    required this.notificationId,
    required this.timestamp,
    this.templateId,
    this.pluginId,
    this.metadata = const {},
  });
}

/// Analytics data for notifications
class NotificationAnalytics {
  final int totalScheduled;
  final int totalDelivered;
  final int totalClicked;
  final int totalDismissed;
  final double deliveryRate;
  final double clickThroughRate;
  final double engagementRate;
  final Map<String, int> clicksByAction;
  final Map<String, int> deliveryByChannel;
  final Map<String, double> performanceByPlugin;
  final List<NotificationTrend> trends;
  final DateRange dateRange;

  const NotificationAnalytics({
    required this.totalScheduled,
    required this.totalDelivered,
    required this.totalClicked,
    required this.totalDismissed,
    required this.deliveryRate,
    required this.clickThroughRate,
    required this.engagementRate,
    required this.clicksByAction,
    required this.deliveryByChannel,
    required this.performanceByPlugin,
    required this.trends,
    required this.dateRange,
  });
}

/// User engagement metrics
class UserEngagementMetrics {
  final String userId;
  final DateRange dateRange;
  final int totalNotificationsReceived;
  final int totalNotificationsClicked;
  final double engagementRate;
  final Duration averageResponseTime;
  final Map<String, int> engagementByPlugin;
  final List<String> preferredNotificationTimes;

  const UserEngagementMetrics({
    required this.userId,
    required this.dateRange,
    required this.totalNotificationsReceived,
    required this.totalNotificationsClicked,
    required this.engagementRate,
    required this.averageResponseTime,
    required this.engagementByPlugin,
    required this.preferredNotificationTimes,
  });
}

/// Notification trend data
class NotificationTrend {
  final DateTime date;
  final int scheduled;
  final int delivered;
  final int clicked;
  final double deliveryRate;
  final double engagementRate;

  const NotificationTrend({
    required this.date,
    required this.scheduled,
    required this.delivered,
    required this.clicked,
    required this.deliveryRate,
    required this.engagementRate,
  });
}

/// Enhanced notification settings
class EnhancedNotificationSettings {
  // Base settings
  final String defaultIcon;
  final int? defaultColor;
  final bool enableDebugLogs;
  final bool autoCancel;
  final bool showBadge;
  // Enhanced settings
  final bool enableAnalytics;
  final bool enableSmartScheduling;
  final Duration defaultSnoozeInterval;
  final int maxNotificationsPerDay;
  final List<String> enabledPlugins;
  final Map<String, dynamic> pluginSettings;

  const EnhancedNotificationSettings({
    // Base settings
    this.defaultIcon = '@mipmap/ic_launcher',
    this.defaultColor,
    this.enableDebugLogs = false,
    this.autoCancel = true,
    this.showBadge = true,
    // Enhanced settings
    this.enableAnalytics = true,
    this.enableSmartScheduling = true,
    this.defaultSnoozeInterval = const Duration(hours: 1),
    this.maxNotificationsPerDay = 50,
    this.enabledPlugins = const [],
    this.pluginSettings = const {},
  });
}

/// Validation result for configuration
class NotificationValidationResult {
  final String component;
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;

  const NotificationValidationResult({
    required this.component,
    required this.isValid,
    this.warnings = const [],
    this.errors = const [],
  });
}

// PerformanceMetrics is imported from ../entities/performance_entity.dart

// Enums

/// Notification action data
class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final bool destructive;
  final Map<String, dynamic> data;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.destructive = false,
    this.data = const {},
  });
}

/// Recurrence frequency options
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// Condition operators for conditional notifications
enum ConditionOperator {
  and,
  or,
  not,
}

/// Event types for notifications
enum NotificationEventType {
  scheduled,
  delivered,
  clicked,
  dismissed,
  snoozed,
  cancelled,
  failed,
}