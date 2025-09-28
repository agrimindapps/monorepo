import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class GetUpcomingMaintenanceRecordsParams extends Equatable {

  const GetUpcomingMaintenanceRecordsParams({
    required this.vehicleId,
    this.days = 30,
  });
  final String vehicleId;
  final int days;

  @override
  List<Object> get props => [vehicleId, days];
}

@injectable
class GetUpcomingMaintenanceRecords implements UseCase<List<MaintenanceEntity>, GetUpcomingMaintenanceRecordsParams> {

  GetUpcomingMaintenanceRecords(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(GetUpcomingMaintenanceRecordsParams params) async {
    return await repository.getUpcomingMaintenanceRecords(
      params.vehicleId, 
      days: params.days,
    );
  }
}