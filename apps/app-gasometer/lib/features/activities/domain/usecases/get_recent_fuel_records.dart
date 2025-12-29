import 'package:core/core.dart';

import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../fuel/domain/repositories/fuel_repository.dart';
import 'get_recent_params.dart';

/// Use case for fetching recent fuel records for a specific vehicle
class GetRecentFuelRecords
    implements UseCase<List<FuelRecordEntity>, GetRecentParams> {
  const GetRecentFuelRecords(this.repository);

  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call(
    GetRecentParams params,
  ) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('Vehicle ID is required'));
    }

    return repository.getRecentFuelRecords(
      params.vehicleId,
      limit: params.limit,
    );
  }
}
