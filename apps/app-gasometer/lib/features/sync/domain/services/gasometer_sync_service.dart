import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import 'sync_push_service.dart';
import 'sync_pull_service.dart';

/// Orquestrador de sincronização para o Gasometer
///
/// Coordena os serviços de push e pull sincronização:
/// - SyncPushService (5 adapters push)
/// - SyncPullService (5 adapters pull)
///
/// Implementa ISyncService para integrar com o sistema de sync do core.
///
/// **Fluxo de Sincronização:**
/// 1. Push: Delega para SyncPushService
/// 2. Pull: Delega para SyncPullService
/// 3. Reporta progresso detalhado
/// 4. Agrega resultados e estatísticas
///
/// **Error Handling:**
/// - Um adapter falhando não interrompe os outros
/// - Erros são agregados e reportados no final
/// - Logging detalhado para debugging
class GasometerSyncService implements ISyncService {
  GasometerSyncService({
    required SyncPushService pushService,
    required SyncPullService pullService,
  })  : _pushService = pushService,
        _pullService = pullService;

  final SyncPushService _pushService;
  final SyncPullService _pullService;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController = StreamController<ServiceProgress>.broadcast();

  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  bool _isInitialized = false;
  StreamSubscription<dynamic>? _connectivitySubscription;

  @override
  String get serviceId => 'gasometer';

  @override
  String get displayName => 'Gasometer Sync Service';

  @override
  String get version => '3.0.0';

  @override
  bool get canSync =>
      _isInitialized && _currentStatus != SyncServiceStatus.syncing;

  Either<Failure, String> get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Left(AuthFailure('No authenticated user'));
    }
    return Right(user.uid);
  }

  @override
  Future<bool> get hasPendingSync async {
    try {
      final userIdResult = _currentUserId;
      if (userIdResult.isLeft()) {
        developer.log(
          '⚠️ Cannot check pending sync: user not authenticated',
          name: 'GasometerSync',
        );
        return false;
      }

      // Query pending directly - implementation delegated to adapters
      // For now, return false to avoid complex queries
      return false;
    } catch (e) {
      developer.log('❌ Error checking pending sync: $e', name: 'GasometerSync');
      return false;
    }
  }

  @override
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;

  @override
  Stream<ServiceProgress> get progressStream => _progressController.stream;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        developer.log('⚠️ Already initialized', name: 'GasometerSync');
        return const Right(null);
      }

      _updateStatus(SyncServiceStatus.idle);
      _isInitialized = true;

      developer.log(
        '✅ GasometerSyncService v$version initialized',
        name: 'GasometerSync',
      );
      developer.log(
        '   Delegates to: SyncPushService + SyncPullService',
        name: 'GasometerSync',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log('❌ Failed to initialize: $e', name: 'GasometerSync');
      developer.log('$stackTrace', name: 'GasometerSync');

      return Left(
        ServerFailure('Failed to initialize GasometerSyncService: $e'),
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
      final userIdResult = _currentUserId;
      if (userIdResult.isLeft()) {
        _updateStatus(SyncServiceStatus.failed);
        return const Left(AuthFailure('User not authenticated'));
      }
      final userId = userIdResult.getOrElse(() => '');

      developer.log(
        '🔄 Starting sync for user: $userId',
        name: 'GasometerSync',
      );

      int totalSynced = 0;
      int totalFailed = 0;
      final errors = <String>[];

      // ========== PUSH PHASE ==========
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pushing',
          current: 0,
          total: 2,
          currentItem: 'Enviando mudanças locais...',
        ),
      );

      final pushResult = await _pushService.pushAll(userId);
      pushResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Push: ${failure.message}');
          developer.log(
            '❌ Push failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (phaseResult) {
          // phaseResult is SyncPhaseResult combining all adapters
          totalSynced = totalSynced + (phaseResult?.successCount ?? 0);
          totalFailed = totalFailed + (phaseResult?.failureCount ?? 0);
          if ((phaseResult?.errors ?? []).isNotEmpty) {
            errors.addAll(phaseResult?.errors ?? []);
          }
          developer.log(
            '✅ Push completed: ${phaseResult?.successCount ?? 0} records pushed',
            name: 'GasometerSync',
          );
        },
      );

      // ========== PULL PHASE ==========
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pulling',
          current: 1,
          total: 2,
          currentItem: 'Baixando mudanças remotas...',
        ),
      );

      final pullResult = await _pullService.pullAll(userId);
      pullResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Pull: ${failure.message}');
          developer.log(
            '❌ Pull failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (phaseResult) {
          // phaseResult is SyncPhaseResult combining all adapters
          totalSynced += phaseResult.successCount;
          if (phaseResult.errors.isNotEmpty) {
            errors.addAll(phaseResult.errors);
          }
          developer.log(
            '✅ Pull completed: ${phaseResult.successCount} records pulled',
            name: 'GasometerSync',
          );
        },
      );

      // ========== FINALIZATION ==========
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'completed',
          current: 2,
          total: 2,
          currentItem: 'Sincronização concluída',
        ),
      );

      final duration = DateTime.now().difference(startTime);
      _updateStatus(SyncServiceStatus.completed);

      developer.log(
        '✅ Sync completed: $totalSynced items synced, $totalFailed failed',
        name: 'GasometerSync',
      );
      developer.log(
        '   Duration: ${duration.inSeconds}s',
        name: 'GasometerSync',
      );

      if (errors.isNotEmpty) {
        developer.log('   Errors: ${errors.join(', ')}', name: 'GasometerSync');
      }

      return Right(
        ServiceSyncResult(
          success: totalFailed == 0,
          itemsSynced: totalSynced,
          itemsFailed: totalFailed,
          duration: duration,
          error: errors.isEmpty ? null : errors.join('; '),
        ),
      );
    } catch (e, stackTrace) {
      _updateStatus(SyncServiceStatus.failed);

      developer.log('❌ Sync failed with exception: $e', name: 'GasometerSync');
      developer.log('$stackTrace', name: 'GasometerSync');

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
    return true;
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear local data: $e'));
    }
  }

  @override
  Future<SyncStatistics> getStatistics() async {
    return const SyncStatistics(
      serviceId: 'gasometer',
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

    developer.log('🧹 GasometerSyncService disposed', name: 'GasometerSync');
  }

  void _updateStatus(SyncServiceStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void startConnectivityMonitoring(Stream<dynamic> connectivityStream) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivityStream.listen((event) {
      // Implementar lógica de monitoramento se necessário
    });
  }
}
