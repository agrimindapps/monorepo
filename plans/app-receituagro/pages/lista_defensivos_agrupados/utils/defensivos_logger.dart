// Flutter imports:
import 'package:flutter/foundation.dart';

/// Log levels for structured logging
enum DefensivosLogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Log categories for better organization
enum DefensivosLogCategory {
  initialization,
  dataLoading,
  filtering,
  navigation,
  repository,
  ui,
  performance,
  cleanup,
  error,
}

/// Structured logging utility for the Defensivos module
class DefensivosLogger {
  static const String _moduleTag = 'Defensivos';
  
  /// Main logging method with structured output
  static void log(
    DefensivosLogLevel level,
    DefensivosLogCategory category,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
    String? operation,
  }) {
    // Only log in debug mode for production optimization
    if (!kDebugMode && level != DefensivosLogLevel.critical) {
      return;
    }
    
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final levelIcon = _getLevelIcon(level);
    final categoryTag = category.name.toUpperCase();
    
    final logPrefix = '[$timestamp] $levelIcon [$_moduleTag:$categoryTag]';
    
    if (operation != null) {
      debugPrint('$logPrefix [$operation] $message');
    } else {
      debugPrint('$logPrefix $message');
    }
    
    // Log additional data if provided
    if (data != null && data.isNotEmpty) {
      debugPrint('$logPrefix   └── Data: $data');
    }
    
    // Log error details if provided
    if (error != null) {
      debugPrint('$logPrefix   └── Error: $error');
      if (stackTrace != null && kDebugMode) {
        debugPrint('$logPrefix   └── Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      }
    }
  }
  
  /// Convenience method for debug logs
  static void debug(
    DefensivosLogCategory category,
    String message, {
    Map<String, dynamic>? data,
    String? operation,
  }) {
    log(DefensivosLogLevel.debug, category, message, 
        data: data, operation: operation);
  }
  
  /// Convenience method for info logs
  static void info(
    DefensivosLogCategory category,
    String message, {
    Map<String, dynamic>? data,
    String? operation,
  }) {
    log(DefensivosLogLevel.info, category, message, 
        data: data, operation: operation);
  }
  
  /// Convenience method for warning logs
  static void warning(
    DefensivosLogCategory category,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    String? operation,
  }) {
    log(DefensivosLogLevel.warning, category, message, 
        data: data, error: error, operation: operation);
  }
  
  /// Convenience method for error logs
  static void error(
    DefensivosLogCategory category,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
    String? operation,
  }) {
    log(DefensivosLogLevel.error, category, message, 
        data: data, error: error, stackTrace: stackTrace, operation: operation);
  }
  
  /// Convenience method for critical logs (always shown, even in production)
  static void critical(
    DefensivosLogCategory category,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
    String? operation,
  }) {
    log(DefensivosLogLevel.critical, category, message, 
        data: data, error: error, stackTrace: stackTrace, operation: operation);
  }
  
  /// Logs method entry with parameters
  static void methodEntry(String methodName, [Map<String, dynamic>? params]) {
    if (!kDebugMode) return;
    
    debug(DefensivosLogCategory.performance, 'Method entry: $methodName',
          data: params, operation: 'ENTRY');
  }
  
  /// Logs method exit with results
  static void methodExit(String methodName, [Map<String, dynamic>? results]) {
    if (!kDebugMode) return;
    
    debug(DefensivosLogCategory.performance, 'Method exit: $methodName',
          data: results, operation: 'EXIT');
  }
  
  /// Logs data loading operations
  static void dataOperation(String operation, {
    required int itemCount,
    String? category,
    bool? success,
    Duration? duration,
  }) {
    final data = <String, dynamic>{
      'itemCount': itemCount,
      if (category != null) 'category': category,
      if (success != null) 'success': success,
      if (duration != null) 'duration': '${duration.inMilliseconds}ms',
    };
    
    info(DefensivosLogCategory.dataLoading, operation, data: data);
  }
  
  /// Logs filtering operations
  static void filterOperation(String searchText, {
    required int originalCount,
    required int filteredCount,
    Duration? duration,
  }) {
    final data = {
      'searchText': searchText.isEmpty ? '(empty)' : '"$searchText"',
      'originalCount': originalCount,
      'filteredCount': filteredCount,
      'filtered': originalCount - filteredCount,
      if (duration != null) 'duration': '${duration.inMilliseconds}ms',
    };
    
    info(DefensivosLogCategory.filtering, 'Filter applied', data: data);
  }
  
  /// Logs UI state changes
  static void stateChange(String stateName, dynamic oldValue, dynamic newValue) {
    if (!kDebugMode) return;
    
    final data = {
      'from': oldValue?.toString() ?? 'null',
      'to': newValue?.toString() ?? 'null',
    };
    
    debug(DefensivosLogCategory.ui, 'State changed: $stateName', data: data);
  }
  
  /// Logs performance metrics
  static void performance(String operation, Duration duration, {
    Map<String, dynamic>? metrics,
  }) {
    final data = {
      'duration': '${duration.inMilliseconds}ms',
      ...?metrics,
    };
    
    if (duration.inMilliseconds > 1000) {
      warning(DefensivosLogCategory.performance, 
              'Slow operation detected: $operation', data: data);
    } else {
      debug(DefensivosLogCategory.performance, 
            'Performance: $operation', data: data);
    }
  }
  
  /// Gets appropriate icon for log level
  static String _getLevelIcon(DefensivosLogLevel level) {
    switch (level) {
      case DefensivosLogLevel.debug:
        return 'DEBUG';
      case DefensivosLogLevel.info:
        return 'INFO';
      case DefensivosLogLevel.warning:
        return 'WARN';
      case DefensivosLogLevel.error:
        return 'ERROR';
      case DefensivosLogLevel.critical:
        return 'CRITICAL';
    }
  }
}

/// Extension for easier logging within methods
extension DefensivosLoggerExtension on Object {
  void logDebug(DefensivosLogCategory category, String message, {
    Map<String, dynamic>? data,
    String? operation,
  }) {
    DefensivosLogger.debug(category, message, data: data, operation: operation);
  }
  
  void logInfo(DefensivosLogCategory category, String message, {
    Map<String, dynamic>? data,
    String? operation,
  }) {
    DefensivosLogger.info(category, message, data: data, operation: operation);
  }
  
  void logWarning(DefensivosLogCategory category, String message, {
    Map<String, dynamic>? data,
    Object? error,
    String? operation,
  }) {
    DefensivosLogger.warning(category, message, 
                           data: data, error: error, operation: operation);
  }
  
  void logError(DefensivosLogCategory category, String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
    String? operation,
  }) {
    DefensivosLogger.error(category, message, 
                         data: data, error: error, 
                         stackTrace: stackTrace, operation: operation);
  }
}
