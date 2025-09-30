import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
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
    return repository.getUpcomingMaintenanceRecords(
      params.vehicleId, 
      days: params.days,
    );
  }
}