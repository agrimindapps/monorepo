import 'package:core/core.dart';
import 'log_local_datasource.dart';

/// Implementation without persistence - Hive removed from app-petiveti
/// Logs are printed to console only
///
/// For production logging, consider implementing Drift-based persistence
/// or using external logging services (Sentry, Firebase Crashlytics, etc)
class LogLocalDataSourceImpl implements LogLocalDataSource {
  LogLocalDataSourceImpl();

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
    // No-op - no persistence
  }

  @override
  Future<void> clearAllLogs() async {
    // No-op - no persistence
  }

  @override
  Future<Map<LogLevel, int>> getLogsCount() async {
    return {}; // No persistence
  }
}
