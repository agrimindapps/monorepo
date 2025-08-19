import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class GetUpcomingMaintenanceRecordsParams extends Equatable {
  final String vehicleId;
  final int days;

  const GetUpcomingMaintenanceRecordsParams({
    required this.vehicleId,
    this.days = 30,
  });

  @override
  List<Object> get props => [vehicleId, days];
}

@injectable
class GetUpcomingMaintenanceRecords implements UseCase<List<MaintenanceEntity>, GetUpcomingMaintenanceRecordsParams> {
  final MaintenanceRepository repository;

  GetUpcomingMaintenanceRecords(this.repository);

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(GetUpcomingMaintenanceRecordsParams params) async {
    return await repository.getUpcomingMaintenanceRecords(
      params.vehicleId, 
      days: params.days,
    );
  }
}