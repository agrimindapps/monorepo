import '../entities/log_entry.dart';

abstract class LogLocalDataSource {
  /// Save a log entry to local storage
  Future<void> saveLog(LogEntry logEntry);

  /// Get logs with optional filtering
  Future<List<LogEntry>> getLogs({
    LogLevel? level,
    LogCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get logs by category
  Future<List<LogEntry>> getLogsByCategory(
    LogCategory category, {
    int? limit,
  });

  /// Get error logs
  Future<List<LogEntry>> getErrorLogs({
    int? limit,
  });

  /// Clear old logs (older than specified days)
  Future<void> clearOldLogs(int daysToKeep);

  /// Clear all logs
  Future<void> clearAllLogs();

  /// Get count of logs by level
  Future<Map<LogLevel, int>> getLogsCount();
}
