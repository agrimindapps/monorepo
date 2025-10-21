// Dart imports:
import 'dart:developer' as developer;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../constants/meditacao_constants.dart';

/// Log levels for structured logging
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Log entry with structured data
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? component;
  final Map<String, dynamic>? context;
  final String? stackTrace;
  final Object? error;

  LogEntry({
    required this.level,
    required this.message,
    this.component,
    this.context,
    this.stackTrace,
    this.error,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'component': component,
      'context': context,
      'stackTrace': stackTrace,
      'error': error?.toString(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name.toUpperCase()}] ');
    if (component != null) buffer.write('[$component] ');
    buffer.write(message);
    if (context != null && context!.isNotEmpty) {
      buffer.write(' - Context: $context');
    }
    if (error != null) buffer.write(' - Error: $error');
    return buffer.toString();
  }
}

/// Professional logging service for meditation module
class MeditacaoLoggerService {
  static final MeditacaoLoggerService _instance = MeditacaoLoggerService._internal();
  factory MeditacaoLoggerService() => _instance;
  MeditacaoLoggerService._internal();

  static const String _component = 'Meditacao';
  
  // Configuration
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static bool _enableConsoleOutput = true;
  static bool _enableDevLog = true;
  
  // Store recent logs for debugging
  final List<LogEntry> _recentLogs = [];

  /// Configure minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Enable/disable console output
  static void setConsoleOutput(bool enabled) {
    _enableConsoleOutput = enabled;
  }

  /// Enable/disable developer log
  static void setDevLog(bool enabled) {
    _enableDevLog = enabled;
  }

  // ========================================================================
  // MAIN LOGGING METHODS
  // ========================================================================

