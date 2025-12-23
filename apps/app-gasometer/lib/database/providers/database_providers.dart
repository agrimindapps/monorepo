import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/interfaces/i_expenses_repository.dart';
import '../../core/providers/dependency_providers.dart' as deps;
import '../../features/expenses/data/repositories/expenses_repository_drift_impl.dart';
import '../../features/maintenance/data/repositories/maintenance_repository_drift_impl.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart' as domain_maintenance;
import '../../features/odometer/data/repositories/odometer_repository_drift_impl.dart';
import '../../features/odometer/domain/repositories/odometer_repository.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_drift_impl.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart' as domain_vehicle;
import '../gasometer_database.dart';
import '../repositories/receipt_images_repository.dart';
import '../repositories/repositories.dart';
import '../repositories/vehicle_images_repository.dart';

/// Provider do banco de dados principal
///
/// **IMPORTANTE:** Este provider retorna a instância singleton do banco de dados.
///
/// **Funcionamento em todas as plataformas:**
/// - **Mobile/Desktop**: SQLite nativo via Drift
/// - **Web**: WASM + IndexedDB via Drift
///
/// Usa DriftDatabaseConfig que automaticamente escolhe o executor correto.
final gasometerDatabaseProvider = Provider<GasometerDatabase>((ref) {
  // Cria a instância de produção
  final db = GasometerDatabase.production();

  // Fecha o banco quando o provider for descartado (se não for mantido vivo)
  // Mas como queremos singleton, mantemos vivo.
  ref.keepAlive();
  
  ref.onDispose(() {
    db.close();
  });

  return db;
});

// ========== DATABASE AVAILABILITY PROVIDER ==========

/// Provider que indica se o banco Drift está disponível
///
/// Agora sempre retorna true pois Drift funciona em todas as plataformas
final isDatabaseAvailableProvider = Provider<bool>((ref) {
  return true; // Drift com WASM funciona na web
});

// ========== REPOSITORY PROVIDERS ==========

/// Provider do repositório de veículos
///
/// **Comportamento:**
/// - **Mobile**: Usa Drift database (local storage)
/// - **Web**: Usa null database + fallback para Firestore (veja repository)
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  // Repositories lidam com db = null em web, usando Firestore como backend
  return VehicleRepository(db);
});

/// Provider do repositório de abastecimentos
final fuelSupplyRepositoryProvider = Provider<FuelSupplyRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  return FuelSupplyRepository(db);
});

/// Provider do repositório de manutenções
final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  return MaintenanceRepository(db);
});

/// Provider do repositório de despesas
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  return ExpenseRepository(db);
});

/// Provider do repositório de leituras de odômetro
final odometerReadingRepositoryProvider = Provider<OdometerReadingRepository>((
  ref,
) {
  final db = ref.watch(gasometerDatabaseProvider);
  return OdometerReadingRepository(db);
});

/// Provider do repositório de veículos (interface do domain)
/// Usa VehicleRepositoryDriftImpl como implementação com Sync-on-Write
final vehicleDomainRepositoryProvider = Provider<domain_vehicle.VehicleRepository>((ref) {
  final dataSource = ref.watch(deps.vehicleLocalDataSourceProvider);
  final connectivityService = ref.watch(deps.connectivityServiceProvider);
  final syncAdapter = ref.watch(deps.vehicleDriftSyncAdapterProvider);
  return VehicleRepositoryDriftImpl(dataSource, connectivityService, syncAdapter);
});

/// Provider do repositório de odômetro (interface do domain)
/// Usa OdometerRepositoryDriftImpl como implementação com Sync-on-Write
final odometerRepositoryProvider = Provider<OdometerRepository>((ref) {
  final dataSource = ref.watch(deps.odometerReadingLocalDataSourceProvider);
  final connectivityService = ref.watch(deps.connectivityServiceProvider);
  final syncAdapter = ref.watch(deps.odometerDriftSyncAdapterProvider);
  final vehicleRepository = ref.watch(vehicleDomainRepositoryProvider);
  return OdometerRepositoryDriftImpl(dataSource, connectivityService, syncAdapter, vehicleRepository);
});

