import 'package:core/core.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';


class ExportReportToCSV implements UseCase<String, ExportReportToCSVParams> {

  ExportReportToCSV(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, String>> call(ExportReportToCSVParams params) async {
    return repository.exportReportToCSV(params.report);
  }
}


class ExportReportToPDF implements UseCase<String, ExportReportToPDFParams> {

  ExportReportToPDF(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, String>> call(ExportReportToPDFParams params) async {
    return repository.exportReportToPDF(params.report);
  }
}

class ExportReportToCSVParams with EquatableMixin {

  const ExportReportToCSVParams({required this.report});
  final ReportSummaryEntity report;

  @override
  List<Object> get props => [report];
}

class ExportReportToPDFParams with EquatableMixin {

  const ExportReportToPDFParams({required this.report});
  final ReportSummaryEntity report;

  @override
  List<Object> get props => [report];
}
