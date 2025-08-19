import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class GetAllVehicles implements NoParamsUseCase<List<VehicleEntity>> {
  final VehicleRepository repository;

  GetAllVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call() async {
    return await repository.getAllVehicles();
  }
}