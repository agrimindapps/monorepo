import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

@lazySingleton
class GenerateYearlyReport implements UseCase<ReportSummaryEntity, GenerateYearlyReportParams> {
  final ReportsRepository repository;

  GenerateYearlyReport(this.repository);

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(GenerateYearlyReportParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.year < 2000 || params.year > DateTime.now().year + 1) {
      return const Left(ValidationFailure('Ano inválido'));
    }

    return await repository.generateYearlyReport(params.vehicleId, params.year);
  }
}

class GenerateYearlyReportParams extends UseCaseParams {
  final String vehicleId;
  final int year;

  const GenerateYearlyReportParams({
    required this.vehicleId,
    required this.year,
  });

  @override
  List<Object> get props => [vehicleId, year];
}