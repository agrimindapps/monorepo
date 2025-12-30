/// Barrel file for Fuel Riverpod providers
///
/// Export all fuel-related providers for easy importing
library;

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../../domain/services/fuel_calculation_service.dart';
import '../../domain/services/fuel_connectivity_service.dart';
import '../../domain/services/fuel_crud_service.dart';
import '../../domain/services/fuel_query_service.dart';
import '../../domain/services/fuel_sync_service.dart';
import '../../domain/usecases/get_fuel_analytics.dart';

export 'fuel_form_notifier.dart';
export 'fuel_riverpod_notifier.dart';

part 'providers.g.dart';

// --- Bridge Providers for Services ---

@riverpod
FuelCrudService fuelCrudService(Ref ref) {
  return FuelCrudService(
    addFuelRecord: ref.watch(deps.addFuelRecordProvider),
    updateFuelRecord: ref.watch(deps.updateFuelRecordProvider),
    deleteFuelRecord: ref.watch(deps.deleteFuelRecordProvider),
  );
}

@riverpod
FuelQueryService fuelQueryService(Ref ref) {
  return FuelQueryService(
    getAllFuelRecords: ref.watch(deps.getAllFuelRecordsProvider),
    getFuelRecordsByVehicle: ref.watch(deps.getFuelRecordsByVehicleProvider),
  );
}

@riverpod
FuelSyncService fuelSyncService(Ref ref) {
  return FuelSyncService(
    localDataSource: ref.watch(deps.fuelSupplyLocalDataSourceProvider),
  );
}

@riverpod
FuelCalculationService fuelCalculationService(Ref ref) {
  return FuelCalculationService();
}

@riverpod
FuelConnectivityService fuelConnectivityService(Ref ref) {
  return FuelConnectivityService(ref.watch(deps.connectivityServiceProvider));
}

/// Bridge provider for GasometerAnalyticsService
@riverpod
GasometerAnalyticsService fuelAnalyticsService(Ref ref) {
  return ref.watch(deps.gasometerAnalyticsServiceProvider);
}

// --- Bridge Providers for Use Cases ---

@riverpod
GetAverageConsumption getAverageConsumption(Ref ref) {
  return GetAverageConsumption(ref.watch(deps.fuelRepositoryProvider));
}

@riverpod
GetTotalSpent getTotalSpent(Ref ref) {
  return GetTotalSpent(ref.watch(deps.fuelRepositoryProvider));
}

@riverpod
GetRecentFuelRecords getRecentFuelRecords(Ref ref) {
  return GetRecentFuelRecords(ref.watch(deps.fuelRepositoryProvider));
}
