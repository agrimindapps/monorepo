import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repositories.dart';
import 'database_providers.dart';

part 'sync_providers.g.dart';

/// Provider para buscar registros sujos (precisam sync) de todos os repositórios
final dirtyRecordsProvider = FutureProvider.autoDispose<DirtyRecordsData>((
  ref,
) async {
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);
  final fuelSupplyRepo = ref.watch(fuelSupplyRepositoryProvider);
  final maintenanceRepo = ref.watch(maintenanceRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final odometerRepo = ref.watch(odometerReadingRepositoryProvider);

  final dirtyVehicles = await vehicleRepo.findDirtyRecords();
  final dirtyFuelSupplies = await fuelSupplyRepo.findDirtyRecords();
  final dirtyMaintenances = await maintenanceRepo.findDirtyRecords();
  final dirtyExpenses = await expenseRepo.findDirtyRecords();
  final dirtyOdometerReadings = await odometerRepo.findDirtyRecords();

  return DirtyRecordsData(
    vehicles: dirtyVehicles,
    fuelSupplies: dirtyFuelSupplies,
    maintenances: dirtyMaintenances,
    expenses: dirtyExpenses,
    odometerReadings: dirtyOdometerReadings,
  );
});

/// Provider para contar total de registros sujos
final dirtyRecordsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final dirtyRecords = await ref.watch(dirtyRecordsProvider.future);
  return dirtyRecords.totalCount;
});

/// Estados possíveis da sincronização
enum SyncStatus { idle, syncing, success, error }

/// Estado da sincronização
class SyncState {

  const SyncState({
    required this.status,
    this.totalRecords = 0,
    this.syncedRecords = 0,
    this.errorMessage,
  });
  final SyncStatus status;
  final int totalRecords;
  final int syncedRecords;
  final String? errorMessage;

  SyncState copyWith({
    SyncStatus? status,
    int? totalRecords,
    int? syncedRecords,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      totalRecords: totalRecords ?? this.totalRecords,
      syncedRecords: syncedRecords ?? this.syncedRecords,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get progress {
    if (totalRecords == 0) return 0.0;
    return syncedRecords / totalRecords;
  }

  bool get isInProgress => status == SyncStatus.syncing;
}

/// Notifier para gerenciar estado de sincronização
@riverpod
class SyncStateNotifier extends _$SyncStateNotifier {
  @override
  SyncState build() => const SyncState(status: SyncStatus.idle);

  /// Inicia processo de sincronização
  Future<void> startSync() async {
    try {
      state = const SyncState(status: SyncStatus.syncing);

      // Busca registros sujos
      final dirtyRecords = await ref.read(dirtyRecordsProvider.future);
      final totalRecords = dirtyRecords.totalCount;

      state = state.copyWith(totalRecords: totalRecords);

      if (totalRecords == 0) {
        state = const SyncState(status: SyncStatus.success);
        return;
      }

      int syncedCount = 0;

      // TODO: Implementar chamadas à API para sincronizar cada tipo de registro
      // Por enquanto, apenas simula a sincronização marcando como sincronizado

      final vehicleRepo = ref.read(vehicleRepositoryProvider);
      final fuelSupplyRepo = ref.read(fuelSupplyRepositoryProvider);
      final maintenanceRepo = ref.read(maintenanceRepositoryProvider);
      final expenseRepo = ref.read(expenseRepositoryProvider);
      final odometerRepo = ref.read(odometerReadingRepositoryProvider);

      // Sincroniza veículos
      if (dirtyRecords.vehicles.isNotEmpty) {
        await vehicleRepo.markAsSynced(
          dirtyRecords.vehicles.map((v) => v.id).toList(),
        );
        syncedCount += dirtyRecords.vehicles.length;
        state = state.copyWith(syncedRecords: syncedCount);
      }

      // Sincroniza abastecimentos
      if (dirtyRecords.fuelSupplies.isNotEmpty) {
        await fuelSupplyRepo.markAsSynced(
          dirtyRecords.fuelSupplies.map((f) => f.id).toList(),
        );
        syncedCount += dirtyRecords.fuelSupplies.length;
        state = state.copyWith(syncedRecords: syncedCount);
      }

      // Sincroniza manutenções
      if (dirtyRecords.maintenances.isNotEmpty) {
        await maintenanceRepo.markAsSynced(
          dirtyRecords.maintenances.map((m) => m.id).toList(),
        );
        syncedCount += dirtyRecords.maintenances.length;
        state = state.copyWith(syncedRecords: syncedCount);
      }

      // Sincroniza despesas
      if (dirtyRecords.expenses.isNotEmpty) {
        await expenseRepo.markAsSynced(
          dirtyRecords.expenses.map((e) => e.id).toList(),
        );
        syncedCount += dirtyRecords.expenses.length;
        state = state.copyWith(syncedRecords: syncedCount);
      }

      // Sincroniza leituras de odômetro
      if (dirtyRecords.odometerReadings.isNotEmpty) {
        await odometerRepo.markAsSynced(
          dirtyRecords.odometerReadings.map((o) => o.id).toList(),
        );
        syncedCount += dirtyRecords.odometerReadings.length;
        state = state.copyWith(syncedRecords: syncedCount);
      }

      state = const SyncState(status: SyncStatus.success);
    } catch (e, stackTrace) {
      state = SyncState(status: SyncStatus.error, errorMessage: e.toString());
      // Log error
      print('Sync error: $e\n$stackTrace');
    }
  }

  /// Reseta o estado de sincronização
  void reset() {
    state = const SyncState(status: SyncStatus.idle);
  }
}

/// Classe para agrupar registros sujos
class DirtyRecordsData {

  const DirtyRecordsData({
    required this.vehicles,
    required this.fuelSupplies,
    required this.maintenances,
    required this.expenses,
    required this.odometerReadings,
  });
  final List<VehicleData> vehicles;
  final List<FuelSupplyData> fuelSupplies;
  final List<MaintenanceData> maintenances;
  final List<ExpenseData> expenses;
  final List<OdometerReadingData> odometerReadings;

  int get totalCount =>
      vehicles.length +
      fuelSupplies.length +
      maintenances.length +
      expenses.length +
      odometerReadings.length;

  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => totalCount > 0;
}
