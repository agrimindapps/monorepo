import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../entities/log_entry.dart';
import '../../repositories/log_repository.dart';
import '../datasources/log_local_data_source.dart';
import '../datasources/log_remote_data_source.dart';

@LazySingleton(as: LogRepository)
class LogRepositoryImpl implements LogRepository {

  LogRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });
  final LogLocalDataSource localDataSource;
  final LogRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  Future<bool> get _isConnected async {
    final connectivityResults = await connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  @override
  Future<Either<Failure, Unit>> saveLog(LogEntry logEntry) async {
    try {
      await localDataSource.saveLog(logEntry);
      _syncInBackground();
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveLogs(List<LogEntry> logEntries) async {
    try {
      await localDataSource.saveLogs(logEntries);
      _syncInBackground();
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getAllLogs() async {
    try {
      final logs = await localDataSource.getAllLogs();
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLogsByCategory(String category) async {
    try {
      final logs = await localDataSource.getLogsByCategory(category);
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLogsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await localDataSource.getLogsByPeriod(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getUnsyncedLogs() async {
    try {
      final logs = await localDataSource.getUnsyncedLogs();
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markLogsAsSynced(List<String> logIds) async {
    try {
      await localDataSource.markLogsAsSynced(logIds);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cleanOldLogs({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      await localDataSource.deleteLogsOlderThan(cutoffDate);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLogStatistics() async {
    try {
      final stats = await localDataSource.getLogStatistics();
      return Right(stats);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncLogsToRemote(List<LogEntry> logs) async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.syncLogs(logs);
      final logIds = logs.map((log) => log.id).toList();
      await localDataSource.markLogsAsSynced(logIds);
      
      return const Right(unit);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteLog(String logId) async {
    try {
      await localDataSource.deleteLog(logId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllLogs() async {
    try {
      await localDataSource.deleteAllLogs();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> searchLogs(String query) async {
    try {
      final logs = await localDataSource.searchLogs(query);
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getErrorLogs() async {
    try {
      final logs = await localDataSource.getLogsByLevel(LogLevel.error.name);
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLogsByOperation(String operation) async {
    try {
      final logs = await localDataSource.getLogsByOperation(operation);
      return Right(logs);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportLogsToJson() async {
    try {
      final logs = await localDataSource.getAllLogs();
      final logsJson = logs.map((log) => log.toJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(logsJson);
      
      return Right(jsonString);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Sincroniza logs pendentes em background
  Future<void> _syncInBackground() async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) return;

      final unsyncedLogsResult = await getUnsyncedLogs();
      unsyncedLogsResult.fold(
        (failure) => null,
        (unsyncedLogs) async {
          if (unsyncedLogs.isNotEmpty) {
            syncLogsToRemote(unsyncedLogs).then((_) {
              if (kDebugMode) {
                print('✅ Logs synced in background: ${unsyncedLogs.length}');
              }
            }).catchError((Object error) {
              if (kDebugMode) {
                print('❌ Failed to sync logs in background: $error');
              }
            });
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Background sync error: $e');
      }
    }
  }
}
