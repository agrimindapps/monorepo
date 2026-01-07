import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../shared/utils/failure.dart';
import '../interfaces/i_drift_manager.dart';

/// Implementação concreta do gerenciador de databases Drift
/// Singleton pattern para garantir única instância no app
/// 
/// Equivalente Drift do HiveManager
class DriftManager implements IDriftManager {
  static DriftManager? _instance;
  static DriftManager get instance => _instance ??= DriftManager._();

  DriftManager._();

  bool _isInitialized = false;
  String? _appName;
  String? _databasesPath;

  /// Cache de databases abertas
  final Map<String, GeneratedDatabase> _openDatabases = {};

  /// Estatísticas de uso
  final Map<String, int> _databaseStats = {};

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get openDatabaseNames => _openDatabases.keys.toList();

  @override
  Future<Either<Failure, void>> initialize(String appName) async {
    if (_isInitialized) {
      debugPrint('DriftManager: Already initialized for app: $_appName');
      return Right(null);
    }

    try {
      _appName = appName;

      // Obter path de armazenamento
      final appDocDir = await getApplicationDocumentsDirectory();
      _databasesPath = path.join(appDocDir.path, 'drift_databases', appName);

      _isInitialized = true;
      debugPrint('DriftManager: Initialized successfully for app: $appName');
      debugPrint('DriftManager: Databases path: $_databasesPath');

      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Initialization failed - $e');
      return const Left(
        CacheFailure(
          'Failed to initialize DriftManager',
          code: 'DRIFT_INIT_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GeneratedDatabase>> getDatabase(String databaseName) async {
    try {
      if (!_isInitialized) {
        return const Left(
          CacheFailure(
            'DriftManager not initialized. Call initialize() first.',
            code: 'DRIFT_NOT_INITIALIZED',
          ),
        );
      }

      // Se já está aberta, retornar do cache
      if (_openDatabases.containsKey(databaseName)) {
        debugPrint('DriftManager: Returning cached database: $databaseName');
        return Right(_openDatabases[databaseName]!);
      }

      // Nota: Para obter database, o app precisa fornecer a instância
      // Este método é mais para validação e cache
      return Left(
        CacheFailure(
          'Database not found: $databaseName',
          code: 'DRIFT_DB_NOT_FOUND',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to get database - $e');
      return Left(
        CacheFailure(
          'Failed to get database: $e',
          code: 'DRIFT_GET_DB_ERROR',
          details: stackTrace,
        ),
      );
    }
  }

  /// Registra uma database aberta (usado pelos apps)
  Future<Either<Failure, void>> registerDatabase(
    String databaseName,
    GeneratedDatabase database,
  ) async {
    try {
      if (!_isInitialized) {
        return const Left(
          CacheFailure(
            'DriftManager not initialized',
            code: 'DRIFT_NOT_INITIALIZED',
          ),
        );
      }

      _openDatabases[databaseName] = database;
      _databaseStats[databaseName] = 0;

      debugPrint('DriftManager: Registered database: $databaseName');
      return const Right(null);
    } catch (e, stackTrace) {
      return const Left(
        CacheFailure(
          'Failed to register database',
          code: 'DRIFT_REGISTER_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> closeDatabase(String databaseName) async {
    try {
      if (!_openDatabases.containsKey(databaseName)) {
        debugPrint('DriftManager: Database not open: $databaseName');
        return const Right(null);
      }

      final database = _openDatabases[databaseName]!;
      await database.close();

      _openDatabases.remove(databaseName);
      _databaseStats.remove(databaseName);

      debugPrint('DriftManager: Closed database: $databaseName');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to close database - $e');
      return Left(
        CacheFailure(
          'Failed to close database: $e',
          code: 'DRIFT_CLOSE_ERROR',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> closeAllDatabases() async {
    try {
      final databaseNames = _openDatabases.keys.toList();

      for (final name in databaseNames) {
        final result = await closeDatabase(name);
        result.fold(
          (failure) => debugPrint('DriftManager: Error closing database $name: $failure'),
          (_) => null,
        );
      }

      debugPrint('DriftManager: Closed all databases');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to close all databases - $e');
      return Left(
        CacheFailure(
          'Failed to close all databases: $e',
          code: 'DRIFT_CLOSE_ALL_ERROR',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  bool isDatabaseOpen(String databaseName) {
    return _openDatabases.containsKey(databaseName);
  }

  @override
  Map<String, int> getDatabaseStatistics() {
    return Map.unmodifiable(_databaseStats);
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      if (!_isInitialized) {
        return const Left(
          CacheFailure(
            'DriftManager not initialized',
            code: 'DRIFT_NOT_INITIALIZED',
          ),
        );
      }

      // Fechar todas as databases primeiro
      await closeAllDatabases();

      // Limpar estatísticas
      _databaseStats.clear();

      debugPrint('DriftManager: All data cleared');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to clear all data - $e');
      return const Left(
        CacheFailure(
          'Failed to clear all data',
          code: 'DRIFT_CLEAR_DATA_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> vacuumDatabase(String databaseName) async {
    try {
      if (!_openDatabases.containsKey(databaseName)) {
        return Left(
          CacheFailure(
            'Database not found: $databaseName',
            code: 'DRIFT_DB_NOT_FOUND',
          ),
        );
      }

      final database = _openDatabases[databaseName]!;
      await database.customStatement('VACUUM');

      debugPrint('DriftManager: Vacuumed database: $databaseName');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to vacuum database - $e');
      return Left(
        CacheFailure(
          'Failed to vacuum database: $e',
          code: 'DRIFT_VACUUM_ERROR',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> vacuumAllDatabases() async {
    try {
      for (final databaseName in _openDatabases.keys) {
        final result = await vacuumDatabase(databaseName);
        result.fold(
          (failure) => debugPrint('DriftManager: Error vacuuming database $databaseName: $failure'),
          (_) => null,
        );
      }

      debugPrint('DriftManager: Vacuumed all databases');
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        CacheFailure(
          'Failed to vacuum all databases: $e',
          code: 'DRIFT_VACUUM_ALL_ERROR',
          details: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDatabaseInfo(
    String databaseName,
  ) async {
    try {
      if (!_openDatabases.containsKey(databaseName)) {
        return Left(
          CacheFailure(
            'Database not found: $databaseName',
            code: 'DRIFT_DB_NOT_FOUND',
          ),
        );
      }

      final database = _openDatabases[databaseName]!;

      // Obter informações via pragma SQLite
      final versionResult = await database.customSelect(
        'PRAGMA user_version',
      ).getSingle();

      final pageSizeResult = await database.customSelect(
        'PRAGMA page_size',
      ).getSingle();

      final pageCountResult = await database.customSelect(
        'PRAGMA page_count',
      ).getSingle();

      final info = {
        'databaseName': databaseName,
        'version': versionResult.data['user_version'],
        'pageSize': pageSizeResult.data['page_size'],
        'pageCount': pageCountResult.data['page_count'],
        'estimatedSize':
            (pageSizeResult.data['page_size'] as int) *
            (pageCountResult.data['page_count'] as int),
        'isOpen': true,
        'path': _databasesPath != null
            ? path.join(_databasesPath!, '$databaseName.db')
            : null,
      };

      return Right(info);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to get database info - $e');
      return Left(
        CacheFailure(
          'Failed to get database info: $e',
          code: 'DRIFT_GET_INFO_ERROR',
          details: stackTrace,
        ),
      );
    }
  }

  /// Reset completo (apenas para testes)
  @visibleForTesting
  Future<void> reset() async {
    await closeAllDatabases();
    _isInitialized = false;
    _appName = null;
    _databasesPath = null;
    _databaseStats.clear();
  }
}
