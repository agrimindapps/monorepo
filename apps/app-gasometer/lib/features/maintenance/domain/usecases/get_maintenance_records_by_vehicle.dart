import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceRecordsByVehicleParams extends Equatable {

  const GetMaintenanceRecordsByVehicleParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}

@injectable
class GetMaintenanceRecordsByVehicle implements UseCase<List<MaintenanceEntity>, GetMaintenanceRecordsByVehicleParams> {

  GetMaintenanceRecordsByVehicle(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(GetMaintenanceRecordsByVehicleParams params) async {
    return await repository.getMaintenanceRecordsByVehicle(params.vehicleId);
  }
}