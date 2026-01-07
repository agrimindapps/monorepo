import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/utils/failure.dart';
import '../../common/interfaces/i_storage_service.dart';
import '../interfaces/i_drift_manager.dart';
import '../interfaces/i_drift_storage_service.dart';
import 'drift_manager.dart';

/// Implementação concreta do serviço de storage usando Drift
/// Orquestra o DriftManager e fornece funcionalidades de alto nível
///
/// Equivalente Drift do CoreHiveStorageService
/// Implementa IBoxStorageService (interface agnóstica) e IDatabaseStorageService (específica Drift)
class CoreDriftStorageService implements IBoxStorageService, IDatabaseStorageService {
  /// Gerenciador de banco de dados Drift
  final IDriftManager _driftManager;
  bool _isInitialized = false;
  String? _appName;

  /// Cria uma instância de CoreDriftStorageService
  CoreDriftStorageService({IDriftManager? driftManager})
    : _driftManager = driftManager ?? DriftManager.instance;

  @override
  String get serviceName => 'CoreDriftStorageService';

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<Either<Failure, void>> initialize(Map<String, dynamic>? config) async {
    if (_isInitialized) {
      debugPrint('$serviceName: Already initialized');
      return const Right(null);
    }

    try {
      _appName = config?['appName'] as String?;
      if (_appName == null || _appName!.isEmpty) {
        return const Left(
          UnexpectedFailure('App name is required in config'),
        );
      }

      final initResult = await _driftManager.initialize(_appName!);
      return initResult.fold(
        (failure) => Left(failure),
        (_) {
          _isInitialized = true;
          debugPrint('$serviceName: Successfully initialized for app: $_appName');
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Initialization failed - $e');
      return const Left(
        UnexpectedFailure('Failed to initialize storage service'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> healthCheck() async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final isDriftInitialized = _driftManager.isInitialized;
      final openDatabases = _driftManager.openDatabaseNames;
      final databaseStats = _driftManager.getDatabaseStatistics();

      final healthData = {
        'serviceName': serviceName,
        'isInitialized': _isInitialized,
        'appName': _appName,
        'driftInitialized': isDriftInitialized,
        'openDatabasesCount': openDatabases.length,
        'openDatabases': openDatabases,
        'databaseStatistics': databaseStats,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'healthy',
      };

      debugPrint('$serviceName: Health check completed successfully');
      return Right(healthData);
    } catch (e) {
      debugPrint('$serviceName: Health check failed - $e');
      final errorData = {
        'serviceName': serviceName,
        'status': 'unhealthy',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      return Right(errorData);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final databaseStats = _driftManager.getDatabaseStatistics();
      final openDatabases = _driftManager.openDatabaseNames;

      final statistics = {
        'serviceName': serviceName,
        'appName': _appName,
        'totalDatabases': openDatabases.length,
        'openDatabases': openDatabases,
        'databaseStatistics': databaseStats,
        'totalItems':
            databaseStats.values.fold<int>(0, (sum, count) => sum + count),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      return Right(statistics);
    } catch (e) {
      debugPrint('$serviceName: Failed to get statistics - $e');
      return const Left(
        UnexpectedFailure('Failed to get storage statistics'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> listBoxes() async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final openDatabases = _driftManager.openDatabaseNames;
      return Right(openDatabases);
    } catch (e) {
      debugPrint('$serviceName: Failed to list databases - $e');
      return const Left(
        UnexpectedFailure('Failed to list databases'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> boxExists(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final exists = _driftManager.isDatabaseOpen(boxName);
      return Right(exists);
    } catch (e) {
      debugPrint('$serviceName: Failed to check if database exists - $e');
      return const Left(
        UnexpectedFailure('Failed to check if database exists'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBoxStatistics(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final infoResult = await _driftManager.getDatabaseInfo(boxName);
      return infoResult;
    } catch (e) {
      debugPrint('$serviceName: Failed to get database statistics - $e');
      return const Left(
        UnexpectedFailure('Failed to get statistics for database'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> compactBox(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isLeft()) {
        return validationResult;
      }

      final vacuumResult = await _driftManager.vacuumDatabase(boxName);
      return vacuumResult.fold(
        (failure) => Left(failure),
        (_) {
          debugPrint('$serviceName: Compacted (vacuumed) database: $boxName');
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to compact database - $e');
      return const Left(
        UnexpectedFailure('Failed to compact database'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteBox(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isLeft()) {
        return validationResult;
      }

      final closeResult = await _driftManager.closeDatabase(boxName);
      return closeResult.fold(
        (failure) => Left(failure),
        (_) {
          debugPrint(
            '$serviceName: Database closed: $boxName (Physical deletion requires app-level implementation)',
          );
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to delete database - $e');
      return const Left(
        UnexpectedFailure('Failed to delete database'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> backup() async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final statisticsResult = await getStatistics();
      return statisticsResult.fold(
        (failure) => Left(failure),
        (stats) {
          final backupData = {
            'serviceName': serviceName,
            'appName': _appName,
            'backupTimestamp': DateTime.now().toIso8601String(),
            'statistics': stats,
            'note':
                'Full backup functionality requires database-level implementation',
          };

          debugPrint('$serviceName: Backup metadata created');
          return Right(backupData);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to create backup - $e');
      return const Left(
        UnexpectedFailure('Failed to create backup'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> backupBox(String boxName) async {
    try {
      final statisticsResult = await getBoxStatistics(boxName);
      return statisticsResult.fold(
        (failure) => Left(failure),
        (stats) {
          final backupData = {
            'databaseName': boxName,
            'backupTimestamp': DateTime.now().toIso8601String(),
            'statistics': stats,
            'note':
                'Database data backup requires app-specific implementation per data type',
          };

          return Right(backupData);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to backup database - $e');
      return const Left(
        UnexpectedFailure('Failed to backup database'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> restore(Map<String, dynamic> backupData) async {
    debugPrint(
      '$serviceName: Restore functionality requires app-specific implementation',
    );
    return const Left(
      UnexpectedFailure('Restore functionality not implemented yet'),
    );
  }

  @override
  Future<Either<Failure, void>> restoreBox(
    String boxName,
    Map<String, dynamic> boxData,
  ) async {
    debugPrint(
      '$serviceName: Database restore functionality requires app-specific implementation',
    );
    return const Left(
      UnexpectedFailure('Database restore functionality not implemented yet'),
    );
  }

  @override
  Future<Either<Failure, void>> clearAllData({required bool confirm}) async {
    if (!confirm) {
      return const Left(
        ValidationFailure('Clear all data operation requires explicit confirmation'),
      );
    }

    try {
      final validationResult = _validateInitialized();
      if (validationResult.isLeft()) {
        return validationResult;
      }

      final clearResult = await _driftManager.clearAllData();
      return clearResult.fold(
        (failure) => Left(failure),
        (_) {
          debugPrint('$serviceName: All data cleared successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to clear all data - $e');
      return const Left(
        UnexpectedFailure('Failed to clear all data'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> performMaintenance() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isLeft()) {
        return validationResult;
      }

      final vacuumResult = await _driftManager.vacuumAllDatabases();
      return vacuumResult.fold(
        (failure) => Left(failure),
        (_) {
          debugPrint('$serviceName: Maintenance completed - vacuumed all databases');
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Maintenance failed - $e');
      return const Left(
        UnexpectedFailure('Failed to perform maintenance'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      final closeResult = await _driftManager.closeAllDatabases();
      return closeResult.fold(
        (failure) => Left(failure),
        (_) {
          _isInitialized = false;
          _appName = null;

          debugPrint('$serviceName: Disposed successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to dispose - $e');
      return const Left(
        UnexpectedFailure('Failed to dispose storage service'),
      );
    }
  }

  /// Valida se o serviço foi inicializado
  Either<Failure, void> _validateInitialized() {
    if (!_isInitialized) {
      return const Left(
        ValidationFailure('Storage service not initialized. Call initialize() first.'),
      );
    }
    return const Right(null);
  }

  // ==================== IDatabaseStorageService Methods ====================

  @override
  Future<Either<Failure, List<String>>> listDatabases() async {
    return listBoxes(); // Alias for IBoxStorageService.listBoxes()
  }

  @override
  Future<Either<Failure, bool>> databaseExists(String databaseName) async {
    return boxExists(databaseName); // Alias for IBoxStorageService.boxExists()
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDatabaseStatistics(String databaseName) async {
    return getBoxStatistics(databaseName); // Alias for IBoxStorageService.getBoxStatistics()
  }

  @override
  Future<Either<Failure, void>> vacuumDatabase(String databaseName) async {
    return compactBox(databaseName); // Alias for IBoxStorageService.compactBox()
  }

  @override
  Future<Either<Failure, void>> deleteDatabase(String databaseName) async {
    return deleteBox(databaseName); // Alias for IBoxStorageService.deleteBox()
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> backupDatabase(String databaseName) async {
    return backupBox(databaseName); // Alias for IBoxStorageService.backupBox()
  }

  @override
  Future<Either<Failure, void>> restoreDatabase(
    String databaseName,
    Map<String, dynamic> databaseData,
  ) async {
    return restoreBox(databaseName, databaseData); // Alias for IBoxStorageService.restoreBox()
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDatabaseInfo(String databaseName) async {
    try {
      final validationResult = _validateInitialized();
      final validationError = validationResult.fold(
        (failure) => failure,
        (_) => null,
      );
      if (validationError != null) {
        return Left(validationError);
      }

      final infoResult = await _driftManager.getDatabaseInfo(databaseName);
      return infoResult;
    } catch (e) {
      debugPrint('$serviceName: Failed to get database info - $e');
      return const Left(
        UnexpectedFailure('Failed to get info for database'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> vacuumAllDatabases() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isLeft()) {
        return validationResult;
      }

      final vacuumResult = await _driftManager.vacuumAllDatabases();
      return vacuumResult.fold(
        (failure) => Left(failure),
        (_) {
          debugPrint('$serviceName: All databases vacuumed successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      debugPrint('$serviceName: Failed to vacuum all databases - $e');
      return const Left(
        UnexpectedFailure('Failed to vacuum all databases'),
      );
    }
  }
}
