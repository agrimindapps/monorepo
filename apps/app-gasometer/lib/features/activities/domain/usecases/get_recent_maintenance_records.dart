import 'package:core/core.dart';

import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../maintenance/domain/repositories/maintenance_repository.dart';
import 'get_recent_params.dart';

/// Use case for fetching recent maintenance records for a specific vehicle
class GetRecentMaintenanceRecords
    implements UseCase<List<MaintenanceEntity>, GetRecentParams> {
  const GetRecentMaintenanceRecords(this.repository);

  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(
    GetRecentParams params,
  ) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('Vehicle ID is required'));
    }

    return repository.getRecentMaintenanceRecords(
      params.vehicleId,
      limit: params.limit,
    );
  }
}
