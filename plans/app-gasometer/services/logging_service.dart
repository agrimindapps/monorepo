// Flutter imports:
import 'package:flutter/foundation.dart';

/// Log levels enum
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Professional logging service for the Gasometer app
/// 
/// This service provides structured logging with different levels and 
/// environment-aware behavior (development vs production)
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  static LoggingService get instance => _instance;
  
  LoggingService._internal();

  /// Current minimum log level (configurable based on build mode)
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  /// Set minimum log level
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Debug logging - only shown in debug mode
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Info logging - general information
  void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Warning logging - potential issues
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Error logging - actual errors
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Don't log if below minimum level
    if (level.index < _minLevel.index) return;

    // In production, only log warnings and errors
    if (!kDebugMode && level.index < LogLevel.warning.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padLeft(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    
    final logMessage = '$timestamp $levelStr: $tagStr$message';
    
    // In debug mode, use debugPrint for better IDE integration
    if (kDebugMode) {
      debugPrint(logMessage);
      if (error != null) {
        debugPrint('  Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('  Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      }
    } else {
      // In production, could integrate with crash reporting services like Firebase Crashlytics
      // For now, we suppress logs in production to avoid information leakage
      // Only critical errors could be logged to external services here
      if (level.index >= LogLevel.error.index) {
        // TODO: Integrate with Firebase Crashlytics or similar service
        // FirebaseCrashlytics.instance.log(logMessage);
      }
    }
  }

  /// Log repository operations
  void repository(String repository, String operation, {Object? error}) {
    if (error != null) {
      this.error('$repository.$operation failed', tag: 'REPO', error: error);
    } else {
      debug('$repository.$operation', tag: 'REPO');
    }
  }

  /// Log controller lifecycle events
  void controller(String controller, String event, {Object? data}) {
    debug('$controller.$event${data != null ? ': $data' : ''}', tag: 'CTRL');
  }

  /// Log service operations
  void service(String service, String operation, {Object? error, Object? data}) {
    if (error != null) {
      this.error('$service.$operation failed', tag: 'SVC', error: error);
    } else {
      debug('$service.$operation${data != null ? ': $data' : ''}', tag: 'SVC');
    }
  }

  /// Log UI operations
  void ui(String component, String action, {Object? data}) {
    debug('$component.$action${data != null ? ': $data' : ''}', tag: 'UI');
  }
}
