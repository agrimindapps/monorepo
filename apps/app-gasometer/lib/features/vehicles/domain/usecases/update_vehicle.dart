import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class UpdateVehicle implements UseCase<VehicleEntity, UpdateVehicleParams> {

  UpdateVehicle(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, VehicleEntity>> call(UpdateVehicleParams params) async {
    return await repository.updateVehicle(params.vehicle);
  }
}

class UpdateVehicleParams extends UseCaseParams {

  const UpdateVehicleParams({required this.vehicle});
  final VehicleEntity vehicle;

  @override
  List<Object> get props => [vehicle];
}