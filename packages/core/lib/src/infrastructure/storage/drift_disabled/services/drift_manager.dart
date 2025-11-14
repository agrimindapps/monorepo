import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/result.dart';
import '../exceptions/drift_exceptions.dart';
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
  Future<Result<void>> initialize(String appName) async {
    if (_isInitialized) {
      debugPrint('DriftManager: Already initialized for app: $_appName');
      return Result.success(null);
    }

    try {
      _appName = appName;

      // Obter path de armazenamento
      final appDocDir = await getApplicationDocumentsDirectory();
      _databasesPath = path.join(appDocDir.path, 'drift_databases', appName);

      _isInitialized = true;
      debugPrint('DriftManager: Initialized successfully for app: $appName');
      debugPrint('DriftManager: Databases path: $_databasesPath');

      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Initialization failed - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to initialize DriftManager',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<GeneratedDatabase>> getDatabase(String databaseName) async {
    try {
      if (!_isInitialized) {
        return Result.error(
          AppErrorFactory.fromException(
            const DriftInitializationException(
              'DriftManager not initialized. Call initialize() first.',
            ),
            null,
          ),
        );
      }

      // Se já está aberta, retornar do cache
      if (_openDatabases.containsKey(databaseName)) {
        debugPrint('DriftManager: Returning cached database: $databaseName');
        return Result.success(_openDatabases[databaseName]!);
      }

      // Nota: Para obter database, o app precisa fornecer a instância
      // Este método é mais para validação e cache
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseNotFoundException(databaseName),
          null,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to get database - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to get database',
            databaseName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  /// Registra uma database aberta (usado pelos apps)
  Future<Result<void>> registerDatabase(
    String databaseName,
    GeneratedDatabase database,
  ) async {
    try {
      if (!_isInitialized) {
        return Result.error(
          AppErrorFactory.fromException(
            const DriftInitializationException(
              'DriftManager not initialized',
            ),
            null,
          ),
        );
      }

      _openDatabases[databaseName] = database;
      _databaseStats[databaseName] = 0;

      debugPrint('DriftManager: Registered database: $databaseName');
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to register database',
            databaseName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> closeDatabase(String databaseName) async {
    try {
      if (!_openDatabases.containsKey(databaseName)) {
        debugPrint('DriftManager: Database not open: $databaseName');
        return Result.success(null);
      }

      final database = _openDatabases[databaseName]!;
      await database.close();

      _openDatabases.remove(databaseName);
      _databaseStats.remove(databaseName);

      debugPrint('DriftManager: Closed database: $databaseName');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to close database - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to close database',
            databaseName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> closeAllDatabases() async {
    try {
      final databaseNames = _openDatabases.keys.toList();

      for (final name in databaseNames) {
        final result = await closeDatabase(name);
        if (result.isError) {
          debugPrint('DriftManager: Error closing database $name');
        }
      }

      debugPrint('DriftManager: Closed all databases');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to close all databases - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to close all databases',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
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
  Future<Result<void>> clearAllData() async {
    try {
      if (!_isInitialized) {
        return Result.error(
          AppErrorFactory.fromException(
            const DriftInitializationException('DriftManager not initialized'),
            null,
          ),
        );
      }

      // Fechar todas as databases primeiro
      await closeAllDatabases();

      // Limpar estatísticas
      _databaseStats.clear();

      debugPrint('DriftManager: All data cleared');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to clear all data - $e');
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
  Future<Result<void>> vacuumDatabase(String databaseName) async {
    try {
      if (!_openDatabases.containsKey(databaseName)) {
        return Result.error(
          AppErrorFactory.fromException(
            DriftDatabaseNotFoundException(databaseName),
            null,
          ),
        );
      }

      final database = _openDatabases[databaseName]!;
      await database.customStatement('VACUUM');

      debugPrint('DriftManager: Vacuumed database: $databaseName');
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to vacuum database - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to vacuum database',
            databaseName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> vacuumAllDatabases() async {
    try {
      for (final databaseName in _openDatabases.keys) {
        final result = await vacuumDatabase(databaseName);
        if (result.isError) {
          debugPrint('DriftManager: Error vacuuming database $databaseName');
        }
      }

      debugPrint('DriftManager: Vacuumed all databases');
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(
          DriftInitializationException(
            'Failed to vacuum all databases',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getDatabaseInfo(
    String databaseName,
  ) async {
    try {
      if (!_openDatabases.containsKey(databaseName)) {
        return Result.error(
          AppErrorFactory.fromException(
            DriftDatabaseNotFoundException(databaseName),
            null,
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

      return Result.success(info);
    } catch (e, stackTrace) {
      debugPrint('DriftManager: Failed to get database info - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftDatabaseException(
            'Failed to get database info',
            databaseName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
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
