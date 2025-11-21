import 'package:core/core.dart';
import '../repositories/vehicle_repository.dart';


class DeleteVehicle implements UseCase<Unit, DeleteVehicleParams> {

  DeleteVehicle(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteVehicleParams params) async {
    return repository.deleteVehicle(params.vehicleId);
  }
}

class DeleteVehicleParams with EquatableMixin {

  const DeleteVehicleParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}
