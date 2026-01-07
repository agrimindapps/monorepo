import 'dart:async';
import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../features/items/data/adapters/item_master_drift_sync_adapter.dart';
import '../../features/items/data/adapters/list_item_drift_sync_adapter.dart';
import '../../features/items/data/repositories/item_master_repository.dart';
import '../../features/items/data/repositories/list_item_repository.dart';
import '../../features/lists/data/adapters/list_drift_sync_adapter.dart';
import '../../features/lists/data/repositories/list_repository.dart';

/// Implementação do serviço de sincronização para o Nebulalist
/// Implementa ISyncService para integrar com o sistema de sync do core
///
/// **Padrão:** Baseado em app-plantis/PlantisSyncService
///
/// **Responsabilidades:**
/// 1. Coordenar sync de Lists, ItemMasters e ListItems
/// 2. Reportar progresso via streams
/// 3. Gerenciar status de sync
/// 4. Integrar com UnifiedSyncManager
///
/// **Quando usar:**
/// - Sync automático após login
/// - Sync manual (pull-to-refresh)
/// - Background sync periódico
///
/// **Exemplo:**
/// ```dart
/// final syncService = NebulalistSyncService(
///   listRepository: listRepository,
///   itemMasterRepository: itemMasterRepository,
///   listItemRepository: listItemRepository,
///   authRepository: authRepository,
/// );
///
/// await syncService.initialize();
///
/// // Sync completo
/// final result = await syncService.sync();
/// result.fold(
///   (failure) => print('Sync failed: ${failure.message}'),
///   (syncResult) => print('Synced ${syncResult.itemsSynced} items'),
/// );
/// ```
class NebulalistSyncService implements ISyncService {
  // Repositories (future use for advanced sync operations)
  // ignore: unused_field
  final ListRepository _listRepository;
  // ignore: unused_field
  final ItemMasterRepository _itemMasterRepository;
  // ignore: unused_field
  final ListItemRepository _listItemRepository;
  final IAuthRepository _authRepository;

  // Sync adapters
  final ListDriftSyncAdapter _listSyncAdapter;
  final ItemMasterDriftSyncAdapter _itemMasterSyncAdapter;
  final ListItemDriftSyncAdapter _listItemSyncAdapter;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController = StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  bool _isInitialized = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  NebulalistSyncService({
    required ListRepository listRepository,
    required ItemMasterRepository itemMasterRepository,
    required ListItemRepository listItemRepository,
    required IAuthRepository authRepository,
    required ListDriftSyncAdapter listSyncAdapter,
    required ItemMasterDriftSyncAdapter itemMasterSyncAdapter,
    required ListItemDriftSyncAdapter listItemSyncAdapter,
  })  : _listRepository = listRepository,
        _itemMasterRepository = itemMasterRepository,
        _listItemRepository = listItemRepository,
        _authRepository = authRepository,
        _listSyncAdapter = listSyncAdapter,
        _itemMasterSyncAdapter = itemMasterSyncAdapter,
        _listItemSyncAdapter = listItemSyncAdapter;

  @override
  String get serviceId => 'nebulalist';

  @override
  String get displayName => 'Nebulalist Sync Service';

  @override
  String get version => '1.0.0';

  @override
  bool get canSync =>
      _isInitialized && _currentStatus != SyncServiceStatus.syncing;

  @override
  Future<bool> get hasPendingSync async {
    // TODO: Verificar sync queue para items pendentes
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
        debugPrint('✅ NebulalistSyncService initialized');
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to initialize NebulalistSyncService: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    if (!canSync) {
      return const Left(ServerFailure('Service not ready for sync'));
    }

    _updateStatus(SyncServiceStatus.syncing);
    final startTime = DateTime.now();

    try {
      int totalSynced = 0;
      int totalFailed = 0;

      // 1. Sync Lists
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_lists',
          current: 0,
          total: 3,
          currentItem: 'Sincronizando listas...',
        ),
      );

      final listsResult = await _syncLists();
      listsResult.fold(
        (failure) => totalFailed++,
        (syncCount) => totalSynced += syncCount,
      );

