import 'package:core/core.dart' show Box, Hive;

import '../entities/log_entry.dart';
import 'log_local_datasource.dart';

class LogLocalDataSourceImpl implements LogLocalDataSource {
  static const String _boxName = 'logs';
  Box<dynamic>? _logsBox;

  LogLocalDataSourceImpl() {
    try {
      _logsBox = Hive.box(_boxName);
    } catch (e) {
      print('Warning: Failed to initialize logs box: $e');
    }
  }

  @override
  Future<void> saveLog(LogEntry logEntry) async {
    try {
      if (_logsBox == null) return;
      await _logsBox!.put(logEntry.id, logEntry);
    } catch (e) {
      throw Exception('Failed to save log to local storage: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogs({
    LogLevel? level,
    LogCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      if (_logsBox == null) return <LogEntry>[];

      var logs = _logsBox!.values.cast<LogEntry>().toList();
      if (level != null) {
        logs = logs.where((log) => log.level == level).toList();
      }

      if (category != null) {
        logs = logs.where((log) => log.category == category).toList();
      }

      if (startDate != null) {
        logs =
            logs
                .where(
                  (log) =>
                      log.timestamp.isAfter(startDate) ||
                      log.timestamp.isAtSameMomentAs(startDate),
                )
                .toList();
      }

      if (endDate != null) {
        logs =
            logs
                .where(
                  (log) =>
                      log.timestamp.isBefore(endDate) ||
                      log.timestamp.isAtSameMomentAs(endDate),
                )
                .toList();
      }
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (limit != null && limit > 0) {
        logs = logs.take(limit).toList();
      }

      return logs;
    } catch (e) {
      throw Exception('Failed to get logs from local storage: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogsByCategory(
    LogCategory category, {
    int? limit,
  }) async {
    return getLogs(category: category, limit: limit);
  }

  @override
  Future<List<LogEntry>> getErrorLogs({int? limit}) async {
    return getLogs(level: LogLevel.error, limit: limit);
  }

  @override
  Future<void> clearOldLogs(int daysToKeep) async {
    try {
      if (_logsBox == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final keysToDelete = <String>[];

      for (final entry in _logsBox!.toMap().entries) {
        final logEntry = entry.value as LogEntry;
        if (logEntry.timestamp.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key.toString());
        }
      }

      await _logsBox!.deleteAll(keysToDelete);
    } catch (e) {
      throw Exception('Failed to clear old logs: $e');
    }
  }

  @override
  Future<void> clearAllLogs() async {
    try {
      if (_logsBox == null) return;
      await _logsBox!.clear();
    } catch (e) {
      throw Exception('Failed to clear all logs: $e');
    }
  }

  @override
  Future<Map<LogLevel, int>> getLogsCount() async {
    try {
      if (_logsBox == null) return <LogLevel, int>{};

      final counts = <LogLevel, int>{};
      for (final level in LogLevel.values) {
        counts[level] = 0;
      }
      for (final log in _logsBox!.values.cast<LogEntry>()) {
        counts[log.level] = (counts[log.level] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get logs count: $e');
    }
  }

  /// Initialize the logs box (called during app initialization)
  static Future<void> initBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<LogEntry>(_boxName);
    }
  }

  /// Close the logs box (called during app termination)
  static Future<void> closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box<LogEntry>(_boxName).close();
    }
  }
}
