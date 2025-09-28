import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_comparison_entity.dart';
import '../repositories/reports_repository.dart';

@lazySingleton
class CompareMonthlyReports implements UseCase<ReportComparisonEntity, CompareMonthlyReportsParams> {

  CompareMonthlyReports(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, ReportComparisonEntity>> call(CompareMonthlyReportsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return await repository.compareMonthlyReports(
      params.vehicleId, 
      params.currentMonth, 
      params.previousMonth,
    );
  }
}

class CompareMonthlyReportsParams extends UseCaseParams {

  const CompareMonthlyReportsParams({
    required this.vehicleId,
    required this.currentMonth,
    required this.previousMonth,
  });
  final String vehicleId;
  final DateTime currentMonth;
  final DateTime previousMonth;

  @override
  List<Object> get props => [vehicleId, currentMonth, previousMonth];
}

@lazySingleton
class CompareYearlyReports implements UseCase<ReportComparisonEntity, CompareYearlyReportsParams> {

  CompareYearlyReports(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, ReportComparisonEntity>> call(CompareYearlyReportsParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.currentYear < 2000 || params.previousYear < 2000) {
      return const Left(ValidationFailure('Anos inválidos'));
    }

    return await repository.compareYearlyReports(
      params.vehicleId, 
      params.currentYear, 
      params.previousYear,
    );
  }
}

class CompareYearlyReportsParams extends UseCaseParams {

  const CompareYearlyReportsParams({
    required this.vehicleId,
    required this.currentYear,
    required this.previousYear,
  });
  final String vehicleId;
  final int currentYear;
  final int previousYear;

  @override
  List<Object> get props => [vehicleId, currentYear, previousYear];
}