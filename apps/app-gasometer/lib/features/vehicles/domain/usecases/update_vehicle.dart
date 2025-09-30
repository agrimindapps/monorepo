import 'package:core/core.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@injectable
class UpdateVehicle implements UseCase<VehicleEntity, UpdateVehicleParams> {

  UpdateVehicle(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, VehicleEntity>> call(UpdateVehicleParams params) async {
    return repository.updateVehicle(params.vehicle);
  }
}

class UpdateVehicleParams with EquatableMixin {

  const UpdateVehicleParams({required this.vehicle});
  final VehicleEntity vehicle;

  @override
  List<Object> get props => [vehicle];
}