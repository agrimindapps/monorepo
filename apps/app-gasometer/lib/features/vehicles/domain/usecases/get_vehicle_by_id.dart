import 'package:core/core.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';


class GetVehicleById implements UseCase<VehicleEntity, GetVehicleByIdParams> {

  GetVehicleById(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, VehicleEntity>> call(GetVehicleByIdParams params) async {
    return repository.getVehicleById(params.vehicleId);
  }
}

class GetVehicleByIdParams with EquatableMixin {

  const GetVehicleByIdParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}
