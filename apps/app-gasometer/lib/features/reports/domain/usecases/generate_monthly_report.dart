import 'package:core/core.dart';
import '../entities/report_summary_entity.dart';
import '../repositories/reports_repository.dart';

@injectable
class GenerateMonthlyReport implements UseCase<ReportSummaryEntity, GenerateMonthlyReportParams> {

  GenerateMonthlyReport(this.repository);
  final ReportsRepository repository;

  @override
  Future<Either<Failure, ReportSummaryEntity>> call(GenerateMonthlyReportParams params) async {
    if (params.vehicleId.isEmpty) {
      return const Left(ValidationFailure('ID do veículo é obrigatório'));
    }

    return repository.generateMonthlyReport(params.vehicleId, params.month);
  }
}

class GenerateMonthlyReportParams with EquatableMixin {

  const GenerateMonthlyReportParams({
    required this.vehicleId,
    required this.month,
  });
  final String vehicleId;
  final DateTime month;

  @override
  List<Object> get props => [vehicleId, month];
}