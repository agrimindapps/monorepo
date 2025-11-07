import 'package:core/core.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@injectable
class GetAllVehicles implements NoParamsUseCase<List<VehicleEntity>> {

  GetAllVehicles(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, List<VehicleEntity>>> call() async {
    return repository.getAllVehicles();
  }
}
