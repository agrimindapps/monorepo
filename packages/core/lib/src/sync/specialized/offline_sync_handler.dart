import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../domain/entities/base_sync_entity.dart';
import '../../domain/interfaces/i_disposable_service.dart';
import '../../shared/utils/failure.dart';
import 'sync_coordinator.dart';
import 'sync_state_machine.dart';

/// Handler para operações de sincronização offline
///
/// Responsabilidades:
/// - Auto-sync periódico
/// - Gerenciamento de queue de items não sincronizados
/// - Retry logic com backoff
/// - Background sync operations
/// - Force sync para apps específicos
class OfflineSyncHandler implements IDisposableService {
  final SyncCoordinator _coordinator;
  final SyncStateMachine _stateMachine;

  final Map<String, Timer> _syncTimers = {};
  bool _isDisposed = false;
  bool _isSyncing = false;

  OfflineSyncHandler({
    required SyncCoordinator coordinator,
    required SyncStateMachine stateMachine,
  })  : _coordinator = coordinator,
        _stateMachine = stateMachine;

  /// Configura auto-sync para um app
  void setupAutoSync(String appName) {
    final config = _coordinator.getAppConfig(appName);
    if (config == null || !config.enableAutoSync) return;

    // Cancela timer existente
    _syncTimers[appName]?.cancel();

    // Cria novo timer periódico
    _syncTimers[appName] = Timer.periodic(config.syncInterval, (timer) {
      if (_stateMachine.canAppSync(appName)) {
        _triggerAutoSyncForApp(appName);
      }
    });

    developer.log(
      'Auto sync enabled for $appName (${config.syncInterval})',
      name: 'OfflineSyncHandler',
    );
  }

  /// Dispara auto-sync para um app (sem aguardar)
  void _triggerAutoSyncForApp(String appName) {
    Future.microtask(() async {
      try {
        await forceSyncApp(appName);
      } catch (e) {
        developer.log(
          'Auto sync error for $appName: $e',
          name: 'OfflineSyncHandler',
        );
      }
    });
  }

  /// Força sincronização de todas as entidades de um app
  Future<Either<Failure, void>> forceSyncApp(String appName) async {
    if (_isSyncing) {
      return const Left(SyncFailure('Sync already in progress'));
    }

    try {
      _isSyncing = true;

      final repositories = _coordinator.getAppRepositories(appName);
      if (repositories == null || repositories.isEmpty) {
        return Left(NotFoundFailure('No repositories found for app $appName'));
      }

      developer.log(
        'Force syncing $appName (${repositories.length} entities)',
        name: 'OfflineSyncHandler',
      );

      // Sincroniza cada repositório
      final futures = repositories.values.map((repo) => repo.forceSync());
      final results = await Future.wait(futures);

      // Verifica se algum falhou
      for (final result in results) {
        if (result.isLeft()) {
          return result;
        }
      }

      // Atualiza status
      await _stateMachine.updateAppStatus(appName);

      developer.log(
        'Force sync completed for $appName',
        name: 'OfflineSyncHandler',
      );

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Error during force sync: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Força sincronização de uma entidade específica
  Future<Either<Failure, void>> forceSyncEntity<T extends BaseSyncEntity>(
    String appName,
  ) async {
    try {
      final repository = _coordinator.getRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      final result = await repository.forceSync();

      if (result.isRight()) {
        await _stateMachine.updateAppStatus(appName);
      }

      return result;
    } catch (e) {
      return Left(SyncFailure('Error during entity force sync: $e'));
    }
  }

  /// Sincroniza items não sincronizados em background
  Future<void> syncUnsyncedItems(String appName) async {
    Future.microtask(() async {
      try {
        final repositories = _coordinator.getAppRepositories(appName);
        if (repositories == null) return;

        for (final repo in repositories.values) {
          try {
            final unsyncedResult = await repo.getUnsyncedItems();

            unsyncedResult.fold(
              (failure) => developer.log(
                'Error getting unsynced items: ${failure.message}',
                name: 'OfflineSyncHandler',
              ),
              (unsyncedItems) async {
                if (unsyncedItems.isNotEmpty) {
                  developer.log(
                    'Syncing ${unsyncedItems.length} unsynced items',
                    name: 'OfflineSyncHandler',
                  );
                  await repo.forceSync();
                }
              },
            );
          } catch (e) {
            developer.log(
              'Error syncing repository: $e',
              name: 'OfflineSyncHandler',
            );
          }
        }

        await _stateMachine.updateAppStatus(appName);
      } catch (e) {
        developer.log(
          'Error syncing unsynced items for $appName: $e',
          name: 'OfflineSyncHandler',
        );
      }
    });
  }

  /// Limpa dados locais de um app
  Future<Either<Failure, void>> clearAppData(String appName) async {
    try {
      final repositories = _coordinator.getAppRepositories(appName);
      if (repositories == null) {
        return Left(NotFoundFailure('App $appName not found'));
      }

      // Limpa cada repositório
      final futures = repositories.values.map((repo) => repo.clearLocalData());
      final results = await Future.wait(futures);

      // Verifica se algum falhou
      for (final result in results) {
        if (result.isLeft()) {
          return result;
        }
      }

      developer.log('Local data cleared for app $appName', name: 'OfflineSyncHandler');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error clearing app data: $e'));
    }
  }

  /// Para auto-sync de um app
  void stopAutoSync(String appName) {
    _syncTimers[appName]?.cancel();
    _syncTimers.remove(appName);
    developer.log('Auto sync stopped for $appName', name: 'OfflineSyncHandler');
  }

  /// Para todos os auto-syncs
  void stopAllAutoSync() {
    for (final timer in _syncTimers.values) {
      timer.cancel();
    }
    _syncTimers.clear();
    developer.log('All auto syncs stopped', name: 'OfflineSyncHandler');
  }

  /// Verifica se está sincronizando
  bool get isSyncing => _isSyncing;

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    stopAllAutoSync();
    developer.log('OfflineSyncHandler disposed', name: 'OfflineSyncHandler');
  }

  @override
  bool get isDisposed => _isDisposed;
}
