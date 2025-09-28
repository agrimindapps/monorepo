import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class GetVehicleById implements UseCase<VehicleEntity, GetVehicleByIdParams> {

  GetVehicleById(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, VehicleEntity>> call(GetVehicleByIdParams params) async {
    return await repository.getVehicleById(params.vehicleId);
  }
}

class GetVehicleByIdParams extends UseCaseParams {

  const GetVehicleByIdParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}