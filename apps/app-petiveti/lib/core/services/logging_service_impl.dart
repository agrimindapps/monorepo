import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../interfaces/logging_service.dart';
import '../logging/repositories/log_repository.dart';
import '../utils/uuid_generator.dart';

/// **DIP - Dependency Inversion Principle**
/// Concrete implementation of ILoggingService
/// Centralizes logging logic without singleton pattern
class LoggingServiceImpl implements ILoggingService {
  final LogRepository _logRepository;
  final IAnalyticsRepository? _analyticsRepository;
  final ICrashlyticsRepository? _crashlyticsRepository;

  String? _currentUserId;

  LoggingServiceImpl({
    required LogRepository logRepository,
    IAnalyticsRepository? analyticsRepository,
    ICrashlyticsRepository? crashlyticsRepository,
  }) : _logRepository = logRepository,
       _analyticsRepository = analyticsRepository,
       _crashlyticsRepository = crashlyticsRepository;

  @override
  void setUserId(String? userId) {
    _currentUserId = userId;
  }

  @override
  Future<void> logInfo({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _log(
      level: LogLevel.info,
      context: context,
      operation: operation,
      message: message,
      metadata: metadata,
      duration: duration,
    );
  }

  @override
  Future<void> logWarning({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _log(
      level: LogLevel.warning,
      context: context,
      operation: operation,
      message: message,
      metadata: metadata,
      duration: duration,
    );
  }

  @override
  Future<void> logError({
    required String context,
    required String operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    await _log(
      level: LogLevel.error,
      context: context,
      operation: operation,
      message: message,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      metadata: metadata,
      duration: duration,
    );
    await _reportToCrashlytics(error, stackTrace, {
      'context': context,
      'operation': operation,
      'message': message,
      'userId': _currentUserId,
      ...?metadata,
    });
  }

  @override
  Future<T> logTimedOperation<T>({
    required String context,
    required String operation,
    required String message,
    required Future<T> Function() operationFunction,
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();

    await logInfo(
      context: context,
      operation: operation,
      message: 'Starting $message',
      metadata: metadata,
    );

    try {
      final result = await operationFunction();
      stopwatch.stop();

      await logInfo(
        context: context,
        operation: operation,
        message: 'Completed $message',
        metadata: metadata,
        duration: stopwatch.elapsed,
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();

      await logError(
        context: context,
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

  @override
  @override
  Future<void> trackEvent({
    required String eventName,
    required String context,
    Map<String, dynamic>? parameters,
  }) async {
    final enhancedParameters = {
      'context': context,
      'user_id': _currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
      ...?parameters,
    };
    await logInfo(
      context: context,
      operation: 'analytics',
      message: 'Analytics event: $eventName',
      metadata: enhancedParameters,
    );
    await _analyticsRepository?.logEvent(
      eventName,
      parameters: enhancedParameters,
    );
  }

  @override
  Future<void> trackUserAction({
    required String context,
    required String operation,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await logInfo(
      context: context,
      operation: operation,
      message: 'User action: $action',
      metadata: {'action': action, 'user_id': _currentUserId, ...?metadata},
    );

    await trackEvent(
      eventName: 'user_action',
      context: context,
      parameters: {'action': action, 'operation': operation, ...?metadata},
    );
  }

  /// Core logging method
  Future<void> _log({
    required LogLevel level,
    required String context,
    required String operation,
    required String message,
    String? error,
    String? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  }) async {
    final logEntry = LogEntry(
      id: UuidGenerator.generate(),
      hora: DateTime.now(),
      level: level,
      context: context,
      descricao:
          '[$operation] $message${error != null ? ' | Error: $error' : ''}${stackTrace != null ? ' | StackTrace: $stackTrace' : ''}${metadata != null ? ' | Metadata: $metadata' : ''}${_currentUserId != null ? ' | User: $_currentUserId' : ''}${duration != null ? ' | Duration: $duration' : ''}',
    );
    await _logRepository.saveLog(logEntry);
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
      developer.log(
        'Failed to report to Crashlytics: $e',
        name: 'LoggingServiceImpl',
      );
    }
  }

  /// Convert LogLevel to developer log level
  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 300;
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }

  @override
  Future<void> performMaintenance({int daysToKeep = 30}) async {
    try {
      await _logRepository.clearOldLogs(daysToKeep);
      await logInfo(
        context: 'system',
        operation: 'maintenance',
        message: 'Cleaned up logs older than $daysToKeep days',
      );
    } catch (e) {
      await logError(
        context: 'system',
        operation: 'maintenance',
        message: 'Failed to clean up old logs',
        error: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getLoggingStats() async {
    try {
      final countsResult = await _logRepository.getLogsCount();
      Map<LogLevel, int> counts = {};

      countsResult.fold(
        (failure) => counts = {},
        (success) => counts = success,
      );

      final totalLogs = counts.values.fold<int>(
        0,
        (int sum, int count) => sum + count,
      );

      return {
        'total_logs': totalLogs,
        'by_level': counts.map<String, int>(
          (LogLevel key, int value) => MapEntry(key.name, value),
        ),
        'user_id': _currentUserId,
      };
    } catch (e) {
      return {'error': 'Failed to get logging stats: $e'};
    }
  }
}
