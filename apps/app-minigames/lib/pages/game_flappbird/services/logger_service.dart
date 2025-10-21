// Dart imports:
import 'dart:developer' as developer;

/// Service for centralized logging throughout the Flappy Bird game
class LoggerService {
  static const String _gameTag = 'FlappyBird';

  /// Log an informational message
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _gameTag,
      level: 800, // Info level
    );
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _gameTag,
      level: 900, // Warning level
    );
  }

  /// Log an error message with optional error object and stack trace
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    developer.log(
      message,
      name: tag ?? _gameTag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a debug message (only in debug mode)
  static void debug(String message, {String? tag}) {
    assert(() {
      developer.log(
        message,
        name: tag ?? _gameTag,
        level: 700, // Debug level
      );
      return true;
    }());
  }
}
