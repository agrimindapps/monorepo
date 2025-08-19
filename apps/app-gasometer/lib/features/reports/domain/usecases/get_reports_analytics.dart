import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reports_repository.dart';

@lazySingleton
class GetFuelEfficiencyTrends implements UseCase<Map<String, dynamic>, GetFuelEfficiencyTrendsParams> {
  final ReportsRepository repository;

  GetFuelEfficiencyTrends(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetFuelEfficiencyTrendsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.months <= 0 || params.months > 24) {
      return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
    }

    return await repository.getFuelEfficiencyTrends(params.vehicleId, params.months);
  }
}

class GetFuelEfficiencyTrendsParams extends UseCaseParams {
  final String vehicleId;
  final int months;

  const GetFuelEfficiencyTrendsParams({
    required this.vehicleId,
    required this.months,
  });

  @override
  List<Object> get props => [vehicleId, months];
}

@lazySingleton
class GetCostAnalysis implements UseCase<Map<String, dynamic>, GetCostAnalysisParams> {
  final ReportsRepository repository;

  GetCostAnalysis(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetCostAnalysisParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure('Data inicial não pode ser posterior à data final'));
    }

    return await repository.getCostAnalysis(params.vehicleId, params.startDate, params.endDate);
  }
}

class GetCostAnalysisParams extends UseCaseParams {
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  const GetCostAnalysisParams({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [vehicleId, startDate, endDate];
}

@lazySingleton
class GetUsagePatterns implements UseCase<Map<String, dynamic>, GetUsagePatternsParams> {
  final ReportsRepository repository;

  GetUsagePatterns(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetUsagePatternsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.months <= 0 || params.months > 24) {
      return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
    }

    return await repository.getUsagePatterns(params.vehicleId, params.months);
  }
}

class GetUsagePatternsParams extends UseCaseParams {
  final String vehicleId;
  final int months;

  const GetUsagePatternsParams({
    required this.vehicleId,
    required this.months,
  });

  @override
  List<Object> get props => [vehicleId, months];
}