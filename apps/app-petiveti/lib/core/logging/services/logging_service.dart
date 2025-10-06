import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide LogEntry, LogLevel;

import '../../utils/uuid_generator.dart';
import '../entities/log_entry.dart';
import '../repositories/log_repository.dart';

/// Centralized logging service that handles all application logging
class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance => _instance ??= LoggingService._();

  LoggingService._();

  LogRepository? _logRepository;
  IAnalyticsRepository? _analyticsRepository;
  ICrashlyticsRepository? _crashlyticsRepository;
  String? _currentUserId;

  /// Initialize the logging service with dependencies
  Future<void> initialize({
    required LogRepository logRepository,
    IAnalyticsRepository? analyticsRepository,
    ICrashlyticsRepository? crashlyticsRepository,
  }) async {
    _logRepository = logRepository;
    _analyticsRepository = analyticsRepository;
    _crashlyticsRepository = crashlyticsRepository;
  }

  /// Set the current user ID for log entries
  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Log an info message
  Future<void> logInfo({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _log(
      level: LogLevel.info,
      category: category,
      operation: operation,
      message: message,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log a warning message
  Future<void> logWarning({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _log(
      level: LogLevel.warning,
      category: category,
      operation: operation,
      message: message,
      metadata: metadata,
      duration: duration,
    );
  }

  /// Log an error message
  Future<void> logError({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _log(
      level: LogLevel.error,
      category: category,
      operation: operation,
      message: message,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      metadata: metadata,
      duration: duration,
    );
    await _reportToCrashlytics(error, stackTrace, {
      'category': category.name,
      'operation': operation.name,
      'message': message,
      'userId': _currentUserId,
      ...?metadata,
    });
  }

  /// Log a timed operation
  Future<T> logTimedOperation<T>({
    required LogCategory category,
    required LogOperation operation,
    required String message,
    required Future<T> Function() operationFunction,
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    await logInfo(
      category: category,
      operation: operation,
      message: 'Starting $message',
      metadata: metadata,
    );

    try {
      final result = await operationFunction();
      stopwatch.stop();

      await logInfo(
        category: category,
        operation: operation,
        message: 'Completed $message',
        metadata: metadata,
        duration: stopwatch.elapsed,
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();

      await logError(
        category: category,
        operation: operation,
        message: 'Failed $message',
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
        duration: stopwatch.elapsed,
      );

      rethrow;
    }
  }

  /// Track analytics event
  Future<void> trackEvent({
    required String eventName,
    required LogCategory category,
    Map<String, dynamic>? parameters,
  }) async {
    final enhancedParameters = {
      'category': category.name,
      'user_id': _currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
      ...?parameters,
    };
    await logInfo(
      category: category,
      operation: LogOperation.create, // Using create as generic operation for events
      message: 'Analytics event: $eventName',
      metadata: enhancedParameters,
    );
    await _analyticsRepository?.logEvent(
      eventName,
      parameters: enhancedParameters,
    );
  }

  /// Track user action
  Future<void> trackUserAction({
    required LogCategory category,
    required LogOperation operation,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await logInfo(
      category: category,
      operation: operation,
      message: 'User action: $action',
      metadata: {
        'action': action,
        'user_id': _currentUserId,
        ...?metadata,
      },
    );

    await trackEvent(
      eventName: 'user_action',
      category: category,
      parameters: {
        'action': action,
        'operation': operation.name,
        ...?metadata,
      },
    );
  }

  /// Core logging method
  Future<void> _log({
    required LogLevel level,
    required LogCategory category,
    required LogOperation operation,
    required String message,
    String? error,
    String? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    final logEntry = LogEntry(
      id: UuidGenerator.generate(),
      timestamp: DateTime.now(),
      level: level,
      category: category,
      operation: operation,
      message: message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
      userId: _currentUserId,
      duration: duration,
    );
    await _logRepository?.saveLog(logEntry);
    developer.log(
      logEntry.toString(),
      name: 'PetivetiLog',
      level: _getLogLevel(level),
      error: error,
      stackTrace: stackTrace != null ? StackTrace.fromString(stackTrace) : null,
    );
  }

  /// Report error to Crashlytics
  Future<void> _reportToCrashlytics(
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic> context,
  ) async {
    try {
      for (final entry in context.entries) {
        await _crashlyticsRepository?.setCustomKey(
          key: entry.key,
          value: entry.value.toString(),
        );
      }
      await _crashlyticsRepository?.recordError(
        exception: error,
        stackTrace: stackTrace ?? StackTrace.empty,
        fatal: false,
        additionalInfo: context,
      );
    } catch (e) {
      developer.log('Failed to report to Crashlytics: $e', name: 'LoggingService');
    }
  }

  /// Convert LogLevel to developer log level
  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  /// Clean up old logs periodically
  Future<void> performMaintenance({int daysToKeep = 30}) async {
    try {
      await _logRepository?.clearOldLogs(daysToKeep);
      await logInfo(
        category: LogCategory.system,
        operation: LogOperation.delete,
        message: 'Cleaned up logs older than $daysToKeep days',
      );
    } catch (e) {
      await logError(
        category: LogCategory.system,
        operation: LogOperation.delete,
        message: 'Failed to clean up old logs',
        error: e,
      );
    }
  }

  /// Get logging statistics
  Future<Map<String, dynamic>> getLoggingStats() async {
    try {
      final countsResult = await _logRepository?.getLogsCount();
      Map<LogLevel, int> counts = {};
      
      countsResult?.fold(
        (failure) => counts = {},
        (success) => counts = success,
      );

      final totalLogs = counts.values.fold<int>(0, (int sum, int count) => sum + count);

      return {
        'total_logs': totalLogs,
        'by_level': counts.map<String, int>((LogLevel key, int value) => MapEntry(key.name, value)),
        'user_id': _currentUserId,
      };
    } catch (e) {
      return {
        'error': 'Failed to get logging stats: $e',
      };
    }
  }
}
