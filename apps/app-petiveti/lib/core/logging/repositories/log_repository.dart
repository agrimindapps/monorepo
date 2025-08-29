import 'package:dartz/dartz.dart';
import '../../error/failures.dart';
import '../entities/log_entry.dart';

abstract class LogRepository {
  /// Save a log entry locally
  Future<Either<Failure, void>> saveLog(LogEntry logEntry);

  /// Get logs with optional filters
  Future<Either<Failure, List<LogEntry>>> getLogs({
    LogLevel? level,
    LogCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get logs by category
  Future<Either<Failure, List<LogEntry>>> getLogsByCategory(
    LogCategory category, {
    int? limit,
  });

  /// Get error logs
  Future<Either<Failure, List<LogEntry>>> getErrorLogs({
    int? limit,
  });

  /// Clear old logs (older than specified days)
  Future<Either<Failure, void>> clearOldLogs(int daysToKeep);

  /// Clear all logs
  Future<Either<Failure, void>> clearAllLogs();

  /// Get logs count by level
  Future<Either<Failure, Map<LogLevel, int>>> getLogsCount();

  /// Export logs as JSON
  Future<Either<Failure, String>> exportLogs({
    DateTime? startDate,
    DateTime? endDate,
  });
}