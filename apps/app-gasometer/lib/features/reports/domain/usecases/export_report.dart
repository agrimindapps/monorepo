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

@lazySingleton
class ExportReportToPDF implements UseCase<String, ExportReportToPDFParams> {
  final ReportsRepository repository;

  ExportReportToPDF(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportReportToPDFParams params) async {
    return await repository.exportReportToPDF(params.report);
  }
}

class ExportReportToCSVParams extends UseCaseParams {
  final ReportSummaryEntity report;

  const ExportReportToCSVParams({required this.report});

  @override
  List<Object> get props => [report];
}

class ExportReportToPDFParams extends UseCaseParams {
  final ReportSummaryEntity report;

  const ExportReportToPDFParams({required this.report});

  @override
  List<Object> get props => [report];
}