/// Provider do repositório de manutenção (interface do domain)
/// Usa MaintenanceRepositoryDriftImpl como implementação com Sync-on-Write
final maintenanceDomainRepositoryProvider = Provider<domain_maintenance.MaintenanceRepository>((ref) {
  final dataSource = ref.watch(deps.maintenanceLocalDataSourceProvider);
  final connectivityService = ref.watch(deps.connectivityServiceProvider);
  final syncAdapter = ref.watch(deps.maintenanceDriftSyncAdapterProvider);
  final vehicleRepository = ref.watch(vehicleDomainRepositoryProvider);
  return MaintenanceRepositoryDriftImpl(dataSource, connectivityService, syncAdapter, vehicleRepository);
});

/// Provider do repositório de despesas (interface do domain)
/// Usa ExpensesRepositoryDriftImpl como implementação com Sync-on-Write
final expensesDomainRepositoryProvider = Provider<IExpensesRepository>((ref) {
  final dataSource = ref.watch(deps.expensesLocalDataSourceProvider);
  final connectivityService = ref.watch(deps.connectivityServiceProvider);
  final syncAdapter = ref.watch(deps.expenseDriftSyncAdapterProvider);
  final vehicleRepository = ref.watch(vehicleDomainRepositoryProvider);
  return ExpensesRepositoryDriftImpl(dataSource, connectivityService, syncAdapter, vehicleRepository);
});

/// Provider do repositório de auditoria
final auditTrailRepositoryProvider = Provider<AuditTrailRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  return AuditTrailRepository(db);
});

/// Provider do repositório de imagens de veículos
final vehicleImagesDriftRepositoryProvider = Provider<VehicleImagesDriftRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  return VehicleImagesDriftRepository(db);
});

/// Provider do repositório de imagens de comprovantes
final receiptImagesDriftRepositoryProvider = Provider<ReceiptImagesDriftRepository>((ref) {
  final db = ref.watch(gasometerDatabaseProvider);
  return ReceiptImagesDriftRepository(db);
});

// ========== IMAGE STREAM PROVIDERS ==========

/// Stream de imagens de um veículo
final vehicleImagesStreamProvider = StreamProvider.autoDispose
    .family<List<VehicleImage>, int>((ref, vehicleId) {
      final repo = ref.watch(vehicleImagesDriftRepositoryProvider);
      return repo.watchImagesByVehicleId(vehicleId);
    });

/// Stream da imagem primária de um veículo
final vehiclePrimaryImageStreamProvider = StreamProvider.autoDispose
    .family<VehicleImage?, int>((ref, vehicleId) {
      final repo = ref.watch(vehicleImagesDriftRepositoryProvider);
      return repo.watchPrimaryImage(vehicleId);
    });

/// Stream de comprovantes de uma entidade (abastecimento, manutenção, despesa)
final receiptImagesStreamProvider = StreamProvider.autoDispose
    .family<List<ReceiptImage>, ({ReceiptEntityType type, int entityId})>((ref, params) {
      final repo = ref.watch(receiptImagesDriftRepositoryProvider);
      return repo.watchImagesByEntity(params.type, params.entityId);
    });

// ========== STREAM PROVIDERS ==========

/// Stream de veículos ativos do usuário
final userVehiclesStreamProvider = StreamProvider.autoDispose
    .family<List<VehicleData>, String>((ref, userId) {
      final repo = ref.watch(vehicleRepositoryProvider);
      return repo.watchByUserId(userId);
    });

/// Stream de veículos ativos (não vendidos)
final activeVehiclesStreamProvider = StreamProvider.autoDispose
    .family<List<VehicleData>, String>((ref, userId) {
      final repo = ref.watch(vehicleRepositoryProvider);
      return repo.watchActiveVehicles(userId);
    });

/// Stream de abastecimentos de um veículo
final vehicleFuelSuppliesStreamProvider = StreamProvider.autoDispose
    .family<List<FuelSupplyData>, int>((ref, vehicleId) {
      final repo = ref.watch(fuelSupplyRepositoryProvider);
      return repo.watchByVehicleId(vehicleId);
    });

