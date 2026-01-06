import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../domain/services/vehicle_filter_service.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_all_vehicles.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';

part 'vehicle_services_providers.g.dart';

/// Provider para VehicleFilterService (Singleton)
@riverpod
VehicleFilterService vehicleFilterService(Ref ref) {
  return VehicleFilterServiceImpl();
}

/// Provider para ErrorMapper (Singleton) - Compartilhado por todo o app
@riverpod
ErrorMapper errorMapper(Ref ref) {
  return ErrorMapperImpl();
}

// --- Bridge Providers for Use Cases ---

@riverpod
AddVehicle addVehicle(Ref ref) {
  return ref.watch(deps.addVehicleProvider);
}

@riverpod
UpdateVehicle updateVehicle(Ref ref) {
  return ref.watch(deps.updateVehicleProvider);
}

@riverpod
DeleteVehicle deleteVehicle(Ref ref) {
  return ref.watch(deps.deleteVehicleProvider);
}

@riverpod
GetVehicleById getVehicleById(Ref ref) {
  return ref.watch(deps.getVehicleByIdProvider);
}

@riverpod
SearchVehicles searchVehicles(Ref ref) {
  return ref.watch(deps.searchVehiclesProvider);
}

@riverpod
GetAllVehicles getAllVehicles(Ref ref) {
  return ref.watch(deps.getAllVehiclesProvider);
}
