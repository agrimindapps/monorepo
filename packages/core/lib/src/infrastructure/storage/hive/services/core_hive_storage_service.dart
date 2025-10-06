import 'package:flutter/foundation.dart';

import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/result.dart';
import '../exceptions/storage_exceptions.dart';
import '../interfaces/i_hive_manager.dart';
import '../interfaces/i_storage_service.dart';
import 'hive_manager.dart';

/// Implementação concreta do serviço de storage usando Hive
/// Orquestra o HiveManager e fornece funcionalidades de alto nível
class CoreHiveStorageService implements IBoxStorageService {
  final IHiveManager _hiveManager;
  bool _isInitialized = false;
  String? _appName;

  CoreHiveStorageService({IHiveManager? hiveManager})
    : _hiveManager = hiveManager ?? HiveManager.instance;

  @override
  String get serviceName => 'CoreHiveStorageService';

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
            const HiveInitializationException('App name is required in config'),
            null,
          ),
        );
      }

      final initResult = await _hiveManager.initialize(_appName!);
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
          HiveInitializationException(
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

      final isHiveInitialized = _hiveManager.isInitialized;
      final openBoxes = _hiveManager.openBoxNames;
      final boxStats = _hiveManager.getBoxStatistics();

      final healthData = {
        'serviceName': serviceName,
        'isInitialized': _isInitialized,
        'appName': _appName,
        'hiveInitialized': isHiveInitialized,
        'openBoxesCount': openBoxes.length,
        'openBoxes': openBoxes,
        'boxStatistics': boxStats,
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

      final boxStats = _hiveManager.getBoxStatistics();
      final openBoxes = _hiveManager.openBoxNames;

      final statistics = {
        'serviceName': serviceName,
        'appName': _appName,
        'totalBoxes': openBoxes.length,
        'openBoxes': openBoxes,
        'boxStatistics': boxStats,
        'totalItems': boxStats.values.fold<int>(0, (sum, count) => sum + count),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      return Result.success(statistics);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to get statistics - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveInitializationException(
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

      final openBoxes = _hiveManager.openBoxNames;
      return Result.success(openBoxes);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to list boxes - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveInitializationException(
            'Failed to list boxes',
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

      final exists = _hiveManager.isBoxOpen(boxName);
      return Result.success(exists);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to check if box exists - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveInitializationException(
            'Failed to check if box exists: $boxName',
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

      final boxResult = await _hiveManager.getBox<dynamic>(boxName);
      if (boxResult.isError) {
        return Result.error(boxResult.error!);
      }

      final box = boxResult.data!;
      final statistics = {
        'boxName': boxName,
        'itemCount': box.length,
        'isEmpty': box.isEmpty,
        'isOpen': box.isOpen,
        'path': box.path,
        'keys': box.keys.length,
        'lastAccessed': DateTime.now().toIso8601String(),
      };

      return Result.success(statistics);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to get box statistics - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveBoxException(
            'Failed to get statistics for box: $boxName',
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

      final boxResult = await _hiveManager.getBox<dynamic>(boxName);
      if (boxResult.isError) {
        return Result.error(boxResult.error!);
      }

      final box = boxResult.data!;
      await box.compact();

      debugPrint('$serviceName: Compacted box: $boxName');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to compact box - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveBoxException(
            'Failed to compact box: $boxName',
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

      final closeResult = await _hiveManager.closeBox(boxName);
      if (closeResult.isError) {
        return closeResult;
      }
      debugPrint(
        '$serviceName: Box closed: $boxName (Note: Physical deletion not implemented)',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to delete box - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveBoxException(
            'Failed to delete box: $boxName',
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
        'note': 'Full backup functionality requires box-level implementation',
      };

      debugPrint('$serviceName: Backup metadata created');
      return Result.success(backupData);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to create backup - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveInitializationException(
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
        'boxName': boxName,
        'backupTimestamp': DateTime.now().toIso8601String(),
        'statistics': statisticsResult.data!,
        'note':
            'Box data backup requires specific implementation per data type',
      };

      return Result.success(backupData);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to backup box - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveBoxException(
            'Failed to backup box: $boxName',
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
      '$serviceName: Restore functionality requires specific implementation',
    );
    return Result.error(
      AppErrorFactory.fromException(
        const HiveInitializationException(
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
      '$serviceName: Box restore functionality requires specific implementation',
    );
    return Result.error(
      AppErrorFactory.fromException(
        HiveBoxException(
          'Box restore functionality not implemented yet',
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
          const HiveInitializationException(
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

      final clearResult = await _hiveManager.clearAllData();
      if (clearResult.isError) {
        return clearResult;
      }

      debugPrint('$serviceName: All data cleared successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Failed to clear all data - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveInitializationException(
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

      final boxNames = _hiveManager.openBoxNames;
      int compactedBoxes = 0;

      for (final boxName in boxNames) {
        final compactResult = await compactBox(boxName);
        if (compactResult.isSuccess) {
          compactedBoxes++;
        }
      }

      debugPrint(
        '$serviceName: Maintenance completed - compacted $compactedBoxes boxes',
      );
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('$serviceName: Maintenance failed - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveInitializationException(
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
      final closeResult = await _hiveManager.closeAllBoxes();
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
          HiveInitializationException(
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
          const HiveInitializationException(
            'Storage service not initialized. Call initialize() first.',
          ),
          null,
        ),
      );
    }
    return Result.success(null);
  }
}