/// Stream de manutenções de um veículo
final vehicleMaintenancesStreamProvider = StreamProvider.autoDispose
    .family<List<MaintenanceData>, int>((ref, vehicleId) {
      final repo = ref.watch(maintenanceRepositoryProvider);
      return repo.watchByVehicleId(vehicleId);
    });

/// Stream de manutenções pendentes de um veículo
final pendingMaintenancesStreamProvider = StreamProvider.autoDispose
    .family<List<MaintenanceData>, int>((ref, vehicleId) {
      final repo = ref.watch(maintenanceRepositoryProvider);
      return repo.watchPendingByVehicleId(vehicleId);
    });

/// Stream de despesas de um veículo
final vehicleExpensesStreamProvider = StreamProvider.autoDispose
    .family<List<ExpenseData>, int>((ref, vehicleId) {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.watchByVehicleId(vehicleId);
    });

/// Stream de leituras de odômetro de um veículo
final vehicleOdometerReadingsStreamProvider = StreamProvider.autoDispose
    .family<List<OdometerReadingData>, int>((ref, vehicleId) {
      final repo = ref.watch(odometerReadingRepositoryProvider);
      return repo.watchByVehicleId(vehicleId);
    });

/// Stream da última leitura de odômetro
final latestOdometerReadingStreamProvider = StreamProvider.autoDispose
    .family<OdometerReadingData?, int>((ref, vehicleId) {
      final repo = ref.watch(odometerReadingRepositoryProvider);
      return repo.watchLatestByVehicleId(vehicleId);
    });

// ========== FUTURE PROVIDERS ==========

/// Provider para contar veículos ativos do usuário
final activeVehiclesCountProvider = FutureProvider.autoDispose
    .family<int, String>((ref, userId) async {
      final repo = ref.watch(vehicleRepositoryProvider);
      return repo.countActiveVehicles(userId);
    });

/// Provider para buscar um veículo por ID
final vehicleByIdProvider = FutureProvider.autoDispose
    .family<VehicleData?, int>((ref, vehicleId) async {
      final repo = ref.watch(vehicleRepositoryProvider);
      return repo.findById(vehicleId);
    });

/// Provider para total de despesas de um veículo
final vehicleTotalExpensesProvider = FutureProvider.autoDispose
    .family<double, int>((ref, vehicleId) async {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.calculateTotalExpenses(vehicleId);
    });

/// Provider para total gasto em combustível
final vehicleTotalFuelSpentProvider = FutureProvider.autoDispose
    .family<double, int>((ref, vehicleId) async {
      final repo = ref.watch(fuelSupplyRepositoryProvider);
      return repo.calculateTotalSpent(vehicleId);
    });

/// Provider para total gasto em manutenções
final vehicleTotalMaintenanceCostProvider = FutureProvider.autoDispose
    .family<double, int>((ref, vehicleId) async {
      final repo = ref.watch(maintenanceRepositoryProvider);
      return repo.calculateTotalCost(vehicleId);
    });

/// Provider para contar manutenções pendentes
final pendingMaintenancesCountProvider = FutureProvider.autoDispose
    .family<int, int>((ref, vehicleId) async {
      final repo = ref.watch(maintenanceRepositoryProvider);
      return repo.countPendingByVehicleId(vehicleId);
    });

/// Provider para buscar marcas distintas de um usuário
final distinctVehicleBrandsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, userId) async {
      final repo = ref.watch(vehicleRepositoryProvider);
      return repo.findDistinctBrands(userId);
    });

/// Provider para buscar categorias de despesas distintas
final distinctExpenseCategoriesProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, vehicleId) async {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.findDistinctCategories(vehicleId);
    });

/// Provider para estatísticas de despesas por categoria
final expensesByCategoryProvider = FutureProvider.autoDispose
    .family<Map<String, double>, int>((ref, vehicleId) async {
      final repo = ref.watch(expenseRepositoryProvider);
      return repo.getExpensesByCategory(vehicleId);
    });
