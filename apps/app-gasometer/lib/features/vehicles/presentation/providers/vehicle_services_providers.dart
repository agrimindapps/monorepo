import 'package:core/core.dart';

import '../../../../core/error/error_mapper.dart';
import '../../domain/services/vehicle_filter_service.dart';
import '../../domain/usecases/add_vehicle.dart';
import '../../domain/usecases/delete_vehicle.dart';
import '../../domain/usecases/get_all_vehicles.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/search_vehicles.dart';
import '../../domain/usecases/update_vehicle.dart';

part 'vehicle_services_providers.g.dart';

/// Provider para VehicleFilterService (Singleton)
@Riverpod(keepAlive: true)
VehicleFilterService vehicleFilterService(Ref ref) {
  return VehicleFilterServiceImpl();
}

/// Provider para ErrorMapper (Singleton) - Compartilhado por todo o app
@Riverpod(keepAlive: true)
ErrorMapper errorMapper(Ref ref) {
  return ErrorMapperImpl();
}

// --- Bridge Providers for Use Cases ---

@riverpod
AddVehicle addVehicle(Ref ref) {
  return GetIt.instance<AddVehicle>();
}

@riverpod
UpdateVehicle updateVehicle(Ref ref) {
  return GetIt.instance<UpdateVehicle>();
}

@riverpod
DeleteVehicle deleteVehicle(Ref ref) {
  return GetIt.instance<DeleteVehicle>();
}

@riverpod
GetVehicleById getVehicleById(Ref ref) {
  return GetIt.instance<GetVehicleById>();
}

@riverpod
SearchVehicles searchVehicles(Ref ref) {
  return GetIt.instance<SearchVehicles>();
}

@riverpod
GetAllVehicles getAllVehicles(Ref ref) {
  return GetIt.instance<GetAllVehicles>();
}
