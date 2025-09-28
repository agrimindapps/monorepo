import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

@lazySingleton
class GenerateCustomReport implements UseCase<ReportSummaryEntity, GenerateCustomReportParams> {

  GenerateCustomReport(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(GenerateCustomReportParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure('Data inicial não pode ser posterior à data final'));
    }

    if (params.endDate.isAfter(DateTime.now())) {
      return const Left(ValidationFailure('Data final não pode ser no futuro'));
    }

    return await repository.generateCustomReport(params.vehicleId, params.startDate, params.endDate);
  }
}

class GenerateCustomReportParams extends UseCaseParams {

  const GenerateCustomReportParams({
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