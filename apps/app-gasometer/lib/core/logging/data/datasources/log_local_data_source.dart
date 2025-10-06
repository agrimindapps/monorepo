import 'package:core/core.dart' show Hive, Box;
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../entities/log_entry.dart';

abstract class LogLocalDataSource {
  Future<void> saveLog(LogEntry logEntry);
  Future<void> saveLogs(List<LogEntry> logEntries);
  Future<List<LogEntry>> getAllLogs();
  Future<List<LogEntry>> getLogsByCategory(String category);
  Future<List<LogEntry>> getLogsByLevel(String level);
  Future<List<LogEntry>> getLogsByOperation(String operation);
  Future<List<LogEntry>> getLogsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<LogEntry>> getUnsyncedLogs();
  Future<void> markLogsAsSynced(List<String> logIds);
  Future<void> deleteLog(String logId);
  Future<void> deleteAllLogs();
  Future<void> deleteLogsOlderThan(DateTime cutoffDate);
  Future<List<LogEntry>> searchLogs(String query);
  Future<Map<String, dynamic>> getLogStatistics();
}

@LazySingleton(as: LogLocalDataSource)
class LogLocalDataSourceImpl implements LogLocalDataSource {
  static const String _boxName = 'logs';
  Box<LogEntry>? _box;

  Future<Box<LogEntry>> get _logBox async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<LogEntry>(_boxName);
    }
    return _box!;
  }

  @override
  Future<void> saveLog(LogEntry logEntry) async {
    try {
      final box = await _logBox;
      await box.put(logEntry.id, logEntry);
    } catch (e) {
      throw CacheException('Failed to save log: $e');
    }
  }

  @override
  Future<void> saveLogs(List<LogEntry> logEntries) async {
    try {
      final box = await _logBox;
      final Map<String, LogEntry> logMap = {};
      for (final log in logEntries) {
        logMap[log.id] = log;
      }
      await box.putAll(logMap);
    } catch (e) {
      throw CacheException('Failed to save logs: $e');
    }
  }

  @override
  Future<List<LogEntry>> getAllLogs() async {
    try {
      final box = await _logBox;
      return box.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw CacheException('Failed to get logs: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogsByCategory(String category) async {
    try {
      final box = await _logBox;
      return box.values.where((log) => log.category == category).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw CacheException('Failed to get logs by category: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogsByLevel(String level) async {
    try {
      final box = await _logBox;
      return box.values.where((log) => log.level == level).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw CacheException('Failed to get logs by level: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogsByOperation(String operation) async {
    try {
      final box = await _logBox;
      return box.values.where((log) => log.operation == operation).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw CacheException('Failed to get logs by operation: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final box = await _logBox;
      return box.values
          .where(
            (log) =>
                log.timestamp.isAfter(startDate) &&
                log.timestamp.isBefore(endDate),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw CacheException('Failed to get logs by period: $e');
    }
  }

  @override
  Future<List<LogEntry>> getUnsyncedLogs() async {
    try {
      final box = await _logBox;
      return box.values.where((log) => !log.synced).toList()..sort(
        (a, b) => a.timestamp.compareTo(b.timestamp),
      ); // Mais antigos primeiro
    } catch (e) {
      throw CacheException('Failed to get unsynced logs: $e');
    }
  }

  @override
  Future<void> markLogsAsSynced(List<String> logIds) async {
    try {
      final box = await _logBox;
      for (final logId in logIds) {
        final log = box.get(logId);
        if (log != null) {
          final syncedLog = log.copyWith(synced: true);
          await box.put(logId, syncedLog);
        }
      }
    } catch (e) {
      throw CacheException('Failed to mark logs as synced: $e');
    }
  }

  @override
  Future<void> deleteLog(String logId) async {
    try {
      final box = await _logBox;
      await box.delete(logId);
    } catch (e) {
      throw CacheException('Failed to delete log: $e');
    }
  }

  @override
  Future<void> deleteAllLogs() async {
    try {
      final box = await _logBox;
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to delete all logs: $e');
    }
  }

  @override
  Future<void> deleteLogsOlderThan(DateTime cutoffDate) async {
    try {
      final box = await _logBox;
      final logsToDelete = <String>[];

      for (final log in box.values) {
        if (log.timestamp.isBefore(cutoffDate)) {
          logsToDelete.add(log.id);
        }
      }

      for (final logId in logsToDelete) {
        await box.delete(logId);
      }
    } catch (e) {
      throw CacheException('Failed to delete old logs: $e');
    }
  }

  @override
  Future<List<LogEntry>> searchLogs(String query) async {
    try {
      final box = await _logBox;
      final searchQuery = query.toLowerCase();

      return box.values
          .where(
            (log) =>
                log.message.toLowerCase().contains(searchQuery) ||
                log.category.toLowerCase().contains(searchQuery) ||
                log.operation.toLowerCase().contains(searchQuery) ||
                (log.error?.toLowerCase().contains(searchQuery) ?? false),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      throw CacheException('Failed to search logs: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getLogStatistics() async {
    try {
      final box = await _logBox;
      final logs = box.values.toList();

      if (logs.isEmpty) {
        return {
          'total': 0,
          'by_category': <String, int>{},
          'by_level': <String, int>{},
          'by_operation': <String, int>{},
          'error_count': 0,
          'unsynced_count': 0,
          'oldest_log': null,
          'newest_log': null,
        };
      }

      final Map<String, int> byCategory = {};
      final Map<String, int> byLevel = {};
      final Map<String, int> byOperation = {};
      int errorCount = 0;
      int unsyncedCount = 0;

      DateTime? oldestTimestamp;
      DateTime? newestTimestamp;

      for (final log in logs) {
        // Count by category
        byCategory[log.category] = (byCategory[log.category] ?? 0) + 1;

        // Count by level
        byLevel[log.level] = (byLevel[log.level] ?? 0) + 1;

        // Count by operation
        byOperation[log.operation] = (byOperation[log.operation] ?? 0) + 1;

        // Count errors
        if (log.error != null) {
          errorCount++;
        }

        // Count unsynced
        if (!log.synced) {
          unsyncedCount++;
        }

        // Track oldest/newest
        if (oldestTimestamp == null ||
            log.timestamp.isBefore(oldestTimestamp)) {
          oldestTimestamp = log.timestamp;
        }
        if (newestTimestamp == null || log.timestamp.isAfter(newestTimestamp)) {
          newestTimestamp = log.timestamp;
        }
      }

      return {
        'total': logs.length,
        'by_category': byCategory,
        'by_level': byLevel,
        'by_operation': byOperation,
        'error_count': errorCount,
        'unsynced_count': unsyncedCount,
        'oldest_log': oldestTimestamp?.toIso8601String(),
        'newest_log': newestTimestamp?.toIso8601String(),
      };
    } catch (e) {
      throw CacheException('Failed to get log statistics: $e');
    }
  }
}
