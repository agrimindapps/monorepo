import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class GetVehicleById implements UseCase<VehicleEntity, GetVehicleByIdParams> {
  final VehicleRepository repository;

  GetVehicleById(this.repository);

  @override
  Future<Either<Failure, VehicleEntity>> call(GetVehicleByIdParams params) async {
    return await repository.getVehicleById(params.vehicleId);
  }
}

class GetVehicleByIdParams extends UseCaseParams {
  final String vehicleId;

  const GetVehicleByIdParams({required this.vehicleId});

  @override
  List<Object> get props => [vehicleId];
}