import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';


class GetFuelRecordsByVehicle implements UseCase<List<FuelRecordEntity>, GetFuelRecordsByVehicleParams> {

  GetFuelRecordsByVehicle(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call(GetFuelRecordsByVehicleParams params) async {
    if (params.vehicleId.trim().isEmpty) {
      return Left(ValidationFailure('ID do veículo não pode ser vazio'));
    }
    return repository.getFuelRecordsByVehicle(params.vehicleId);
  }
}

class GetFuelRecordsByVehicleParams with EquatableMixin {

  const GetFuelRecordsByVehicleParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}
