import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class DeleteVehicle implements UseCase<Unit, DeleteVehicleParams> {

  DeleteVehicle(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteVehicleParams params) async {
    return await repository.deleteVehicle(params.vehicleId);
  }
}

class DeleteVehicleParams extends UseCaseParams {

  const DeleteVehicleParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}