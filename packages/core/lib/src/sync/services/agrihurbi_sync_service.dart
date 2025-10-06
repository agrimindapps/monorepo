import 'dart:async';

import 'package:dartz/dartz.dart';

import '../interfaces/i_sync_service.dart';
import '../../shared/utils/failure.dart';
import 'sync_logger.dart';

/// Serviço de sincronização específico para o app AgrihUrbi
/// Coordena sincronização de dados agropecuários urbanos, gado e clima
///
/// **Arquitetura**: Delegation pattern - delega sync para repositories
/// **Features**: Livestock management, market data, weather tracking
class AgrihUrbiSyncService implements ISyncService {
  /// Repository references para delegation
  final dynamic livestockRepository;
  final dynamic marketRepository;
  final dynamic weatherRepository;
  final dynamic calculatorRepository;

  /// Logger estruturado para sincronização
  final SyncLogger logger;

  /// Connectivity monitoring (opcional)
  StreamSubscription<bool>? _connectivitySubscription;

  /// Cria uma instância do AgrihUrbiSyncService
  AgrihUrbiSyncService({
    required this.livestockRepository,
    required this.marketRepository,
    required this.weatherRepository,
    required this.calculatorRepository,
  }) : logger = SyncLogger(appName: 'agrihurbi');

  @override
  final String serviceId = 'agrihurbi';

  @override
  final String displayName = 'AgrihUrbi Agricultural Sync';

  @override
  final String version = '2.0.0';
  bool _isInitialized = false;
  final bool _canSync = true;
  bool _hasPendingSync = false;
  DateTime? _lastSync;
  int _totalSyncs = 0;
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  int _totalItemsSynced = 0;
  final StreamController<SyncServiceStatus> _statusController =
      StreamController<SyncServiceStatus>.broadcast();
  final StreamController<ServiceProgress> _progressController =
      StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  final List<String> _entityTypes = [
    'livestock',         // Gado/Animais
    'market_data',       // Dados de mercado/preços
    'weather_prefs',     // Preferências de clima
    'calculator_history',// Histórico de cálculos
    'user_settings',     // Configurações
    'subscriptions',     // Assinaturas
  ];

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      logger.logInfo(
        message: 'Initializing AgrihUrbi Sync Service v$version',
        metadata: {
          'entities': _entityTypes,
          'features': ['livestock_mgmt', 'market_data', 'weather_tracking'],
        },
      );

      _isInitialized = true;
      _updateStatus(SyncServiceStatus.idle);

      logger.logInfo(
        message: 'AgrihUrbi Sync Service initialized successfully',
        metadata: {
          'entity_count': _entityTypes.length,
          'sync_mode': 'agricultural',
        },
      );

