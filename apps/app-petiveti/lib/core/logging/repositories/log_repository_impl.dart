import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../error/failures.dart';
import '../datasources/log_local_datasource.dart';
import '../entities/log_entry.dart';
import 'log_repository.dart';

class LogRepositoryImpl implements LogRepository {
  final LogLocalDataSource localDataSource;

  LogRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> saveLog(LogEntry logEntry) async {
    try {
      await localDataSource.saveLog(logEntry);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save log: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLogs({
    LogLevel? level,
    LogCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final logs = await localDataSource.getLogs(
        level: level,
        category: category,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      return Right(logs);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLogsByCategory(
    LogCategory category, {
    int? limit,
  }) async {
    try {
      final logs = await localDataSource.getLogsByCategory(category, limit: limit);
      return Right(logs);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get logs by category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getErrorLogs({
    int? limit,
  }) async {
    try {
      final logs = await localDataSource.getErrorLogs(limit: limit);
      return Right(logs);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get error logs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearOldLogs(int daysToKeep) async {
    try {
      await localDataSource.clearOldLogs(daysToKeep);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear old logs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllLogs() async {
    try {
      await localDataSource.clearAllLogs();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear all logs: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<LogLevel, int>>> getLogsCount() async {
    try {
      final counts = await localDataSource.getLogsCount();
      return Right(counts);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get logs count: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await localDataSource.getLogs(
        startDate: startDate,
        endDate: endDate,
      );
      
      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'total_logs': logs.length,
        'filters': {
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        },
        'logs': logs.map((log) => log.toJson()).toList(),
      };
      
      return Right(jsonEncode(exportData));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to export logs: $e'));
    }
  }
}
