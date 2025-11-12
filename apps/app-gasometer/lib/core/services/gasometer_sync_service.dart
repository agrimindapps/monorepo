import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../features/expenses/data/sync/expense_drift_sync_adapter.dart';
import '../../features/fuel/data/sync/fuel_supply_drift_sync_adapter.dart';
import '../../features/maintenance/data/sync/maintenance_drift_sync_adapter.dart';
import '../../features/odometer/data/sync/odometer_drift_sync_adapter.dart';
import '../../features/vehicles/data/sync/vehicle_drift_sync_adapter.dart';

/// Orquestrador de sincronização para o Gasometer
///
/// Coordena os 5 adapters de sincronização Drift ↔ Firestore:
/// - VehicleDriftSyncAdapter (veículos)
/// - FuelSupplyDriftSyncAdapter (abastecimentos)
/// - MaintenanceDriftSyncAdapter (manutenções)
/// - ExpenseDriftSyncAdapter (despesas)
/// - OdometerDriftSyncAdapter (odômetro)
///
/// Implementa ISyncService para integrar com o sistema de sync do core.
///
/// **Fluxo de Sincronização:**
/// 1. Push: Envia registros dirty locais → Firestore (5 adapters)
/// 2. Pull: Baixa mudanças remotas → Drift (5 adapters)
/// 3. Reporta progresso detalhado (10 steps: 5 push + 5 pull)
/// 4. Agrega resultados e estatísticas
///
/// **Error Handling:**
/// - Um adapter falhando não interrompe os outros
/// - Erros são agregados e reportados no final
/// - Logging detalhado para debugging
@lazySingleton
class GasometerSyncService implements ISyncService {
  GasometerSyncService({
    required VehicleDriftSyncAdapter vehicleAdapter,
    required FuelSupplyDriftSyncAdapter fuelAdapter,
    required MaintenanceDriftSyncAdapter maintenanceAdapter,
    required ExpenseDriftSyncAdapter expenseAdapter,
    required OdometerDriftSyncAdapter odometerAdapter,
  }) : _vehicleAdapter = vehicleAdapter,
       _fuelAdapter = fuelAdapter,
       _maintenanceAdapter = maintenanceAdapter,
       _expenseAdapter = expenseAdapter,
       _odometerAdapter = odometerAdapter;

  final VehicleDriftSyncAdapter _vehicleAdapter;
  final FuelSupplyDriftSyncAdapter _fuelAdapter;
  final MaintenanceDriftSyncAdapter _maintenanceAdapter;
  final ExpenseDriftSyncAdapter _expenseAdapter;
  final OdometerDriftSyncAdapter _odometerAdapter;

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

  /// Obtém o userId do usuário autenticado
  ///
  /// Retorna:
  /// - Right(userId): Usuário autenticado
  /// - Left(AuthFailure): Usuário não autenticado
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

      final userId = userIdResult.getOrElse(() => '');

      // Verificar se há dirty records em qualquer adapter
      // Query direta no Drift sem fazer push real
      final vehiclesPending = await _vehicleAdapter.db
          .customSelect(
            'SELECT COUNT(*) as count FROM vehicles WHERE user_id = ? AND is_dirty = 1 AND is_deleted = 0',
            variables: [Variable.withString(userId)],
            readsFrom: {_vehicleAdapter.table},
          )
          .getSingle()
          .then((row) => row.read<int>('count') > 0);

      final fuelPending = await _fuelAdapter.db
          .customSelect(
            'SELECT COUNT(*) as count FROM fuel_supplies WHERE user_id = ? AND is_dirty = 1 AND is_deleted = 0',
            variables: [Variable.withString(userId)],
            readsFrom: {_fuelAdapter.table},
          )
          .getSingle()
          .then((row) => row.read<int>('count') > 0);

      final maintenancePending = await _maintenanceAdapter.db
          .customSelect(
            'SELECT COUNT(*) as count FROM maintenances WHERE user_id = ? AND is_dirty = 1 AND is_deleted = 0',
            variables: [Variable.withString(userId)],
            readsFrom: {_maintenanceAdapter.table},
          )
          .getSingle()
          .then((row) => row.read<int>('count') > 0);

