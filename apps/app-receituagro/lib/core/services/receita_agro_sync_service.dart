import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../database/sync/adapters/subscription_drift_sync_adapter.dart';
import '../../features/favoritos/data/repositories/favoritos_repository_simplified.dart';

/// Implementação do serviço de sincronização para o ReceitaAgro
/// Implementa ISyncService para integrar com o sistema de sync do core
class ReceitaAgroSyncService implements ISyncService {
  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController = StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  DateTime? _lastSyncTime;
  bool _isInitialized = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  final FavoritosRepositorySimplified? _favoritosRepository;
  final SubscriptionDriftSyncAdapter? _subscriptionSyncAdapter;
  final IAuthRepository? _authRepository;

  ReceitaAgroSyncService({
    FavoritosRepositorySimplified? favoritosRepository,
    SubscriptionDriftSyncAdapter? subscriptionSyncAdapter,
    IAuthRepository? authRepository,
  })  : _favoritosRepository = favoritosRepository,
        _subscriptionSyncAdapter = subscriptionSyncAdapter,
        _authRepository = authRepository;

  SyncServiceStatus get syncState => _currentStatus;
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  String get serviceId => 'receituagro';

  @override
  String get displayName => 'ReceitaAgro Sync Service';

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
        print('✅ ReceitaAgroSyncService initialized');
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to initialize ReceitaAgroSyncService: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    if (!canSync) {
      return const Left(ServerFailure('Service not ready for sync'));
    }

    final startTime = DateTime.now();
    _updateStatus(SyncServiceStatus.syncing);

