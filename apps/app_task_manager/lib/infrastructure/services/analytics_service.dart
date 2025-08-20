import 'package:core/core.dart';

/// Analytics service específico do app Task Manager
class TaskManagerAnalyticsService {
  final IAnalyticsRepository _analyticsRepository;

  TaskManagerAnalyticsService(this._analyticsRepository);

  // Eventos específicos do Task Manager

  Future<void> logTaskCreated({
    required String taskId,
    required String priority,
    String? category,
    Duration? estimatedTime,
  }) async {
    await _analyticsRepository.logEvent('task_created', parameters: {
      'task_id': taskId,
      'priority': priority,
      if (category != null) 'category': category,
      if (estimatedTime != null) 'estimated_time_minutes': estimatedTime.inMinutes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logTaskCompleted({
    required String taskId,
    required Duration timeSpent,
    required String priority,
    String? category,
  }) async {
    await _analyticsRepository.logEvent('task_completed', parameters: {
      'task_id': taskId,
      'time_spent_minutes': timeSpent.inMinutes,
      'priority': priority,
      if (category != null) 'category': category,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logTaskDeleted({
    required String taskId,
    required String reason,
    bool wasCompleted = false,
  }) async {
    await _analyticsRepository.logEvent('task_deleted', parameters: {
      'task_id': taskId,
      'deletion_reason': reason,
      'was_completed': wasCompleted,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logTaskEdited({
    required String taskId,
    required List<String> editedFields,
  }) async {
    await _analyticsRepository.logEvent('task_edited', parameters: {
      'task_id': taskId,
      'edited_fields': editedFields.join(','),
      'fields_count': editedFields.length,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logSubtaskCreated({
    required String parentTaskId,
    required String subtaskId,
  }) async {
    await _analyticsRepository.logEvent('subtask_created', parameters: {
      'parent_task_id': parentTaskId,
      'subtask_id': subtaskId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logFilterApplied({
    required String filterType,
    required String filterValue,
  }) async {
    await _analyticsRepository.logEvent('filter_applied', parameters: {
      'filter_type': filterType,
      'filter_value': filterValue,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logSearchPerformed({
    required String searchTerm,
    required int resultCount,
  }) async {
    await _analyticsRepository.logSearch(
      searchTerm: searchTerm,
      category: 'tasks',
      resultCount: resultCount,
    );
  }

  Future<void> logCommentAdded({
    required String taskId,
    required int commentLength,
  }) async {
    await _analyticsRepository.logEvent('comment_added', parameters: {
      'task_id': taskId,
      'comment_length': commentLength,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logTimeTrackingStarted({
    required String taskId,
  }) async {
    await _analyticsRepository.logEvent('time_tracking_started', parameters: {
      'task_id': taskId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logTimeTrackingStopped({
    required String taskId,
    required Duration trackedTime,
  }) async {
    await _analyticsRepository.logEvent('time_tracking_stopped', parameters: {
      'task_id': taskId,
      'tracked_time_minutes': trackedTime.inMinutes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logAppFeatureUsed({
    required String featureName,
    Map<String, dynamic>? additionalData,
  }) async {
    await _analyticsRepository.logEvent('feature_used', parameters: {
      'feature_name': featureName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalData,
    });
  }

  Future<void> logProductivityMetrics({
    required int completedTasks,
    required int totalTasks,
    required Duration totalTimeSpent,
  }) async {
    await _analyticsRepository.logEvent('productivity_metrics', parameters: {
      'completed_tasks': completedTasks,
      'total_tasks': totalTasks,
      'completion_rate': (completedTasks / totalTasks * 100).round(),
      'total_time_minutes': totalTimeSpent.inMinutes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Delegate methods do core
  Future<void> setUserId(String? userId) => _analyticsRepository.setUserId(userId);

  Future<void> setUserProperties(Map<String, String> properties) => 
      _analyticsRepository.setUserProperties(properties: properties);

  Future<void> setCurrentScreen(String screenName) => 
      _analyticsRepository.setCurrentScreen(screenName: screenName);

  Future<void> logLogin(String method) => 
      _analyticsRepository.logLogin(method: method);

  Future<void> logLogout() => _analyticsRepository.logLogout();

  Future<void> logSignUp(String method) => 
      _analyticsRepository.logSignUp(method: method);

  Future<void> logError({
    required String error,
    String? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) => _analyticsRepository.logError(
        error: error,
        stackTrace: stackTrace,
        additionalInfo: additionalInfo,
      );

  Future<void> logSettingChanged({
    required String settingName,
    required dynamic oldValue,
    required dynamic newValue,
  }) => _analyticsRepository.logSettingChanged(
        settingName: settingName,
        oldValue: oldValue,
        newValue: newValue,
      );
}