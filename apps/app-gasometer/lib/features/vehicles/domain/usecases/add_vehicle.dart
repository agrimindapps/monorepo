import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class AddVehicle implements UseCase<VehicleEntity, AddVehicleParams> {

  AddVehicle(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, VehicleEntity>> call(AddVehicleParams params) async {
    return await repository.addVehicle(params.vehicle);
  }
}

class AddVehicleParams extends UseCaseParams {

  const AddVehicleParams({required this.vehicle});
  final VehicleEntity vehicle;

  @override
  List<Object> get props => [vehicle];
}