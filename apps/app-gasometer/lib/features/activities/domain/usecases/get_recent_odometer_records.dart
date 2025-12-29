import 'package:core/core.dart';

import '../../../odometer/domain/entities/odometer_entity.dart';
import '../../../odometer/domain/repositories/odometer_repository.dart';
import 'get_recent_params.dart';

/// Use case for fetching recent odometer records for a specific vehicle
class GetRecentOdometerRecords
    implements UseCase<List<OdometerEntity>, GetRecentParams> {
  const GetRecentOdometerRecords(this.repository);

  final OdometerRepository repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(
    GetRecentParams params,
  ) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('Vehicle ID is required'));
    }

    return repository.getRecentOdometerRecords(
      params.vehicleId,
      limit: params.limit,
    );
  }
}
