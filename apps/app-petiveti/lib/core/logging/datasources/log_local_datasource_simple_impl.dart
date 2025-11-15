import 'package:core/core.dart';
import 'log_local_datasource.dart';

/// Disabled implementation - Hive removed from app-petiveti
/// Logs are printed to console only
class LogLocalDataSourceSimpleImpl implements LogLocalDataSource {
  LogLocalDataSourceSimpleImpl();

  @override
  Future<void> saveLog(LogEntry logEntry) async {
    // Print to console only
    print(logEntry.toString());
  }

  @override
  Future<List<LogEntry>> getLogs({
    LogLevel? level,
    String? context,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return []; // No persistence - logs only printed to console
  }

  @override
  Future<List<LogEntry>> getLogsByCategory(String context, {int? limit}) async {
    return [];
  }

  @override
  Future<List<LogEntry>> getErrorLogs({int? limit}) async {
    return [];
  }

  @override
  Future<void> clearOldLogs(int daysToKeep) async {
    // No-op
  }

  @override
  Future<void> clearAllLogs() async {
    // No-op
  }

  @override
  Future<Map<LogLevel, int>> getLogsCount() async {
    return {};
  }
}
