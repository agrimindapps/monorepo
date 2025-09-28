import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@lazySingleton
class GetFuelRecordsByVehicle implements UseCase<List<FuelRecordEntity>, GetFuelRecordsByVehicleParams> {

  GetFuelRecordsByVehicle(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call(GetFuelRecordsByVehicleParams params) async {
    return await repository.getFuelRecordsByVehicle(params.vehicleId);
  }
}

class GetFuelRecordsByVehicleParams extends UseCaseParams {

  const GetFuelRecordsByVehicleParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}