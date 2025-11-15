/// **ISP - Interface Segregation Principle**
/// **DIP - Dependency Inversion Principle**
///
/// Abstraction for logging service - enables dependency inversion
///
/// By depending on this interface instead of concrete LoggingServiceImpl:
/// - All services depend on abstraction, not concrete implementation
/// - Easy to swap with mock for testing (just override the provider)
/// - Testable without hitting real logging backend
/// - Can change implementation without affecting dependents
///
/// Usage in providers (see logging_providers.dart):
///   @riverpod
///   ILoggingService loggingService(LoggingServiceRef ref) {
///     return LoggingServiceImpl();  // Can be overridden for testing
///   }
///
/// Usage in notifiers (injected via provider):
///   class MyNotifier {
///     MyNotifier(this._logging);
///     final ILoggingService _logging;
///
///     Future<void> doSomething() async {
///       await _logging.logInfo(...);
///     }
///   }
abstract class ILoggingService {
  /// Log an info message
  Future<void> logInfo({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  });

  /// Log a warning message
  Future<void> logWarning({
    required String context,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
    Duration? duration,
  });

  /// Log an error message
  Future<void> logError({
    required String context,
    required String operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    Duration? duration,
  });

  /// Log a timed operation
  Future<T> logTimedOperation<T>({
    required String context,
    required String operation,
    required String message,
    required Future<T> Function() operationFunction,
    Map<String, dynamic>? metadata,
  });

  /// Track analytics event
  Future<void> trackEvent({
    required String eventName,
    required String context,
    Map<String, dynamic>? parameters,
  });

  /// Track user action
  Future<void> trackUserAction({
    required String context,
    required String operation,
    required String action,
    Map<String, dynamic>? metadata,
  });

  /// Set the current user ID for log entries
  void setUserId(String? userId);

  /// Clean up old logs periodically
  Future<void> performMaintenance({int daysToKeep = 30});

  /// Get logging statistics
  Future<Map<String, dynamic>> getLoggingStats();
}
