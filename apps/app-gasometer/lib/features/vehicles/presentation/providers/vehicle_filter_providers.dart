import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/vehicle_entity.dart';
import 'vehicle_services_providers.dart';
import 'vehicles_notifier.dart';

part 'vehicle_filter_providers.g.dart';

/// Provider para veículos filtrados por tipo
@riverpod
AsyncValue<List<VehicleEntity>> vehiclesByType(
  Ref ref,
  VehicleType type,
) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final filterService = ref.watch(vehicleFilterServiceProvider);

  return vehiclesAsync.when(
    data: (vehicles) =>
        AsyncValue.data(filterService.filterByType(vehicles, type)),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Provider para veículos filtrados por tipo de combustível
@riverpod
AsyncValue<List<VehicleEntity>> vehiclesByFuelType(
  Ref ref,
  FuelType fuelType,
) {
  final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
  final filterService = ref.watch(vehicleFilterServiceProvider);

  return vehiclesAsync.when(
    data: (vehicles) =>
        AsyncValue.data(filterService.filterByFuelType(vehicles, fuelType)),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}
