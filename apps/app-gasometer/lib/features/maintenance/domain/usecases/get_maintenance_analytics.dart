import 'package:core/core.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceAnalyticsParams extends Equatable {
  const GetMaintenanceAnalyticsParams({
    required this.vehicleId,
    this.startDate,
    this.endDate,
  });
  final String vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

class MaintenanceAnalytics {
  const MaintenanceAnalytics({
    required this.totalCost,
    required this.averageCost,
    required this.countByType,
  });
  final double totalCost;
  final double averageCost;
  final Map<String, int> countByType;
}

@injectable
class GetMaintenanceAnalytics
    implements UseCase<MaintenanceAnalytics, GetMaintenanceAnalyticsParams> {
  GetMaintenanceAnalytics(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, MaintenanceAnalytics>> call(
    GetMaintenanceAnalyticsParams params,
  ) async {
    try {
      final totalCostResult = await repository.getTotalMaintenanceCost(
        params.vehicleId,
        startDate: params.startDate,
        endDate: params.endDate,
      );

      final averageCostResult = await repository.getAverageMaintenanceCost(
        params.vehicleId,
      );

      final countByTypeResult = await repository.getMaintenanceCountByType(
        params.vehicleId,
      );

      // Combine all results
      return totalCostResult.fold(
        (failure) => Left(failure),
        (totalCost) => averageCostResult.fold(
          (failure) => Left(failure),
          (averageCost) => countByTypeResult.fold(
            (failure) => Left(failure),
            (countByType) => Right(
              MaintenanceAnalytics(
                totalCost: totalCost,
                averageCost: averageCost,
                countByType: countByType,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
