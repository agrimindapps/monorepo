import 'package:core/core.dart';

import '../../core/services/analytics/gasometer_analytics_service.dart';
import '../../core/services/connectivity/connectivity_state_manager.dart';
import '../../core/services/platform/platform_service.dart';
import '../../core/services/storage/firebase_storage_service.dart' as local_storage;
import '../../core/sync/adapters/sync_adapter_registry.dart';
import '../../database/providers/database_providers.dart' as db_providers;
import '../../features/expenses/data/datasources/expenses_local_datasource.dart';
import '../../features/expenses/data/sync/expense_drift_sync_adapter.dart';
import '../../features/fuel/data/datasources/fuel_supply_local_datasource.dart';
import '../../features/fuel/data/repositories/fuel_repository_drift_impl.dart';
import '../../features/fuel/data/sync/fuel_supply_drift_sync_adapter.dart';
import '../../features/fuel/domain/repositories/fuel_repository.dart';
import '../../features/fuel/domain/usecases/add_fuel_record.dart';
import '../../features/fuel/domain/usecases/delete_fuel_record.dart';
import '../../features/fuel/domain/usecases/get_all_fuel_records.dart';
import '../../features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../features/fuel/domain/usecases/update_fuel_record.dart';
import '../../features/image/domain/services/image_sync_service.dart';
import '../../features/maintenance/data/datasources/maintenance_local_datasource.dart';
import '../../features/maintenance/data/sync/maintenance_drift_sync_adapter.dart';
import '../../features/odometer/data/datasources/odometer_reading_local_datasource.dart';
import '../../features/odometer/data/sync/odometer_drift_sync_adapter.dart';
import '../../features/profile/domain/services/profile_image_service.dart';
import '../../features/sync/domain/services/auto_sync_service.dart';
import '../../features/sync/domain/services/gasometer_sync_orchestrator.dart';
import '../../features/sync/domain/services/gasometer_sync_service.dart';
import '../../features/sync/domain/services/sync_checkpoint_store.dart';
import '../../features/sync/domain/services/sync_pull_service.dart';
import '../../features/sync/domain/services/sync_push_service.dart';
import '../../features/sync/domain/services/sync_write_trigger.dart';
import '../../features/vehicles/data/datasources/vehicle_local_datasource.dart';
import '../../features/vehicles/data/repositories/vehicle_repository_drift_impl.dart';
import '../../features/vehicles/data/sync/vehicle_drift_sync_adapter.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../features/vehicles/domain/usecases/add_vehicle.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle.dart';
import '../../features/vehicles/domain/usecases/get_all_vehicles.dart';
import '../../features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../features/vehicles/domain/usecases/search_vehicles.dart';
import '../../features/vehicles/domain/usecases/update_vehicle.dart';

// Core Services
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firebaseAnalyticsServiceProvider = Provider<FirebaseAnalyticsService>((ref) {
  return FirebaseAnalyticsService(analytics: FirebaseAnalytics.instance);
});