    try {
      int totalSynced = 0;
      int totalFailed = 0;

      // Usar o unified sync manager para operações de sync
      // Por enquanto apenas log, mas pode ser expandido

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

      // Sync diagnostics
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_diagnostics',
          current: 1,
          total: 5,
          currentItem: 'Sincronizando diagnósticos...',
        ),
      );

      final diagnosticsResult = await _syncDiagnostics();
      diagnosticsResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync crops
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_crops',
          current: 2,
          total: 5,
          currentItem: 'Sincronizando culturas...',
        ),
      );

      final cropsResult = await _syncCrops();
      cropsResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync pests
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_pests',
          current: 3,
          total: 5,
          currentItem: 'Sincronizando pragas...',
        ),
      );

      final pestsResult = await _syncPests();
      pestsResult.fold(
        (failure) => totalFailed++,
        (count) => totalSynced += count,
      );

      // Sync phytosanitary products
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_phytosanitary',
          current: 4,
          total: 5,
          currentItem: 'Sincronizando fitossanitários...',
        ),
      );

      final phytosanitaryResult = await _syncPhytosanitary();
      phytosanitaryResult.fold(
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

      final duration = DateTime.now().difference(startTime);
      _lastSyncTime = DateTime.now();
      _updateStatus(SyncServiceStatus.completed);

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
      serviceId: 'receituagro',
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

  /// Método específico para sync de dados do usuário (comentários e favoritos)
  /// Sincroniza dados do Firestore após login
  Future<Either<Failure, ServiceSyncResult>> syncUserData() async {
    if (!canSync) {
      return const Left(ServerFailure('Service not ready for user data sync'));
    }

    final startTime = DateTime.now();
    _updateStatus(SyncServiceStatus.syncing);

    try {
      int totalSynced = 0;
      int totalFailed = 0;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          print('⚠️ User not authenticated for sync');
        }
        final duration = DateTime.now().difference(startTime);
        _updateStatus(SyncServiceStatus.completed);
        return Right(
          ServiceSyncResult(
            success: true,
            itemsSynced: 0,
            itemsFailed: 0,
            duration: duration,
          ),
        );
      }

      // Sync favoritos (comentários são sincronizados automaticamente pelo UnifiedSyncManager)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'syncing_favoritos',
          current: 0,
          total: 1,
          currentItem: 'Sincronizando favoritos...',
        ),
      );

      final favoritosResult = await _syncFavoritos();
      favoritosResult.fold(
        (failure) {
          totalFailed++;
          if (kDebugMode) {
            print('⚠️ Falha ao sincronizar favoritos: ${failure.message}');
          }
        },
        (count) {
          totalSynced += count;
          if (kDebugMode) print('✅ Favoritos sincronizados: $count');
        },
      );

      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'completed',
          current: 1,
          total: 1,
          currentItem: 'Sincronização de dados do usuário concluída',
        ),
      );

      final duration = DateTime.now().difference(startTime);
      _updateStatus(SyncServiceStatus.completed);

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
      if (kDebugMode) print('❌ Erro ao sincronizar dados do usuário: $e');

      return Left(ServerFailure('User data sync failed: $e'));
    }
  }

  // Métodos auxiliares para sync de cada entidade
  Future<Either<Failure, int>> _syncSubscriptions() async {
    try {
      if (_authRepository == null || _subscriptionSyncAdapter == null) {
        return const Right(0);
      }

      final user = await _authRepository!.currentUser.first;
      if (user == null) return const Right(0);

      int totalSynced = 0;

      // 1. Push local changes
      final pushResult = await _subscriptionSyncAdapter!.pushDirtyRecords(user.id);
      
      if (pushResult.isLeft()) {
        return Left((pushResult as Left<Failure, SyncPushResult>).value);
      }
      
      totalSynced += (pushResult as Right<Failure, SyncPushResult>).value.recordsPushed;

      // 2. Pull remote changes
      final pullResult = await _subscriptionSyncAdapter!.pullRemoteChanges(user.id);
      
      if (pullResult.isLeft()) {
        return Left((pullResult as Left<Failure, SyncPullResult>).value);
      }

      totalSynced += (pullResult as Right<Failure, SyncPullResult>).value.recordsPulled;

      return Right(totalSynced);
    } catch (e) {
      return Left(ServerFailure('Failed to sync subscriptions: $e'));
    }
  }

  Future<Either<Failure, int>> _syncDiagnostics() async {
    try {
      // Implementar sync de diagnósticos
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync diagnostics: $e'));
    }
  }

  Future<Either<Failure, int>> _syncCrops() async {
    try {
      // Implementar sync de culturas
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync crops: $e'));
    }
  }

  Future<Either<Failure, int>> _syncPests() async {
    try {
      // Implementar sync de pragas
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync pests: $e'));
    }
  }

  Future<Either<Failure, int>> _syncPhytosanitary() async {
    try {
      // Implementar sync de fitossanitários
      // Por enquanto retorna sucesso com 0 itens
      return const Right(0);
    } catch (e) {
      return Left(ServerFailure('Failed to sync phytosanitary products: $e'));
    }
  }

  /// Sincroniza favoritos
  /// Nota: Favoritos são armazenados via UnifiedSyncManager, esta função apenas recarrega
  Future<Either<Failure, int>> _syncFavoritos() async {
    try {
      try {
        if (_favoritosRepository == null) {
          if (kDebugMode)
            print(
              '⚠️ FavoritosRepository not injected in ReceitaAgroSyncService',
            );
          return const Right(0);
        }

        final favoritosRepo = _favoritosRepository;

        // Dispara sincronização dos favoritos (carrega da storage local)
        await favoritosRepo.syncFavorites();

        // Obtém estatísticas para contar
        final statsResult = await favoritosRepo.getStats();

        // Unwrap Either<Failure, FavoritosStats>
        final totalFavoritos = statsResult.fold(
          (failure) => 0, // On error, return 0
          (stats) =>
              stats.totalDefensivos +
              stats.totalPragas +
              stats.totalDiagnosticos +
              stats.totalCulturas,
        );

        if (kDebugMode) {
          print('✅ Favoritos sincronizados - Total: $totalFavoritos');
        }

        return Right(totalFavoritos);
      } catch (e) {
        // Se não conseguir, tenta sem erro crítico
        if (kDebugMode) print('⚠️ Aviso ao sincronizar favoritos: $e');
        return const Right(0);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao sincronizar favoritos: $e');
      return Left(ServerFailure('Erro ao sincronizar favoritos: $e'));
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

/// Factory para criar instâncias do ReceitaAgroSyncService
class ReceitaAgroSyncServiceFactory {
  static ReceitaAgroSyncService create({
    FavoritosRepositorySimplified? favoritosRepository,
    SubscriptionDriftSyncAdapter? subscriptionSyncAdapter,
    IAuthRepository? authRepository,
  }) {
    return ReceitaAgroSyncService(
      favoritosRepository: favoritosRepository,
      subscriptionSyncAdapter: subscriptionSyncAdapter,
      authRepository: authRepository,
    );
  }
}
