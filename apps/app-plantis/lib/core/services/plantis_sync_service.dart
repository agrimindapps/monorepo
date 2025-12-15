import 'dart:async';
import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../database/sync/adapters/subscription_drift_sync_adapter.dart';
import '../../../features/plants/domain/repositories/plant_comments_repository.dart';
import '../../../features/plants/domain/repositories/plant_tasks_repository.dart';
import '../../../features/plants/domain/repositories/plants_repository.dart';
import '../../../features/plants/domain/repositories/spaces_repository.dart';

/// Implementação do serviço de sincronização para o Plantis
/// Implementa ISyncService para integrar com o sistema de sync do core
class PlantisSyncService implements ISyncService {
  /// Repositories reserved for future implementation of entity-specific sync methods
  /// Currently only subscriptions sync is implemented via _subscriptionSyncAdapter
  /// These will be used when _syncPlants, _syncSpaces, _syncTasks, and _syncComments are implemented
  // final PlantsRepository _plantsRepository;
  // final SpacesRepository _spacesRepository;
  // final PlantTasksRepository _plantTasksRepository;
  // final PlantCommentsRepository _plantCommentsRepository;

  final SubscriptionDriftSyncAdapter _subscriptionSyncAdapter;
  final IAuthRepository _authRepository;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController = StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  bool _isInitialized = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  PlantisSyncService({
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required PlantTasksRepository plantTasksRepository,
    required PlantCommentsRepository plantCommentsRepository,
    required SubscriptionDriftSyncAdapter subscriptionSyncAdapter,
    required IAuthRepository authRepository,
  }) : _subscriptionSyncAdapter = subscriptionSyncAdapter,
       _authRepository = authRepository;
       // Note: Repository parameters are kept for future implementation
       // They will be assigned to fields when sync methods are fully implemented

  @override
  String get serviceId => 'plantis';

  @override
  String get displayName => 'Plantis Sync Service';

  @override
  String get version => '2.0.0';

  @override
  bool get canSync =>
      _isInitialized && _currentStatus != SyncServiceStatus.syncing;

  @override
  Future<bool> get hasPendingSync async {
    // Implementar lógica para verificar se há dados pendentes
    // Por enquanto, retorna false para evitar syncs desnecessários
    return false;
  }

  @override
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;

  @override
  Stream<ServiceProgress> get progressStream => _progressController.stream;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      _updateStatus(SyncServiceStatus.idle);
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ PlantisSyncService initialized');
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize PlantisSyncService: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    if (!canSync) {
      return const Left(ServerFailure('Service not ready for sync'));
    }

    _updateStatus(SyncServiceStatus.syncing);

    try {
      int totalSynced = 0;
      int totalFailed = 0;

      // Sync subscriptions
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_subscriptions',
          current: 0,
          total: 5,
          currentItem: 'Sincronizando assinaturas...',
        ),
      );

      final subscriptionsResult = await _syncSubscriptions();
      subscriptionsResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync plants
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_plants',
          current: 1,
          total: 5,
          currentItem: 'Sincronizando plantas...',
        ),
      );

      final plantsResult = await _syncPlants();
      plantsResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync spaces
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_spaces',
          current: 2,
          total: 5,
          currentItem: 'Sincronizando espaços...',
        ),
      );

      final spacesResult = await _syncSpaces();
      spacesResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync tasks
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_tasks',
          current: 3,
          total: 5,
          currentItem: 'Sincronizando tarefas...',
        ),
      );

      final tasksResult = await _syncTasks();
      tasksResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync comments
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_comments',
          current: 4,
          total: 5,
          currentItem: 'Sincronizando comentários...',
        ),
      );

      final commentsResult = await _syncComments();
      commentsResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'completed',
          current: 5,
          total: 5,
          currentItem: 'Sincronização concluída',
        ),
      );

      _updateStatus(SyncServiceStatus.completed);

      return Right(
        ServiceSyncResult(
          success: totalFailed == 0,
          itemsSynced: totalSynced,
          itemsFailed: totalFailed,
          duration: Duration.zero,
        ),
      );
    } catch (e) {
      _updateStatus(SyncServiceStatus.failed);

      return Left(ServerFailure('Sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(
    List<String> ids,
  ) async {
    // Implementação simplificada - sync completa por enquanto
    return sync();
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.idle);
  }

  @override
  Future<bool> checkConnectivity() async {
    // Implementar verificação de conectividade
    return true;
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      // Implementar limpeza de dados locais se necessário
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear local data: $e'));
    }
  }

  @override
  Future<SyncStatistics> getStatistics() async {
    return const SyncStatistics(
      serviceId: 'plantis',
      totalSyncs: 0,
      successfulSyncs: 0,
      failedSyncs: 0,
    );
  }

  @override
  Future<void> dispose() async {
    _updateStatus(SyncServiceStatus.disposing);
    await _connectivitySubscription?.cancel();
    await _statusController.close();
    await _progressController.close();
  }

  // Métodos auxiliares para sync de cada entidade
  Future<Either<Failure, int>> _syncSubscriptions() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return const Right(0);

      int totalSynced = 0;

      // 1. Push local changes
      final pushResult = await _subscriptionSyncAdapter.pushDirtyRecords(
        user.id,
      );

      if (pushResult.isLeft()) {
        return Left((pushResult as Left<Failure, SyncPushResult>).value);
      }

      totalSynced +=
          (pushResult as Right<Failure, SyncPushResult>).value.recordsPushed;

      // 2. Pull remote changes
      final pullResult = await _subscriptionSyncAdapter.pullRemoteChanges(
        user.id,
      );

      if (pullResult.isLeft()) {
        return Left((pullResult as Left<Failure, SyncPullResult>).value);
      }

      totalSynced +=
          (pullResult as Right<Failure, SyncPullResult>).value.recordsPulled;

      return Right(totalSynced);
    } catch (e) {
      return Left(ServerFailure('Failed to sync subscriptions: $e'));
    }
  }

  Future<Either<Failure, int>> _syncPlants() async {
    try {
      // Implementar sync de plantas
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync plants: $e'));
    }
  }

  Future<Either<Failure, int>> _syncSpaces() async {
    try {
      // Implementar sync de espaços
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync spaces: $e'));
    }
  }

  Future<Either<Failure, int>> _syncTasks() async {
    try {
      // Implementar sync de tarefas
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync tasks: $e'));
    }
  }

  Future<Either<Failure, int>> _syncComments() async {
    try {
      // Implementar sync de comentários
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync comments: $e'));
    }
  }

  void _updateStatus(SyncServiceStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Método legado para compatibilidade - será removido em versões futuras
  void startConnectivityMonitoring(Stream<dynamic> connectivityStream) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivityStream.listen((event) {
      // Implementar lógica de monitoramento de conectividade se necessário
    });
  }
}

/// Factory para criar instâncias do PlantisSyncService
class PlantisSyncServiceFactory {
  static PlantisSyncService create({
    required PlantsRepository plantsRepository,
    required SpacesRepository spacesRepository,
    required PlantTasksRepository plantTasksRepository,
    required PlantCommentsRepository plantCommentsRepository,
    required SubscriptionDriftSyncAdapter subscriptionSyncAdapter,
    required IAuthRepository authRepository,
  }) {
    return PlantisSyncService(
      plantsRepository: plantsRepository,
      spacesRepository: spacesRepository,
      plantTasksRepository: plantTasksRepository,
      plantCommentsRepository: plantCommentsRepository,
      subscriptionSyncAdapter: subscriptionSyncAdapter,
      authRepository: authRepository,
    );
  }
}
