import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class DeleteVehicle implements UseCase<Unit, DeleteVehicleParams> {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteVehicleParams params) async {
    return await repository.deleteVehicle(params.vehicleId);
  }
}

class DeleteVehicleParams extends UseCaseParams {
  final String vehicleId;

  const DeleteVehicleParams({required this.vehicleId});

  @override
  List<Object> get props => [vehicleId];
}