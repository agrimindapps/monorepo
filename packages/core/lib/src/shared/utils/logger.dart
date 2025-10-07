import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

/// Simple logger utility used across the project.
/// Allows enabling/disabling logs per level.
class Logger {
  static LogLevel _minLevel = LogLevel.debug;

  /// Set the minimum level that will be printed.
  static void setLevel(LogLevel level) => _minLevel = level;

  static bool _shouldLog(LogLevel level) => level.index >= _minLevel.index;

  static void debug(String message) {
    if (_shouldLog(LogLevel.debug)) {
      developer.log(message, name: 'DEBUG');
    }
  }

  static void info(String message) {
    if (_shouldLog(LogLevel.info)) {
      developer.log(message, name: 'INFO');
    }
  }

  static void warning(String message) {
    if (_shouldLog(LogLevel.warning)) {
      developer.log(message, name: 'WARNING');
    }
  }

  static void error(String message) {
    if (_shouldLog(LogLevel.error)) {
      developer.log(message, name: 'ERROR');
    }
  }
}
