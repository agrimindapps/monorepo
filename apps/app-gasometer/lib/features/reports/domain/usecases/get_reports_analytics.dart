import 'package:core/core.dart';
import '../repositories/reports_repository.dart';

@injectable
class GetFuelEfficiencyTrends implements UseCase<Map<String, dynamic>, GetFuelEfficiencyTrendsParams> {

  GetFuelEfficiencyTrends(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetFuelEfficiencyTrendsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.months <= 0 || params.months > 24) {
      return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
    }

    return repository.getFuelEfficiencyTrends(params.vehicleId, params.months);
  }
}

class GetFuelEfficiencyTrendsParams with EquatableMixin {

  const GetFuelEfficiencyTrendsParams({
    required this.vehicleId,
    required this.months,
  });
  final String vehicleId;
  final int months;

  @override
  List<Object> get props => [vehicleId, months];
}

@injectable
class GetCostAnalysis implements UseCase<Map<String, dynamic>, GetCostAnalysisParams> {

  GetCostAnalysis(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetCostAnalysisParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure('Data inicial não pode ser posterior à data final'));
    }

    return repository.getCostAnalysis(params.vehicleId, params.startDate, params.endDate);
  }
}

class GetCostAnalysisParams with EquatableMixin {

  const GetCostAnalysisParams({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [vehicleId, startDate, endDate];
}

@injectable
class GetUsagePatterns implements UseCase<Map<String, dynamic>, GetUsagePatternsParams> {

  GetUsagePatterns(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetUsagePatternsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.months <= 0 || params.months > 24) {
      return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
    }

    return repository.getUsagePatterns(params.vehicleId, params.months);
  }
}

class GetUsagePatternsParams with EquatableMixin {

  const GetUsagePatternsParams({
    required this.vehicleId,
    required this.months,
  });
  final String vehicleId;
  final int months;

  @override
  List<Object> get props => [vehicleId, months];
}