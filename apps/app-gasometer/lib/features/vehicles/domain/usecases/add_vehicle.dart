import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class AddVehicle implements UseCase<VehicleEntity, AddVehicleParams> {
  final VehicleRepository repository;

  AddVehicle(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(AddVehicleParams params) async {
    return await repository.addVehicle(params.vehicle);
  }
}

class AddVehicleParams extends UseCaseParams {
  final VehicleEntity vehicle;

  const AddVehicleParams({required this.vehicle});

  @override
  List<Object> get props => [vehicle];
}