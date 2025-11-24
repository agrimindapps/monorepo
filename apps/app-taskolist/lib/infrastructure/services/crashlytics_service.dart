import 'package:core/core.dart';

/// Crashlytics service específico do app Task Manager
class TaskManagerCrashlyticsService {
  final ICrashlyticsRepository _crashlyticsRepository;

  TaskManagerCrashlyticsService(this._crashlyticsRepository);

  Future<void> recordTaskError({
    required String taskId,
    required String errorType,
    required String errorMessage,
    StackTrace? stackTrace,
  }) async {
    await _crashlyticsRepository.recordAppError(
      appName: 'Task Manager',
      feature: 'task_management',
      errorType: errorType,
      errorMessage: errorMessage,
      context: {
        'task_id': taskId,
        'error_category': 'task_operation',
      },
    );
  }

  Future<void> recordDataSyncError({
    required String syncType,
    required String errorMessage,
    String? entityId,
    StackTrace? stackTrace,
  }) async {
    await _crashlyticsRepository.recordAppError(
      appName: 'Task Manager',
      feature: 'data_sync',
      errorType: 'sync_error',
      errorMessage: errorMessage,
      context: {
        'sync_type': syncType,
        if (entityId != null) 'entity_id': entityId,
        'error_category': 'data_sync',
      },
    );
  }

  Future<void> recordUIError({
    required String screenName,
    required String errorMessage,
    String? widget,
    StackTrace? stackTrace,
  }) async {
    await _crashlyticsRepository.recordAppError(
      appName: 'Task Manager',
      feature: 'user_interface',
      errorType: 'ui_error',
      errorMessage: errorMessage,
      context: {
        'screen_name': screenName,
        if (widget != null) 'widget': widget,
        'error_category': 'ui',
      },
    );
  }

  Future<void> recordStorageError({
    required String operation,
    required String errorMessage,
    String? entityType,
    StackTrace? stackTrace,
  }) async {
    await _crashlyticsRepository.recordAppError(
      appName: 'Task Manager',
      feature: 'local_storage',
      errorType: 'storage_error',
      errorMessage: errorMessage,
      context: {
        'storage_operation': operation,
        if (entityType != null) 'entity_type': entityType,
        'error_category': 'storage',
      },
    );
  }

  Future<void> recordNotificationError({
    required String notificationType,
    required String errorMessage,
    StackTrace? stackTrace,
  }) async {
    await _crashlyticsRepository.recordAppError(
      appName: 'Task Manager',
      feature: 'notifications',
      errorType: 'notification_error',
      errorMessage: errorMessage,
      context: {
        'notification_type': notificationType,
        'error_category': 'notification',
      },
    );
  }

  Future<void> recordPerformanceIssue({
    required String performanceMetric,
    required double value,
    required double threshold,
    Map<String, dynamic>? additionalContext,
  }) async {
    await _crashlyticsRepository.recordNonFatalError(
      exception: PerformanceIssue(
        metric: performanceMetric,
        value: value,
        threshold: threshold,
      ),
      stackTrace: StackTrace.current,
      reason: 'Performance Issue Detected',
      additionalInfo: {
        'performance_metric': performanceMetric,
        'current_value': value,
        'threshold': threshold,
        'error_category': 'performance',
        ...?additionalContext,
      },
    );
  }

  Future<void> setTaskManagerContext({
    required String userId,
    required String version,
    required String environment,
  }) async {
    await _crashlyticsRepository.setUserId(userId);
    await _crashlyticsRepository.setCustomKey(key: 'app_name', value: 'Task Manager');
    await _crashlyticsRepository.setCustomKey(key: 'app_version', value: version);
    await _crashlyticsRepository.setCustomKey(key: 'environment', value: environment);
    await _crashlyticsRepository.setCustomKey(key: 'feature_flags', value: 'task_management,notifications,analytics');
  }

  Future<void> recordBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) async {
    await _crashlyticsRepository.recordBreadcrumb(
      message: message,
      category: category ?? 'task_manager',
      data: data,
    );
  }
  Future<void> recordError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    bool fatal = true,
    Map<String, dynamic>? additionalInfo,
  }) => _crashlyticsRepository.recordError(
        exception: exception,
        stackTrace: stackTrace,
        reason: reason,
        fatal: fatal,
        additionalInfo: additionalInfo,
      );

  Future<void> recordNonFatalError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    Map<String, dynamic>? additionalInfo,
  }) => _crashlyticsRepository.recordNonFatalError(
        exception: exception,
        stackTrace: stackTrace,
        reason: reason,
        additionalInfo: additionalInfo,
      );

  Future<void> log(String message) => _crashlyticsRepository.log(message);

  Future<void> setUserId(String userId) => _crashlyticsRepository.setUserId(userId);

  Future<void> setCustomKey({
    required String key,
    required dynamic value,
  }) => _crashlyticsRepository.setCustomKey(key: key, value: value);

  Future<void> recordValidationError({
    required String field,
    required String message,
    Map<String, dynamic>? context,
  }) => _crashlyticsRepository.recordValidationError(
        field: field,
        message: message,
        context: context,
      );

  Future<void> recordNetworkError({
    required String url,
    required int statusCode,
    String? errorMessage,
    Map<String, dynamic>? context,
  }) => _crashlyticsRepository.recordNetworkError(
        url: url,
        statusCode: statusCode,
        errorMessage: errorMessage,
        context: context,
      );

  Future<void> recordParsingError({
    required String dataType,
    required String errorMessage,
    String? rawData,
    Map<String, dynamic>? context,
  }) => _crashlyticsRepository.recordParsingError(
        dataType: dataType,
        errorMessage: errorMessage,
        rawData: rawData,
        context: context,
      );

  Future<void> recordAuthError({
    required String authMethod,
    required String errorCode,
    required String errorMessage,
    Map<String, dynamic>? context,
  }) => _crashlyticsRepository.recordAuthError(
        authMethod: authMethod,
        errorCode: errorCode,
        errorMessage: errorMessage,
        context: context,
      );
}
class PerformanceIssue implements Exception {
  final String metric;
  final double value;
  final double threshold;

  PerformanceIssue({
    required this.metric,
    required this.value,
    required this.threshold,
  });

  @override
  String toString() => 'PerformanceIssue: $metric = $value (threshold: $threshold)';
}
