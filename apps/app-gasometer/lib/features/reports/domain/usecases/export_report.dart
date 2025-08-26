import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

@lazySingleton
class ExportReportToCSV implements UseCase<String, ExportReportToCSVParams> {
  final ReportsRepository repository;

  ExportReportToCSV(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportReportToCSVParams params) async {
    return await repository.exportReportToCSV(params.report);
  }
}

class ExportReportToCSVParams extends UseCaseParams {
  final ReportSummaryEntity report;

  const ExportReportToCSVParams({required this.report});

  @override
  List<Object> get props => [report];
}

