import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceAnalyticsParams extends Equatable {
  final String vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetMaintenanceAnalyticsParams({
    required this.vehicleId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [vehicleId, startDate, endDate];
}

class MaintenanceAnalytics {
  final double totalCost;
  final double averageCost;
  final Map<String, int> countByType;

  const MaintenanceAnalytics({
    required this.totalCost,
    required this.averageCost,
    required this.countByType,
  });
}

@injectable
class GetMaintenanceAnalytics implements UseCase<MaintenanceAnalytics, GetMaintenanceAnalyticsParams> {
  final MaintenanceRepository repository;

  GetMaintenanceAnalytics(this.repository);

  @override
  Future<Either<Failure, MaintenanceAnalytics>> call(GetMaintenanceAnalyticsParams params) async {
    try {
      final totalCostResult = await repository.getTotalMaintenanceCost(
        params.vehicleId,
        startDate: params.startDate,
        endDate: params.endDate,
      );

      final averageCostResult = await repository.getAverageMaintenanceCost(params.vehicleId);
      
      final countByTypeResult = await repository.getMaintenanceCountByType(params.vehicleId);

      // Combine all results
      return totalCostResult.fold(
        (failure) => Left(failure),
        (totalCost) => averageCostResult.fold(
          (failure) => Left(failure),
          (averageCost) => countByTypeResult.fold(
            (failure) => Left(failure),
            (countByType) => Right(MaintenanceAnalytics(
              totalCost: totalCost,
              averageCost: averageCost,
              countByType: countByType,
            )),
          ),
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}