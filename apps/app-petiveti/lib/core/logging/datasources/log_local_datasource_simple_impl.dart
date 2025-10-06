import 'dart:convert';

import 'package:core/core.dart' show Box, Hive;

import '../entities/log_entry.dart';
import 'log_local_datasource.dart';

/// Simple implementation that stores logs as JSON strings until TypeAdapters are generated
class LogLocalDataSourceSimpleImpl implements LogLocalDataSource {
  static const String _boxName = 'logs_json';
  Box<String>? _logsBox;

  LogLocalDataSourceSimpleImpl() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        _logsBox = Hive.box<String>(_boxName);
      }
    } catch (e) {
      print('Warning: Failed to initialize logs box: $e');
    }
  }

  @override
  Future<void> saveLog(LogEntry logEntry) async {
    try {
      if (_logsBox == null) return;

      final jsonString = jsonEncode(logEntry.toJson());
      await _logsBox!.put(logEntry.id, jsonString);
    } catch (e) {
      // Silently fail if logging fails - don't break the app
      print('Warning: Failed to save log: $e');
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
      if (_logsBox == null) return [];

      final logs = <LogEntry>[];

      for (final jsonString in _logsBox!.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final log = _logEntryFromJson(json);

          // Apply filters
          if (level != null && log.level != level) continue;
          if (category != null && log.category != category) continue;
          if (startDate != null && log.timestamp.isBefore(startDate)) continue;
          if (endDate != null && log.timestamp.isAfter(endDate)) continue;

          logs.add(log);
        } catch (e) {
          // Skip invalid logs
          continue;
        }
      }

      // Sort by timestamp (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply limit
      if (limit != null && limit > 0) {
        return logs.take(limit).toList();
      }

      return logs;
    } catch (e) {
      print('Warning: Failed to get logs: $e');
      return [];
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
        try {
          final json = jsonDecode(entry.value) as Map<String, dynamic>;
          final timestamp = DateTime.parse(json['timestamp'] as String);

          if (timestamp.isBefore(cutoffDate)) {
            keysToDelete.add(entry.key.toString());
          }
        } catch (e) {
          // If we can't parse the timestamp, delete it
          keysToDelete.add(entry.key.toString());
        }
      }

      await _logsBox!.deleteAll(keysToDelete);
    } catch (e) {
      print('Warning: Failed to clear old logs: $e');
    }
  }

  @override
  Future<void> clearAllLogs() async {
    try {
      if (_logsBox == null) return;
      await _logsBox!.clear();
    } catch (e) {
      print('Warning: Failed to clear all logs: $e');
    }
  }

  @override
  Future<Map<LogLevel, int>> getLogsCount() async {
    try {
      if (_logsBox == null) return {};

      final counts = <LogLevel, int>{};

      // Initialize counts
      for (final level in LogLevel.values) {
        counts[level] = 0;
      }

      // Count logs by level
      for (final jsonString in _logsBox!.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final levelName = json['level'] as String;
          final level = LogLevel.values.firstWhere(
            (l) => l.name == levelName,
            orElse: () => LogLevel.info,
          );
          counts[level] = (counts[level] ?? 0) + 1;
        } catch (e) {
          // Skip invalid logs
          continue;
        }
      }

      return counts;
    } catch (e) {
      print('Warning: Failed to get logs count: $e');
      return {};
    }
  }

  /// Convert JSON to LogEntry
  LogEntry _logEntryFromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (l) => l.name == json['level'] as String,
      ),
      category: LogCategory.values.firstWhere(
        (c) => c.name == json['category'] as String,
      ),
      operation: LogOperation.values.firstWhere(
        (o) => o.name == json['operation'] as String,
      ),
      message: json['message'] as String,
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'] as Map)
              : null,
      userId: json['userId'] as String?,
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] as String?,
      duration:
          json['duration'] != null
              ? Duration(milliseconds: json['duration'] as int)
              : null,
    );
  }

  /// Initialize the logs box (called during app initialization)
  static Future<void> initBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox<String>(_boxName);
      }
    } catch (e) {
      print('Warning: Failed to open logs box: $e');
    }
  }

  /// Close the logs box (called during app termination)
  static Future<void> closeBox() async {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        await Hive.box<String>(_boxName).close();
      }
    } catch (e) {
      print('Warning: Failed to close logs box: $e');
    }
  }
}