      final expensePending = await _expenseAdapter.db
          .customSelect(
            'SELECT COUNT(*) as count FROM expenses WHERE user_id = ? AND is_dirty = 1 AND is_deleted = 0',
            variables: [Variable.withString(userId)],
            readsFrom: {_expenseAdapter.table},
          )
          .getSingle()
          .then((row) => row.read<int>('count') > 0);

      final odometerPending = await _odometerAdapter.db
          .customSelect(
            'SELECT COUNT(*) as count FROM odometer_readings WHERE user_id = ? AND is_dirty = 1 AND is_deleted = 0',
            variables: [Variable.withString(userId)],
            readsFrom: {_odometerAdapter.table},
          )
          .getSingle()
          .then((row) => row.read<int>('count') > 0);

      final hasPending =
          vehiclesPending ||
          fuelPending ||
          maintenancePending ||
          expensePending ||
          odometerPending;

      if (hasPending) {
        developer.log('🔄 Pending sync detected', name: 'GasometerSync');
      }

      return hasPending;
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
        '   Adapters: Vehicle, FuelSupply, Maintenance, Expense',
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
      // Obter userId autenticado
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

      // ========== PUSH PHASE (Local → Firestore) ==========

      // 1. Push vehicles (dirty records)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pushing_vehicles',
          current: 0,
          total: 8,
          currentItem: 'Enviando veículos modificados...',
        ),
      );

      final vehiclePushResult = await _vehicleAdapter.pushDirtyRecords(userId);
      vehiclePushResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Vehicles push: ${failure.message}');
          developer.log(
            '❌ Vehicles push failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPushed;
          totalFailed += result.recordsFailed;
          errors.addAll(result.errors);
          developer.log(
            '✅ Vehicles push: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 2. Push fuel supplies (dirty records)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pushing_fuel',
          current: 1,
          total: 8,
          currentItem: 'Enviando abastecimentos modificados...',
        ),
      );

      final fuelPushResult = await _fuelAdapter.pushDirtyRecords(userId);
      fuelPushResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Fuel push: ${failure.message}');
          developer.log(
            '❌ Fuel push failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPushed;
          totalFailed += result.recordsFailed;
          errors.addAll(result.errors);
          developer.log(
            '✅ Fuel push: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 3. Push maintenances (dirty records)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pushing_maintenances',
          current: 2,
          total: 8,
          currentItem: 'Enviando manutenções modificadas...',
        ),
      );

      final maintenancePushResult = await _maintenanceAdapter.pushDirtyRecords(
        userId,
      );
      maintenancePushResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Maintenance push: ${failure.message}');
          developer.log(
            '❌ Maintenance push failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPushed;
          totalFailed += result.recordsFailed;
          errors.addAll(result.errors);
          developer.log(
            '✅ Maintenance push: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 4. Push expenses (dirty records)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pushing_expenses',
          current: 3,
          total: 10,
          currentItem: 'Enviando despesas modificadas...',
        ),
      );

      final expensePushResult = await _expenseAdapter.pushDirtyRecords(userId);
      expensePushResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Expense push: ${failure.message}');
          developer.log(
            '❌ Expense push failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPushed;
          totalFailed += result.recordsFailed;
          errors.addAll(result.errors);
          developer.log(
            '✅ Expense push: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 5. Push odometer readings (dirty records)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pushing_odometer',
          current: 4,
          total: 10,
          currentItem: 'Enviando leituras de odômetro modificadas...',
        ),
      );

      final odometerPushResult = await _odometerAdapter.pushDirtyRecords(
        userId,
      );
      odometerPushResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Odometer push: ${failure.message}');
          developer.log(
            '❌ Odometer push failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPushed;
          totalFailed += result.recordsFailed;
          errors.addAll(result.errors);
          developer.log(
            '✅ Odometer push: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // ========== PULL PHASE (Firestore → Local) ==========

      // 6. Pull vehicles (remote changes)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pulling_vehicles',
          current: 5,
          total: 10,
          currentItem: 'Buscando veículos atualizados...',
        ),
      );

      final vehiclePullResult = await _vehicleAdapter.pullRemoteChanges(userId);
      vehiclePullResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Vehicles pull: ${failure.message}');
          developer.log(
            '❌ Vehicles pull failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPulled;
          if (result.conflictsResolved > 0) {
            developer.log(
              '⚠️ ${result.conflictsResolved} vehicle conflicts resolved',
              name: 'GasometerSync',
            );
          }
          developer.log(
            '✅ Vehicles pull: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 7. Pull fuel supplies (remote changes)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pulling_fuel',
          current: 6,
          total: 10,
          currentItem: 'Buscando abastecimentos atualizados...',
        ),
      );

      final fuelPullResult = await _fuelAdapter.pullRemoteChanges(userId);
      fuelPullResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Fuel pull: ${failure.message}');
          developer.log(
            '❌ Fuel pull failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPulled;
          if (result.conflictsResolved > 0) {
            developer.log(
              '⚠️ ${result.conflictsResolved} fuel conflicts resolved',
              name: 'GasometerSync',
            );
          }
          developer.log(
            '✅ Fuel pull: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 8. Pull maintenances (remote changes)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pulling_maintenances',
          current: 7,
          total: 10,
          currentItem: 'Buscando manutenções atualizadas...',
        ),
      );

      final maintenancePullResult = await _maintenanceAdapter.pullRemoteChanges(
        userId,
      );
      maintenancePullResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Maintenance pull: ${failure.message}');
          developer.log(
            '❌ Maintenance pull failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPulled;
          if (result.conflictsResolved > 0) {
            developer.log(
              '⚠️ ${result.conflictsResolved} maintenance conflicts resolved',
              name: 'GasometerSync',
            );
          }
          developer.log(
            '✅ Maintenance pull: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 9. Pull expenses (remote changes)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pulling_expenses',
          current: 8,
          total: 10,
          currentItem: 'Buscando despesas atualizadas...',
        ),
      );

      final expensePullResult = await _expenseAdapter.pullRemoteChanges(userId);
      expensePullResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Expense pull: ${failure.message}');
          developer.log(
            '❌ Expense pull failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPulled;
          if (result.conflictsResolved > 0) {
            developer.log(
              '⚠️ ${result.conflictsResolved} expense conflicts resolved',
              name: 'GasometerSync',
            );
          }
          developer.log(
            '✅ Expense pull: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // 10. Pull odometer readings (remote changes)
      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'pulling_odometer',
          current: 9,
          total: 10,
          currentItem: 'Buscando leituras de odômetro atualizadas...',
        ),
      );

      final odometerPullResult = await _odometerAdapter.pullRemoteChanges(
        userId,
      );
      odometerPullResult.fold(
        (failure) {
          totalFailed++;
          errors.add('Odometer pull: ${failure.message}');
          developer.log(
            '❌ Odometer pull failed: ${failure.message}',
            name: 'GasometerSync',
          );
        },
        (result) {
          totalSynced += result.recordsPulled;
          if (result.conflictsResolved > 0) {
            developer.log(
              '⚠️ ${result.conflictsResolved} odometer conflicts resolved',
              name: 'GasometerSync',
            );
          }
          developer.log(
            '✅ Odometer pull: ${result.summary}',
            name: 'GasometerSync',
          );
        },
      );

      // ========== FINALIZAÇÃO ==========

      _progressController.add(
        ServiceProgress(
          serviceId: serviceId,
          operation: 'completed',
          current: 10,
          total: 10,
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

  /// Método legado para compatibilidade - será removido em versões futuras
  void startConnectivityMonitoring(Stream<dynamic> connectivityStream) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = connectivityStream.listen((event) {
      // Implementar lógica de monitoramento de conectividade se necessário
    });
  }
}