  /// Log verbose message (very detailed debugging)
  void verbose(String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
  }) {
    _log(LogLevel.verbose, message, 
         component: component, context: context, error: error);
  }

  /// Log debug message (general debugging)
  void debug(String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
  }) {
    _log(LogLevel.debug, message, 
         component: component, context: context, error: error);
  }

  /// Log info message (general information)
  void info(String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
  }) {
    _log(LogLevel.info, message, 
         component: component, context: context, error: error);
  }

  /// Log warning message (potential issues)
  void warning(String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
  }) {
    _log(LogLevel.warning, message, 
         component: component, context: context, error: error);
  }

  /// Log error message (errors that don't crash the app)
  void error(String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, 
         component: component, context: context, error: error,
         stackTrace: stackTrace?.toString());
  }

  /// Log fatal message (critical errors)
  void fatal(String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.fatal, message, 
         component: component, context: context, error: error,
         stackTrace: stackTrace?.toString());
  }

  // ========================================================================
  // SPECIALIZED LOGGING METHODS FOR MEDITATION MODULE
  // ========================================================================

  /// Log meditation session operations
  void logSessionOperation(String operation, {
    int? duration,
    String? type,
    String? mood,
    bool success = true,
    Object? error,
  }) {
    final context = <String, dynamic>{
      'operation': operation,
      'success': success,
    };
    
    if (duration != null) context['duration'] = duration;
    if (type != null) context['type'] = type;
    if (mood != null) context['mood'] = mood;
    
    if (success) {
      info('Meditation session operation: $operation', 
           component: 'SessionOps', context: context);
    } else {
      this.error('Meditation session operation failed: $operation', 
            component: 'SessionOps', context: context, error: error);
    }
  }

  /// Log timer operations
  void logTimerOperation(String operation, {
    int? duration,
    int? elapsed,
    bool success = true,
    Object? error,
  }) {
    final context = <String, dynamic>{
      'operation': operation,
      'success': success,
    };
    
    if (duration != null) context['duration'] = duration;
    if (elapsed != null) context['elapsed'] = elapsed;
    
    if (success) {
      debug('Timer operation: $operation', 
           component: 'Timer', context: context);
    } else {
      this.error('Timer operation failed: $operation', 
            component: 'Timer', context: context, error: error);
    }
  }

  /// Log audio operations
  void logAudioOperation(String operation, {
    String? audioFile,
    double? volume,
    bool success = true,
    Object? error,
  }) {
    final context = <String, dynamic>{
      'operation': operation,
      'success': success,
    };
    
    if (audioFile != null) context['audioFile'] = audioFile;
    if (volume != null) context['volume'] = volume;
    
    if (success) {
      debug('Audio operation: $operation', 
           component: 'Audio', context: context);
    } else {
      this.error('Audio operation failed: $operation', 
            component: 'Audio', context: context, error: error);
    }
  }

  /// Log achievement operations
  void logAchievementOperation(String operation, {
    String? achievementId,
    bool unlocked = false,
    Object? error,
  }) {
    final context = <String, dynamic>{
      'operation': operation,
      'unlocked': unlocked,
    };
    
    if (achievementId != null) context['achievementId'] = achievementId;
    
    if (unlocked) {
      info('Achievement unlocked: $operation', 
           component: 'Achievement', context: context);
    } else {
      debug('Achievement operation: $operation', 
           component: 'Achievement', context: context);
    }
  }

  /// Log data persistence operations
  void logPersistenceOperation(String operation, {
    String? dataType,
    int? recordCount,
    bool success = true,
    Object? error,
  }) {
    final context = <String, dynamic>{
      'operation': operation,
      'success': success,
    };
    
    if (dataType != null) context['dataType'] = dataType;
    if (recordCount != null) context['recordCount'] = recordCount;
    
    if (success) {
      debug('Persistence operation: $operation', 
           component: 'Persistence', context: context);
    } else {
      this.error('Persistence operation failed: $operation', 
            component: 'Persistence', context: context, error: error);
    }
  }

  /// Log performance metrics
  void logPerformance(String operation, Duration duration, {
    Map<String, dynamic>? metrics,
  }) {
    final context = <String, dynamic>{
      'operation': operation,
      'durationMs': duration.inMilliseconds,
    };
    
    if (metrics != null) context.addAll(metrics);
    
    if (duration.inMilliseconds > 1000) {
      warning('Slow operation detected: $operation (${duration.inMilliseconds}ms)',
              component: 'Performance', context: context);
    } else {
      debug('Operation completed: $operation (${duration.inMilliseconds}ms)',
            component: 'Performance', context: context);
    }
  }

  /// Log user interactions
  void logUserInteraction(String action, {
    String? screen,
    Map<String, dynamic>? parameters,
  }) {
    final context = <String, dynamic>{
      'action': action,
    };
    
    if (screen != null) context['screen'] = screen;
    if (parameters != null) context.addAll(parameters);
    
    info('User interaction: $action', 
         component: 'UI', context: context);
  }

  // ========================================================================
  // CORE LOGGING IMPLEMENTATION
  // ========================================================================

  void _log(LogLevel level, String message, {
    String? component,
    Map<String, dynamic>? context,
    Object? error,
    String? stackTrace,
  }) {
    // Check if this level should be logged
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      component: component ?? _component,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );

    // Store in recent logs
    _recentLogs.add(entry);
    if (_recentLogs.length > MeditacaoConstants.maxCacheSessoes) {
      _recentLogs.removeAt(0);
    }

    // Output to different targets
    _outputToConsole(entry);
    _outputToDevLog(entry);
    _outputToExternalServices(entry);
  }

  void _outputToConsole(LogEntry entry) {
    if (!_enableConsoleOutput) return;
    
    // Use appropriate print method based on level
    switch (entry.level) {
      case LogLevel.verbose:
      case LogLevel.debug:
        if (kDebugMode) debugPrint(entry.toString());
        break;
      case LogLevel.info:
        debugPrint(entry.toString());
        break;
      case LogLevel.warning:
      case LogLevel.error:
      case LogLevel.fatal:
        // In production, you might want to send these to a logging service
        debugPrint(entry.toString());
        break;
    }
  }

  void _outputToDevLog(LogEntry entry) {
    if (!_enableDevLog || !kDebugMode) return;
    
    developer.log(
      entry.message,
      time: entry.timestamp,
      level: _getDevLogLevel(entry.level),
      name: entry.component ?? _component,
      error: entry.error,
      stackTrace: entry.stackTrace != null 
          ? StackTrace.fromString(entry.stackTrace!) 
          : null,
    );
  }

  void _outputToExternalServices(LogEntry entry) {
    // In production, send to external logging services
    // Examples:
    // - Firebase Crashlytics for errors
    // - Custom analytics for user interactions
    // - APM tools for performance monitoring
    
    if (kReleaseMode && (entry.level == LogLevel.error || entry.level == LogLevel.fatal)) {
      // FirebaseCrashlytics.instance.log(entry.toString());
      // if (entry.error != null) {
      //   FirebaseCrashlytics.instance.recordError(
      //     entry.error,
      //     entry.stackTrace != null ? StackTrace.fromString(entry.stackTrace!) : null,
      //   );
      // }
    }
  }

  int _getDevLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 500;
      case LogLevel.debug:
        return 700;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  // ========================================================================
  // UTILITY METHODS
  // ========================================================================

  /// Get recent log entries for debugging
  List<LogEntry> getRecentLogs({LogLevel? minLevel}) {
    if (minLevel == null) return List.from(_recentLogs);
    
    return _recentLogs
        .where((entry) => entry.level.index >= minLevel.index)
        .toList();
  }

  /// Clear recent logs
  void clearRecentLogs() {
    _recentLogs.clear();
  }

  /// Get logs as formatted string
  String getLogsAsString({LogLevel? minLevel, int? maxEntries}) {
    var logs = getRecentLogs(minLevel: minLevel);
    
    if (maxEntries != null && logs.length > maxEntries) {
      logs = logs.sublist(logs.length - maxEntries);
    }
    
    return logs.map((entry) => entry.toString()).join('\n');
  }

  // ========================================================================
  // STATIC CONVENIENCE METHODS
  // ========================================================================

  static MeditacaoLoggerService get instance => _instance;
  
  static void v(String message, {String? component, Map<String, dynamic>? context}) {
    _instance.verbose(message, component: component, context: context);
  }
  
  static void d(String message, {String? component, Map<String, dynamic>? context}) {
    _instance.debug(message, component: component, context: context);
  }
  
  static void i(String message, {String? component, Map<String, dynamic>? context}) {
    _instance.info(message, component: component, context: context);
  }
  
  static void w(String message, {String? component, Map<String, dynamic>? context, Object? error}) {
    _instance.warning(message, component: component, context: context, error: error);
  }
  
  static void e(String message, {String? component, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    _instance.error(message, component: component, context: context, error: error, stackTrace: stackTrace);
  }
  
  static void f(String message, {String? component, Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    _instance.fatal(message, component: component, context: context, error: error, stackTrace: stackTrace);
  }
}
