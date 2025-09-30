import 'package:core/core.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@injectable
class AddVehicle implements UseCase<VehicleEntity, AddVehicleParams> {

  AddVehicle(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, VehicleEntity>> call(AddVehicleParams params) {
    return repository.addVehicle(params.vehicle);
  }
}

class AddVehicleParams with EquatableMixin {
  const AddVehicleParams({required this.vehicle});

  final VehicleEntity vehicle;

  @override
  List<Object> get props => [vehicle];
}