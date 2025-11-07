import 'dart:convert';

import 'package:core/core.dart' show injectable;
import 'package:flutter/foundation.dart';

import 'app_error.dart';

/// Service for structured error logging
/// Provides consistent error logging across the application
@injectable
class ErrorLogger {
  static const String _logPrefix = '🚨 [ERROR]';
  static const String _warningPrefix = '⚠️ [WARNING]';
  static const String _infoPrefix = 'ℹ️ [INFO]';

  /// Logs an AppError with structured data
  void logError(
    AppError error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalContext,
  }) {
    final errorData = error.toMap();
    if (additionalContext != null) {
      errorData['additionalContext'] = additionalContext;
    }
    if (stackTrace != null) {
      errorData['stackTrace'] = stackTrace.toString();
    }

    _logWithSeverity(error.severity, errorData);
    if (kReleaseMode && error.severity.index >= ErrorSeverity.error.index) {
      _sendToCrashReporting(error, stackTrace, additionalContext);
    }
  }

  /// Logs a generic exception
  void logException(
    Exception exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    final errorData = {
      'type': 'Exception',
      'message': exception.toString(),
      'context': context,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (stackTrace != null) {
      errorData['stackTrace'] = stackTrace.toString();
    }

    _logWithSeverity(ErrorSeverity.error, errorData);

    if (kReleaseMode) {
      _sendToCrashReporting(
        UnexpectedError(
          message: exception.toString(),
          technicalDetails: stackTrace?.toString(),
          metadata: metadata,
        ),
        stackTrace,
        {'context': context},
      );
    }
  }

  /// Logs warning messages
  void logWarning(
    String message, {
    Map<String, dynamic>? metadata,
    String? context,
  }) {
    final logData = {
      'level': 'WARNING',
      'message': message,
      'context': context,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logWithSeverity(ErrorSeverity.warning, logData);
  }

  /// Logs info messages
  void logInfo(
    String message, {
    Map<String, dynamic>? metadata,
    String? context,
  }) {
    final logData = {
      'level': 'INFO',
      'message': message,
      'context': context,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logWithSeverity(ErrorSeverity.info, logData);
  }

  /// Logs provider state changes for debugging - DISABLED for cleaner console
  void logProviderStateChange(
    String providerName,
    String stateName,
    Map<String, dynamic>? stateData,
  ) {
    return;
  }

  /// Logs retry attempts
  void logRetryAttempt(
    String operation,
    int attemptNumber,
    int maxAttempts,
    AppError? lastError,
  ) {
    final logData = {
      'type': 'RETRY_ATTEMPT',
      'operation': operation,
      'attempt': attemptNumber,
      'maxAttempts': maxAttempts,
      'lastError': lastError?.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logWithSeverity(ErrorSeverity.warning, logData);
  }

  /// Logs network requests for debugging
  void logNetworkRequest(
    String method,
    String url,
    int? statusCode,
    Duration? duration, {
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
    String? error,
  }) {
    if (!kDebugMode) return;

    final logData = {
      'type': 'NETWORK_REQUEST',
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'duration': duration?.inMilliseconds,
      'requestData': requestData,
      'responseData': responseData,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final prefix = error != null ? '🌐❌ [NETWORK_ERROR]' : '🌐 [NETWORK]';
    debugPrint('$prefix ${_formatLogData(logData)}');
  }

  void _logWithSeverity(ErrorSeverity severity, Map<String, dynamic> data) {
    final formattedLog = _formatLogData(data);

    switch (severity) {
      case ErrorSeverity.info:
        debugPrint('$_infoPrefix $formattedLog');
        break;
      case ErrorSeverity.warning:
        debugPrint('$_warningPrefix $formattedLog');
        break;
      case ErrorSeverity.error:
      case ErrorSeverity.critical:
      case ErrorSeverity.fatal:
        debugPrint('$_logPrefix $formattedLog');
        if (kDebugMode && data.containsKey('stackTrace')) {
          debugPrint('Stack Trace:\n${data['stackTrace']}');
        }
        break;
    }
  }

  String _formatLogData(Map<String, dynamic> data) {
    try {
      if (kDebugMode) {
        final buffer = StringBuffer();
        data.forEach((key, value) {
          if (key != 'stackTrace') {
            buffer.write('$key: ${_formatValue(value)} ');
          }
        });
        return buffer.toString().trim();
      } else {
        return jsonEncode(data);
      }
    } catch (e) {
      return 'Error formatting log data: ${data.toString()}';
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is Map || value is List) {
      try {
        return jsonEncode(value);
      } catch (e) {
        return value.toString();
      }
    }
    return value.toString();
  }

  void _sendToCrashReporting(
    AppError error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalContext,
  ) {
    if (kReleaseMode) {
      print('CRASH_REPORT: ${error.toMap()}');
    }
  }
}

/// Extension to easily log errors from any context
extension AppErrorLogging on AppError {
  /// Log this error using the default logger
  void log({StackTrace? stackTrace, Map<String, dynamic>? additionalContext}) {
    final logger = ErrorLogger();
    logger.logError(
      this,
      stackTrace: stackTrace,
      additionalContext: additionalContext,
    );
  }
}

/// Utility class for common error scenarios
class ErrorLoggerUtils {
  static final ErrorLogger _logger = ErrorLogger();

  /// Log provider operation errors
  static void logProviderError(
    String providerName,
    String operation,
    AppError error, {
    StackTrace? stackTrace,
  }) {
    _logger.logError(
      error,
      stackTrace: stackTrace,
      additionalContext: {'provider': providerName, 'operation': operation},
    );
  }

  /// Log repository operation errors
  static void logRepositoryError(
    String repositoryName,
    String method,
    AppError error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? params,
  }) {
    _logger.logError(
      error,
      stackTrace: stackTrace,
      additionalContext: {
        'repository': repositoryName,
        'method': method,
        'params': params,
      },
    );
  }

  /// Log UI interaction errors
  static void logUIError(
    String screenName,
    String action,
    AppError error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _logger.logError(
      error,
      stackTrace: stackTrace,
      additionalContext: {
        'screen': screenName,
        'action': action,
        'uiContext': context,
      },
    );
  }
}