      // 2. Sync ItemMasters
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_item_masters',
          current: 1,
          total: 3,
          currentItem: 'Sincronizando banco de itens...',
        ),
      );

      final itemMastersResult = await _syncItemMasters();
      itemMastersResult.fold(
        (failure) => totalFailed++,
        (syncCount) => totalSynced += syncCount,
      );

      // 3. Sync ListItems
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_list_items',
          current: 2,
          total: 3,
          currentItem: 'Sincronizando itens das listas...',
        ),
      );

      final listItemsResult = await _syncListItems();
      listItemsResult.fold(
        (failure) => totalFailed++,
        (syncCount) => totalSynced += syncCount,
      );

      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'completed',
          current: 3,
          total: 3,
          currentItem: 'Sincronização concluída',
        ),
      );

      _updateStatus(SyncServiceStatus.completed);

      final duration = DateTime.now().difference(startTime);

      return Right(
        ServiceSyncResult(
          success: totalFailed == 0,
          itemsSynced: totalSynced,
          itemsFailed: totalFailed,
          duration: duration,
        ),
      );
    } catch (e) {
      _updateStatus(SyncServiceStatus.failed);

      // ignore: unused_local_variable
      final duration = DateTime.now().difference(startTime);

      return Left(ServerFailure('Sync failed: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(
    List<String> ids,
  ) async {
    // Implementação simplificada - sync completa por enquanto
    // TODO: Implementar sync seletivo baseado em IDs
    return sync();
  }

  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.idle);
  }

  @override
  Future<bool> checkConnectivity() async {
    // TODO: Implementar verificação de conectividade real
    return true;
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      // TODO: Implementar limpeza de dados locais se necessário
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear local data: $e'));
    }
  }

  @override
  Future<SyncStatistics> getStatistics() async {
    // TODO: Implementar coleta de estatísticas reais
    return const SyncStatistics(
      serviceId: 'nebulalist',
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

  // =========================================================================
  // MÉTODOS AUXILIARES PARA SYNC DE CADA ENTIDADE
  // =========================================================================

  /// Sincroniza Lists (local <-> remote)
  ///
  /// Usa ListDriftSyncAdapter para push/pull
  Future<Either<Failure, int>> _syncLists() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return const Right(0);

      final userId = user.id;

      // 1. Push local changes
      final pushResult = await _listSyncAdapter.pushDirtyRecords(userId);
      if (pushResult.isLeft()) {
        return Left((pushResult as Left<Failure, dynamic>).value);
      }

      final pushed =
          (pushResult as Right<Failure, dynamic>).value.recordsPushed as int;

      // 2. Pull remote changes
      final pullResult = await _listSyncAdapter.pullRemoteChanges(userId);
      if (pullResult.isLeft()) {
        return Left((pullResult as Left<Failure, dynamic>).value);
      }

      final pulled =
          (pullResult as Right<Failure, dynamic>).value.recordsPulled as int;
      final updated =
          (pullResult as Right<Failure, dynamic>).value.recordsUpdated as int;

      return Right(pushed + pulled + updated);
    } catch (e) {
      return Left(ServerFailure('Failed to sync lists: $e'));
    }
  }

  /// Sincroniza ItemMasters (local <-> remote)
  ///
  /// Usa ItemMasterDriftSyncAdapter para push/pull
  Future<Either<Failure, int>> _syncItemMasters() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return const Right(0);

      final userId = user.id;

      // 1. Push local changes
      final pushResult = await _itemMasterSyncAdapter.pushDirtyRecords(userId);
      if (pushResult.isLeft()) {
        return Left((pushResult as Left<Failure, dynamic>).value);
      }

      final pushed =
          (pushResult as Right<Failure, dynamic>).value.recordsPushed as int;

      // 2. Pull remote changes
      final pullResult =
          await _itemMasterSyncAdapter.pullRemoteChanges(userId);
      if (pullResult.isLeft()) {
        return Left((pullResult as Left<Failure, dynamic>).value);
      }

      final pulled =
          (pullResult as Right<Failure, dynamic>).value.recordsPulled as int;
      final updated =
          (pullResult as Right<Failure, dynamic>).value.recordsUpdated as int;

      return Right(pushed + pulled + updated);
    } catch (e) {
      return Left(ServerFailure('Failed to sync item masters: $e'));
    }
  }

  /// Sincroniza ListItems (local <-> remote)
  ///
  /// Usa ListItemDriftSyncAdapter para push/pull de todas as listas
  Future<Either<Failure, int>> _syncListItems() async {
    try {
      final user = await _authRepository.currentUser.first;
      if (user == null) return const Right(0);

      // ignore: unused_local_variable
      final userId = user.id;

      // 1. Get all user lists
      final listsResult = await _listRepository.getLists();
      if (listsResult.isLeft()) {
        return const Right(0); // Skip if can't get lists
      }

      final lists = (listsResult as Right<Failure, dynamic>).value as List;
      final listIds = lists.map((list) => list.id as String).toList();

      if (listIds.isEmpty) {
        return const Right(0);
      }

      // 2. Sync all lists
      final result = await _listItemSyncAdapter.syncAllLists(listIds);
      if (result.isLeft()) {
        return Left((result as Left<Failure, dynamic>).value);
      }

      final total =
          (result as Right<Failure, dynamic>).value['total'] as int;

      return Right(total);
    } catch (e) {
      return Left(ServerFailure('Failed to sync list items: $e'));
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
      // TODO: Implementar lógica de monitoramento de conectividade se necessário
    });
  }
}

/// Factory para criar instâncias do NebulalistSyncService
class NebulalistSyncServiceFactory {
  static NebulalistSyncService create({
    required ListRepository listRepository,
    required ItemMasterRepository itemMasterRepository,
    required ListItemRepository listItemRepository,
    required IAuthRepository authRepository,
    required ListDriftSyncAdapter listSyncAdapter,
    required ItemMasterDriftSyncAdapter itemMasterSyncAdapter,
    required ListItemDriftSyncAdapter listItemSyncAdapter,
  }) {
    return NebulalistSyncService(
      listRepository: listRepository,
      itemMasterRepository: itemMasterRepository,
      listItemRepository: listItemRepository,
      authRepository: authRepository,
      listSyncAdapter: listSyncAdapter,
      itemMasterSyncAdapter: itemMasterSyncAdapter,
      listItemSyncAdapter: listItemSyncAdapter,
    );
  }
}
