/// Barrel file for Fuel Riverpod providers
///
/// Export all fuel-related providers for easy importing
library;

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  return GetIt.instance<FuelCrudService>();
}

@riverpod
FuelQueryService fuelQueryService(Ref ref) {
  return GetIt.instance<FuelQueryService>();
}

@riverpod
FuelSyncService fuelSyncService(Ref ref) {
  return GetIt.instance<FuelSyncService>();
}

@riverpod
FuelCalculationService fuelCalculationService(Ref ref) {
  return GetIt.instance<FuelCalculationService>();
}

@riverpod
FuelConnectivityService fuelConnectivityService(Ref ref) {
  return GetIt.instance<FuelConnectivityService>();
}

// --- Bridge Providers for Use Cases ---

@riverpod
GetAverageConsumption getAverageConsumption(Ref ref) {
  return GetIt.instance<GetAverageConsumption>();
}

@riverpod
GetTotalSpent getTotalSpent(Ref ref) {
  return GetIt.instance<GetTotalSpent>();
}

@riverpod
GetRecentFuelRecords getRecentFuelRecords(Ref ref) {
  return GetIt.instance<GetRecentFuelRecords>();
}
