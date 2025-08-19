import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

@lazySingleton
class GenerateMonthlyReport implements UseCase<ReportSummaryEntity, GenerateMonthlyReportParams> {
  final ReportsRepository repository;

  GenerateMonthlyReport(this.repository);

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(GenerateMonthlyReportParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return await repository.generateMonthlyReport(params.vehicleId, params.month);
  }
}

class GenerateMonthlyReportParams extends UseCaseParams {
  final String vehicleId;
  final DateTime month;

  const GenerateMonthlyReportParams({
    required this.vehicleId,
    required this.month,
  });

  @override
  List<Object> get props => [vehicleId, month];
}