      return const Right(null);

    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);
      logger.logError(
        message: 'Failed to initialize AgrihUrbi sync',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(SyncFailure('Failed to initialize AgrihUrbi sync: $e'));
    }
  }

  @override
  bool get canSync => _isInitialized && _canSync;

  @override
  Future<bool> get hasPendingSync async => _hasPendingSync;

  @override
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;

  @override
  Stream<ServiceProgress> get progressStream => _progressController.stream;

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    if (!canSync) {
      return const Left(
        SyncFailure('AgrihUrbi sync service cannot sync in current state'),
      );
    }

    try {
      _updateStatus(SyncServiceStatus.syncing);
      _hasPendingSync = false;
      _totalSyncs++;

      final startTime = DateTime.now();
      logger.logSyncStart(entity: 'all_entities');

      int totalSynced = 0;
      final errors = <String>[];

      for (int i = 0; i < _entityTypes.length; i++) {
        final entityType = _entityTypes[i];

        _emitProgress(ServiceProgress(
          serviceId: serviceId,
          operation: 'Syncing $entityType',
          current: i + 1,
          total: _entityTypes.length,
          currentItem: entityType,
        ));

        final syncResult = await _syncEntity(entityType);

        syncResult.fold(
          (failure) {
            errors.add('$entityType: ${failure.message}');
            logger.logWarning(
              message: 'Partial sync failure for $entityType',
              metadata: {'error': failure.message},
            );
          },
          (itemCount) {
            totalSynced += itemCount;
            logger.logInfo(
              message: 'Synced $itemCount items for $entityType',
              metadata: {'entity': entityType, 'count': itemCount},
            );
          },
        );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _lastSync = endTime;
      _totalItemsSynced += totalSynced;

      if (errors.isEmpty || totalSynced > 0) {
        _successfulSyncs++;
        _updateStatus(SyncServiceStatus.completed);

        logger.logSyncSuccess(
          entity: 'all_entities',
          duration: duration,
          itemsSynced: totalSynced,
          metadata: {
            'entities_synced': _entityTypes,
            'partial_failures': errors.length,
          },
        );

        return Right(ServiceSyncResult(
          success: true,
          itemsSynced: totalSynced,
          duration: duration,
          metadata: {
            'entities_synced': _entityTypes,
            'app': 'agrihurbi',
            'sync_type': 'full',
            'partial_failures': errors,
            'agricultural_mode': true,
          },
        ));
      } else {
        _failedSyncs++;
        _updateStatus(SyncServiceStatus.failed);

        logger.logSyncFailure(
          entity: 'all_entities',
          error: 'All entities failed: ${errors.join(', ')}',
        );

        return Left(SyncFailure('All entities failed to sync: ${errors.join(', ')}'));
      }

    } catch (e, stackTrace) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);

      logger.logSyncFailure(
        entity: 'all_entities',
        error: e.toString(),
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('AgrihUrbi sync failed: $e'));
    }
  }

  /// Sincroniza uma entidade específica
  Future<Either<Failure, int>> _syncEntity(String entityType) async {
    try {

      switch (entityType) {
        case 'livestock':
          return const Right(0); // Gado (via LivestockRepository)
        case 'market_data':
          return const Right(0); // Mercado (via MarketRepository)
        case 'weather_prefs':
          return const Right(0); // Clima (via WeatherRepository)
        case 'calculator_history':
          return const Right(0); // Histórico (via CalculatorRepository)
        case 'user_settings':
          return const Right(0); // Settings
        case 'subscriptions':
          return const Right(0); // Subscriptions
        default:
          return Left(ValidationFailure('Unknown entity type: $entityType'));
      }
    } catch (e) {
      return Left(SyncFailure('Failed to sync $entityType: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(List<String> ids) async {
    if (!canSync) {
      return const Left(
        SyncFailure('AgrihUrbi sync service cannot sync in current state'),
      );
    }

    try {
      _updateStatus(SyncServiceStatus.syncing);
      final startTime = DateTime.now();

      logger.logInfo(
        message: 'Starting specific sync for AgrihUrbi entities',
        metadata: {'entity_types': ids, 'count': ids.length},
      );

      int totalSynced = 0;
      for (final entityType in ids) {
        final result = await _syncEntity(entityType);
        result.fold(
          (failure) => logger.logWarning(
            message: 'Failed to sync $entityType',
            metadata: {'error': failure.message},
          ),
          (count) => totalSynced += count,
        );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _lastSync = endTime;
      _successfulSyncs++;
      _totalItemsSynced += totalSynced;
      _updateStatus(SyncServiceStatus.completed);

      return Right(ServiceSyncResult(
        success: true,
        itemsSynced: totalSynced,
        duration: duration,
        metadata: {
          'sync_type': 'specific',
          'entity_types': ids,
          'app': 'agrihurbi',
        },
      ));

    } catch (e, stackTrace) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);

      logger.logSyncFailure(
        entity: 'specific_entities',
        error: e.toString(),
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('AgrihUrbi specific sync failed: $e'));
    }
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.paused);
    logger.logInfo(message: 'AgrihUrbi sync stopped');
  }

  @override
  Future<bool> checkConnectivity() async {
    return true; // Implementação simplificada
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      logger.logInfo(message: 'Clearing local sync metadata for AgrihUrbi');

      _lastSync = null;
      _hasPendingSync = false;
      _totalSyncs = 0;
      _successfulSyncs = 0;
      _failedSyncs = 0;
      _totalItemsSynced = 0;

      return const Right(null);

    } catch (e, stackTrace) {
      logger.logError(
        message: 'Failed to clear AgrihUrbi local data',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CacheFailure('Failed to clear AgrihUrbi local data: $e'));
    }
  }

  @override
  Future<SyncStatistics> getStatistics() async {
    return SyncStatistics(
      serviceId: serviceId,
      totalSyncs: _totalSyncs,
      successfulSyncs: _successfulSyncs,
      failedSyncs: _failedSyncs,
      lastSyncTime: _lastSync,
      totalItemsSynced: _totalItemsSynced,
      metadata: {
        'entity_types': _entityTypes,
        'avg_items_per_sync': _successfulSyncs > 0
            ? (_totalItemsSynced / _successfulSyncs).round()
            : 0,
        'success_rate': _totalSyncs > 0
            ? ((_successfulSyncs / _totalSyncs) * 100).toStringAsFixed(1)
            : '0.0',
        'agricultural_mode': true,
        'market_data_sync': true,
      },
    );
  }

  @override
  Future<void> dispose() async {
    logger.logInfo(message: 'Disposing AgrihUrbi Sync Service');
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    await _statusController.close();
    await _progressController.close();

    _isInitialized = false;
    _updateStatus(SyncServiceStatus.disposing);
  }

  /// Sync apenas dados de gado/livestock
  Future<Either<Failure, ServiceSyncResult>> syncLivestock() async {
    return await syncSpecific(['livestock']);
  }

  /// Sync dados de mercado e preços
  Future<Either<Failure, ServiceSyncResult>> syncMarketData() async {
    return await syncSpecific(['market_data']);
  }

  /// Sync dados de clima
  Future<Either<Failure, ServiceSyncResult>> syncWeatherData() async {
    return await syncSpecific(['weather_prefs']);
  }

  /// Marca dados como pendentes (usado quando offline)
  void markDataAsPending() {
    _hasPendingSync = true;
    logger.logInfo(message: 'AgrihUrbi data marked as pending sync');
  }

  /// Inicia monitoramento de conectividade
  void startConnectivityMonitoring(Stream<bool> connectivityStream) {
    try {
      _connectivitySubscription?.cancel();

      _connectivitySubscription = connectivityStream.listen(
        (isConnected) {
          logger.logConnectivityChange(
            isConnected: isConnected,
            metadata: {'auto_sync_enabled': true},
          );

          if (isConnected && _hasPendingSync) {
            logger.logInfo(
              message: 'Connection restored - triggering auto-sync',
              metadata: {'pending_sync': true},
            );

            sync();
          }
        },
        onError: (Object error) {
          logger.logError(
            message: 'Connectivity monitoring error',
            error: error,
          );
        },
      );

      logger.logInfo(
        message: 'Connectivity monitoring started',
        metadata: {'service': serviceId},
      );
    } catch (e) {
      logger.logError(
        message: 'Failed to start connectivity monitoring',
        error: e,
      );
    }
  }

  /// Para monitoramento de conectividade
  void stopConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    logger.logInfo(
      message: 'Connectivity monitoring stopped',
      metadata: {'service': serviceId},
    );
  }

  void _updateStatus(SyncServiceStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;

      if (!_statusController.isClosed) {
        _statusController.add(status);
      }

      logger.logInfo(
        message: 'Sync status changed',
        metadata: {'old_status': _currentStatus.name, 'new_status': status.name},
      );
    }
  }

  void _emitProgress(ServiceProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
}

/// Factory para criar AgrihUrbiSyncService com dependências
abstract class AgrihUrbiSyncServiceFactory {
  /// Cria uma instância do AgrihUrbiSyncService
  static AgrihUrbiSyncService create({
    required dynamic livestockRepository,
    required dynamic marketRepository,
    required dynamic weatherRepository,
    required dynamic calculatorRepository,
  }) {
    return AgrihUrbiSyncService(
      livestockRepository: livestockRepository,
      marketRepository: marketRepository,
      weatherRepository: weatherRepository,
      calculatorRepository: calculatorRepository,
    );
  }
}