final firebaseCrashlyticsServiceProvider = Provider<FirebaseCrashlyticsService>((ref) {
  return FirebaseCrashlyticsService(crashlytics: FirebaseCrashlytics.instance);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

final platformServiceProvider = Provider<PlatformService>((ref) {
  return const PlatformService();
});

final enhancedAnalyticsServiceProvider = Provider<EnhancedAnalyticsService>((ref) {
  return EnhancedAnalyticsService(
    analytics: ref.watch(firebaseAnalyticsServiceProvider),
    crashlytics: ref.watch(firebaseCrashlyticsServiceProvider),
  );
});

final gasometerAnalyticsServiceProvider = Provider<GasometerAnalyticsService>((ref) {
  return GasometerAnalyticsService(ref.watch(enhancedAnalyticsServiceProvider));
});

final gasometerProfileImageServiceProvider = Provider<GasometerProfileImageService>((ref) {
  return GasometerProfileImageService(ref.watch(gasometerAnalyticsServiceProvider));
});

final imageSyncServiceProvider = Provider<ImageSyncService>((ref) {
  final storageService = local_storage.FirebaseStorageService();
  final connectivityService = ref.watch(connectivityServiceProvider);
  return ImageSyncService(storageService, connectivityService);
});

final gasometerSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

final appRatingRepositoryProvider = Provider<IAppRatingRepository>((ref) {
   return AppRatingService();
});

// Sync
final syncWriteTriggerProvider = Provider<SyncWriteTrigger>((ref) {
  return SyncWriteTrigger();
});

// Datasources
final vehicleLocalDataSourceProvider = Provider<VehicleLocalDataSource>((ref) {
  final driftRepo = ref.watch(db_providers.vehicleRepositoryProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return VehicleLocalDataSource(driftRepo, syncTrigger);
});

final fuelSupplyLocalDataSourceProvider = Provider<FuelSupplyLocalDataSource>((ref) {
  final driftRepo = ref.watch(db_providers.fuelSupplyRepositoryProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return FuelSupplyLocalDataSource(driftRepo, syncTrigger);
});

final odometerReadingLocalDataSourceProvider = Provider<OdometerReadingLocalDataSource>((ref) {
  final driftRepo = ref.watch(db_providers.odometerReadingRepositoryProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return OdometerReadingLocalDataSource(driftRepo, syncTrigger);
});

final maintenanceLocalDataSourceProvider = Provider<MaintenanceLocalDataSource>((ref) {
  final driftRepo = ref.watch(db_providers.maintenanceRepositoryProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return MaintenanceLocalDataSource(driftRepo, syncTrigger);
});

final expensesLocalDataSourceProvider = Provider<ExpensesLocalDataSource>((ref) {
  final driftRepo = ref.watch(db_providers.expenseRepositoryProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return ExpensesLocalDataSource(driftRepo, syncTrigger);
});

// Repositories
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final dataSource = ref.watch(vehicleLocalDataSourceProvider);
  return VehicleRepositoryDriftImpl(dataSource);
});

final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  final dataSource = ref.watch(fuelSupplyLocalDataSourceProvider);
  return FuelRepositoryDriftImpl(dataSource);
});

// Use Cases - Vehicles
final getAllVehiclesProvider = Provider<GetAllVehicles>((ref) {
  return GetAllVehicles(ref.watch(vehicleRepositoryProvider));
});

final addVehicleProvider = Provider<AddVehicle>((ref) {
  return AddVehicle(ref.watch(vehicleRepositoryProvider));
});

final updateVehicleProvider = Provider<UpdateVehicle>((ref) {
  return UpdateVehicle(ref.watch(vehicleRepositoryProvider));
});

final deleteVehicleProvider = Provider<DeleteVehicle>((ref) {
  return DeleteVehicle(ref.watch(vehicleRepositoryProvider));
});

final getVehicleByIdProvider = Provider<GetVehicleById>((ref) {
  return GetVehicleById(ref.watch(vehicleRepositoryProvider));
});

final searchVehiclesProvider = Provider<SearchVehicles>((ref) {
  return SearchVehicles(ref.watch(vehicleRepositoryProvider));
});

// Use Cases - Fuel
final getAllFuelRecordsProvider = Provider<GetAllFuelRecords>((ref) {
  return GetAllFuelRecords(ref.watch(fuelRepositoryProvider));
});

final getFuelRecordsByVehicleProvider = Provider<GetFuelRecordsByVehicle>((ref) {
  return GetFuelRecordsByVehicle(ref.watch(fuelRepositoryProvider));
});

final addFuelRecordProvider = Provider<AddFuelRecord>((ref) {
  return AddFuelRecord(ref.watch(fuelRepositoryProvider));
});

final updateFuelRecordProvider = Provider<UpdateFuelRecord>((ref) {
  return UpdateFuelRecord(ref.watch(fuelRepositoryProvider));
});

final deleteFuelRecordProvider = Provider<DeleteFuelRecord>((ref) {
  return DeleteFuelRecord(ref.watch(fuelRepositoryProvider));
});

// Infrastructure
final crashlyticsRepositoryProvider = Provider<ICrashlyticsRepository>((ref) {
  return FirebaseCrashlyticsService(crashlytics: FirebaseCrashlytics.instance);
});

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return FirebaseAnalyticsService(analytics: FirebaseAnalytics.instance);
});

final performanceRepositoryProvider = Provider<IPerformanceRepository>((ref) {
  return PerformanceService();
});

final connectivityStateManagerProvider = Provider<ConnectivityStateManager>((ref) {
  return ConnectivityStateManager();
});

final autoSyncServiceProvider = Provider<AutoSyncService>((ref) {
  return AutoSyncService(connectivityService: ref.watch(connectivityServiceProvider));
});

// Sync Adapters & Services
final syncCheckpointStoreProvider = Provider<SyncCheckpointStore>((ref) {
  return SyncCheckpointStore();
});

final vehicleDriftSyncAdapterProvider = Provider<VehicleDriftSyncAdapter>((ref) {
  final db = ref.watch(db_providers.gasometerDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return VehicleDriftSyncAdapter(db, FirebaseFirestore.instance, connectivity);
});

final fuelSupplyDriftSyncAdapterProvider = Provider<FuelSupplyDriftSyncAdapter>((ref) {
  final db = ref.watch(db_providers.gasometerDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return FuelSupplyDriftSyncAdapter(db, FirebaseFirestore.instance, connectivity);
});

final maintenanceDriftSyncAdapterProvider = Provider<MaintenanceDriftSyncAdapter>((ref) {
  final db = ref.watch(db_providers.gasometerDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return MaintenanceDriftSyncAdapter(db, FirebaseFirestore.instance, connectivity);
});

final expenseDriftSyncAdapterProvider = Provider<ExpenseDriftSyncAdapter>((ref) {
  final db = ref.watch(db_providers.gasometerDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return ExpenseDriftSyncAdapter(db, FirebaseFirestore.instance, connectivity);
});

final odometerDriftSyncAdapterProvider = Provider<OdometerDriftSyncAdapter>((ref) {
  final db = ref.watch(db_providers.gasometerDatabaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return OdometerDriftSyncAdapter(db, FirebaseFirestore.instance, connectivity);
});

final syncAdapterRegistryProvider = Provider<SyncAdapterRegistry>((ref) {
  return SyncAdapterRegistry(
    adapters: [
      ref.watch(vehicleDriftSyncAdapterProvider) as IDriftSyncAdapter<dynamic, dynamic>,
      ref.watch(fuelSupplyDriftSyncAdapterProvider) as IDriftSyncAdapter<dynamic, dynamic>,
      ref.watch(maintenanceDriftSyncAdapterProvider) as IDriftSyncAdapter<dynamic, dynamic>,
      ref.watch(expenseDriftSyncAdapterProvider) as IDriftSyncAdapter<dynamic, dynamic>,
      ref.watch(odometerDriftSyncAdapterProvider) as IDriftSyncAdapter<dynamic, dynamic>,
    ],
  );
});

final syncPushServiceProvider = Provider<SyncPushService>((ref) {
  return SyncPushService(ref.watch(syncAdapterRegistryProvider));
});

final syncPullServiceProvider = Provider<SyncPullService>((ref) {
  return SyncPullService(
    ref.watch(syncAdapterRegistryProvider),
    ref.watch(syncCheckpointStoreProvider),
  );
});

final gasometerSyncOrchestratorProvider = Provider<GasometerSyncOrchestrator>((ref) {
  return GasometerSyncOrchestrator(
    pushService: ref.watch(syncPushServiceProvider),
    pullService: ref.watch(syncPullServiceProvider),
  );
});

final gasometerSyncServiceProvider = Provider<GasometerSyncService>((ref) {
  return GasometerSyncService(
    pushService: ref.watch(syncPushServiceProvider),
    pullService: ref.watch(syncPullServiceProvider),
  );
});
