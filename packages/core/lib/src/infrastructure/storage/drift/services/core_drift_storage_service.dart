import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/result.dart';
import '../../hive/interfaces/i_storage_service.dart';
import '../exceptions/drift_exceptions.dart';
import '../interfaces/i_drift_manager.dart';
import 'drift_manager.dart';

/// Implementação concreta do serviço de storage usando Drift
/// Orquestra o DriftManager e fornece funcionalidades de alto nível
/// 
/// Equivalente Drift do CoreHiveStorageService
/// Implementa IBoxStorageService (interface agnóstica)
class CoreDriftStorageService implements IBoxStorageService {
  final IDriftManager _driftManager;
  bool _isInitialized = false;
  String? _appName;

  CoreDriftStorageService({IDriftManager? driftManager})
    : _driftManager = driftManager ?? DriftManager.instance;

  @override
  String get serviceName => 'CoreDriftStorageService';

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<Result<void>> initialize(Map<String, dynamic>? config) async {
    if (_isInitialized) {
      debugPrint('$serviceName: Already initialized');
      return Result.success(null);
    }

    try {
      _appName = config?['appName'] as String?;
      if (_appName == null || _appName!.isEmpty) {
        return Result.error(
          AppErrorFactory.fromException(
            const DriftInitializationException(
              'App name is required in config',
            ),
            null,
          ),
        );
      }

      final initResult = await _driftManager.initialize(_appName!);
      if (initResult.isError) {
        return initResult;
      }

      _isInitialized = true;
      debugPrint('$serviceName: Successfully initialized for app: $_appName');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Initialization failed - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to initialize storage service',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> healthCheck() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return Result.error(validationResult.error!);
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
      return Result.success(healthData);
    } catch (e) {
      debugPrint('$serviceName: Health check failed - $e');
      final errorData = {
        'serviceName': serviceName,
        'status': 'unhealthy',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      return Result.success(errorData);
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getStatistics() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return Result.error(validationResult.error!);
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

      return Result.success(statistics);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to get statistics - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to get storage statistics',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<String>>> listBoxes() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return Result.error(validationResult.error!);
      }

      final openDatabases = _driftManager.openDatabaseNames;
      return Result.success(openDatabases);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to list databases - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to list databases',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> boxExists(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return Result.error(validationResult.error!);
      }

      final exists = _driftManager.isDatabaseOpen(boxName);
      return Result.success(exists);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to check if database exists - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to check if database exists: $boxName',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getBoxStatistics(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return Result.error(validationResult.error!);
      }

      final infoResult = await _driftManager.getDatabaseInfo(boxName);
      return infoResult;
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to get database statistics - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to get statistics for database: $boxName',
            boxName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> compactBox(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return validationResult;
      }

      final vacuumResult = await _driftManager.vacuumDatabase(boxName);
      if (vacuumResult.isError) {
        return vacuumResult;
      }

      debugPrint('$serviceName: Compacted (vacuumed) database: $boxName');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to compact database - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to compact database: $boxName',
            boxName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteBox(String boxName) async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return validationResult;
      }

      final closeResult = await _driftManager.closeDatabase(boxName);
      if (closeResult.isError) {
        return closeResult;
      }

      debugPrint(
        '$serviceName: Database closed: $boxName (Physical deletion requires app-level implementation)',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to delete database - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to delete database: $boxName',
            boxName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> backup() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return Result.error(validationResult.error!);
      }

      final statisticsResult = await getStatistics();
      if (statisticsResult.isError) {
        return statisticsResult;
      }

      final backupData = {
        'serviceName': serviceName,
        'appName': _appName,
        'backupTimestamp': DateTime.now().toIso8601String(),
        'statistics': statisticsResult.data,
        'note':
            'Full backup functionality requires database-level implementation',
      };

      debugPrint('$serviceName: Backup metadata created');
      return Result.success(backupData);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to create backup - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to create backup',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> backupBox(String boxName) async {
    try {
      final statisticsResult = await getBoxStatistics(boxName);
      if (statisticsResult.isError) {
        return statisticsResult;
      }

      final backupData = {
        'databaseName': boxName,
        'backupTimestamp': DateTime.now().toIso8601String(),
        'statistics': statisticsResult.data!,
        'note':
            'Database data backup requires app-specific implementation per data type',
      };

      return Result.success(backupData);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to backup database - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to backup database: $boxName',
            boxName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> restore(Map<String, dynamic> backupData) async {
    debugPrint(
      '$serviceName: Restore functionality requires app-specific implementation',
    );
    return Result.error(
      AppErrorFactory.fromException(
        const DriftInitializationException(
          'Restore functionality not implemented yet',
        ),
        null,
      ),
    );
  }

  @override
  Future<Result<void>> restoreBox(
    String boxName,
    Map<String, dynamic> boxData,
  ) async {
    debugPrint(
      '$serviceName: Database restore functionality requires app-specific implementation',
    );
    return Result.error(
      AppErrorFactory.fromException(
        DriftDatabaseException(
          'Database restore functionality not implemented yet',
          boxName,
        ),
        null,
      ),
    );
  }

  @override
  Future<Result<void>> clearAllData({required bool confirm}) async {
    if (!confirm) {
      return Result.error(
        AppErrorFactory.fromException(
          const DriftInitializationException(
            'Clear all data operation requires explicit confirmation',
          ),
          null,
        ),
      );
    }

    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return validationResult;
      }

      final clearResult = await _driftManager.clearAllData();
      if (clearResult.isError) {
        return clearResult;
      }

      debugPrint('$serviceName: All data cleared successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to clear all data - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to clear all data',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> performMaintenance() async {
    try {
      final validationResult = _validateInitialized();
      if (validationResult.isError) {
        return validationResult;
      }

      final vacuumResult = await _driftManager.vacuumAllDatabases();
      if (vacuumResult.isError) {
        return vacuumResult;
      }

      debugPrint('$serviceName: Maintenance completed - vacuumed all databases');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Maintenance failed - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to perform maintenance',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> dispose() async {
    try {
      final closeResult = await _driftManager.closeAllDatabases();
      if (closeResult.isError) {
        return closeResult;
      }

      _isInitialized = false;
      _appName = null;

      debugPrint('$serviceName: Disposed successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to dispose - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to dispose storage service',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  /// Valida se o serviço foi inicializado
  Result<void> _validateInitialized() {
    if (!_isInitialized) {
      return Result.error(
        AppErrorFactory.fromException(
          const DriftInitializationException(
            'Storage service not initialized. Call initialize() first.',
          ),
          null,
        ),
      );
    }
    return Result.success(null);
  }
}
