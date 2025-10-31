import 'package:core/core.dart';

import '../../../../core/error/exceptions.dart' as local_exceptions;
import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/validators/report_validator.dart';
import '../datasources/reports_data_source.dart';

@LazySingleton(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {

  ReportsRepositoryImpl(this._dataSource, this._validator);
  final ReportsDataSource _dataSource;
  final ReportValidator _validator;

  Future<Either<Failure, T>> _executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String errorContext,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } on local_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on local_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$errorContext: ${e.toString()}'));
    }
  }

  Future<Either<Failure, ReportComparisonEntity>> _compareReports({
    required String vehicleId,
    required Future<Either<Failure, ReportSummaryEntity>> Function() getCurrentReport,
    required Future<Either<Failure, ReportSummaryEntity>> Function() getPreviousReport,
    required String comparisonType,
  }) async {
    final validationResult = _validator.validateVehicleId(vehicleId);
    if (validationResult.isLeft()) {
      return validationResult.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final results = await Future.wait([getCurrentReport(), getPreviousReport()]);
    final currentResult = results[0];
    final previousResult = results[1];

    return currentResult.fold(
      (failure) => Left(failure),
      (currentReport) => previousResult.fold(
        (failure) => Left(failure),
        (previousReport) => _executeWithErrorHandling(
          () => _dataSource.compareReports(vehicleId, currentReport, previousReport, comparisonType),
          'Erro ao comparar relatórios',
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, ReportSummaryEntity>> generateMonthlyReport(String vehicleId, DateTime month) async {
    final validationResult = _validator.validateVehicleId(vehicleId);
    if (validationResult.isLeft()) {
      return validationResult.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _executeWithErrorHandling(
      () => _dataSource.generateReport(vehicleId, startDate, endDate, 'month'),
      'Erro ao gerar relatório mensal',
    );
  }

  @override
  Future<Either<Failure, ReportSummaryEntity>> generateYearlyReport(String vehicleId, int year) async {
    final vehicleValidation = _validator.validateVehicleId(vehicleId);
    if (vehicleValidation.isLeft()) {
      return vehicleValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final yearValidation = _validator.validateYear(year);
    if (yearValidation.isLeft()) {
      return yearValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);

    return _executeWithErrorHandling(
      () => _dataSource.generateReport(vehicleId, startDate, endDate, 'year'),
      'Erro ao gerar relatório anual',
    );
  }

  @override
  Future<Either<Failure, ReportSummaryEntity>> generateCustomReport(String vehicleId, DateTime startDate, DateTime endDate) async {
    final vehicleValidation = _validator.validateVehicleId(vehicleId);
    if (vehicleValidation.isLeft()) {
      return vehicleValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final dateValidation = _validator.validateDateRange(startDate, endDate);
    if (dateValidation.isLeft()) {
      return dateValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    return _executeWithErrorHandling(
      () => _dataSource.generateReport(vehicleId, startDate, endDate, 'custom'),
      'Erro ao gerar relatório personalizado',
    );
  }

  @override
  Future<Either<Failure, ReportComparisonEntity>> compareMonthlyReports(String vehicleId, DateTime currentMonth, DateTime previousMonth) async {
    return _compareReports(
      vehicleId: vehicleId,
      getCurrentReport: () => generateMonthlyReport(vehicleId, currentMonth),
      getPreviousReport: () => generateMonthlyReport(vehicleId, previousMonth),
      comparisonType: 'month_to_month',
    );
  }

  @override
  Future<Either<Failure, ReportComparisonEntity>> compareYearlyReports(String vehicleId, int currentYear, int previousYear) async {
    return _compareReports(
      vehicleId: vehicleId,
      getCurrentReport: () => generateYearlyReport(vehicleId, currentYear),
      getPreviousReport: () => generateYearlyReport(vehicleId, previousYear),
      comparisonType: 'year_to_year',
    );
  }



  @override
  Future<Either<Failure, Map<String, dynamic>>> getFuelEfficiencyTrends(String vehicleId, int months) async {
    final vehicleValidation = _validator.validateVehicleId(vehicleId);
    if (vehicleValidation.isLeft()) {
      return vehicleValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final monthsValidation = _validator.validateMonthsRange(months);
    if (monthsValidation.isLeft()) {
      return monthsValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    return _executeWithErrorHandling(
      () => _dataSource.getFuelEfficiencyTrends(vehicleId, months),
      'Erro ao calcular tendências',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate) async {
    final vehicleValidation = _validator.validateVehicleId(vehicleId);
    if (vehicleValidation.isLeft()) {
      return vehicleValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final dateValidation = _validator.validateDateRange(startDate, endDate);
    if (dateValidation.isLeft()) {
      return dateValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    return _executeWithErrorHandling(
      () => _dataSource.getCostAnalysis(vehicleId, startDate, endDate),
      'Erro ao analisar custos',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsagePatterns(String vehicleId, int months) async {
    final vehicleValidation = _validator.validateVehicleId(vehicleId);
    if (vehicleValidation.isLeft()) {
      return vehicleValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    final monthsValidation = _validator.validateMonthsRange(months);
    if (monthsValidation.isLeft()) {
      return monthsValidation.fold((failure) => Left(failure), (_) => throw StateError('Unreachable'));
    }

    return _executeWithErrorHandling(
      () => _dataSource.getUsagePatterns(vehicleId, months),
      'Erro ao analisar padrões de uso',
    );
  }

  @override
  Future<Either<Failure, String>> exportReportToCSV(ReportSummaryEntity report) async {
    return _executeWithErrorHandling(() async {
      final csvContent = StringBuffer();
      csvContent.writeln('Relatório do Veículo,${report.vehicleId}');
      csvContent.writeln('Período,${report.periodDisplayName}');
      csvContent.writeln('Data Início,${report.startDate.toIso8601String()}');
      csvContent.writeln('Data Fim,${report.endDate.toIso8601String()}');
      csvContent.writeln('');
      csvContent.writeln('Métrica,Valor');
      csvContent.writeln('Total Gasto com Combustível,${report.formattedTotalFuelSpent}');
      csvContent.writeln('Total Litros,${report.formattedTotalFuelLiters}');
      csvContent.writeln('Preço Médio por Litro,${report.formattedAverageFuelPrice}');
      csvContent.writeln('Distância Total,${report.formattedTotalDistance}');
      csvContent.writeln('Consumo Médio,${report.formattedAverageConsumption}');
      csvContent.writeln('Custo por Km,${report.formattedCostPerKm}');
      csvContent.writeln('Registros de Combustível,${report.fuelRecordsCount}');
      return csvContent.toString();
    }, 'Erro ao exportar para CSV');
  }

  @override
  Future<Either<Failure, String>> exportReportToPDF(ReportSummaryEntity report) async {
    return _executeWithErrorHandling(() async {
      final pdfContent = StringBuffer();
      pdfContent.writeln('=== RELATÓRIO PDF DO VEÍCULO ${report.vehicleId} ===');
      pdfContent.writeln('');
      pdfContent.writeln('Período: ${report.periodDisplayName}');
      pdfContent.writeln('Data de Início: ${report.startDate.toLocal().toString().split(' ')[0]}');
      pdfContent.writeln('Data de Fim: ${report.endDate.toLocal().toString().split(' ')[0]}');
      pdfContent.writeln('');
      pdfContent.writeln('=== MÉTRICAS PRINCIPAIS ===');
      pdfContent.writeln('Total Gasto com Combustível: ${report.formattedTotalFuelSpent}');
      pdfContent.writeln('Total de Litros: ${report.formattedTotalFuelLiters}');
      pdfContent.writeln('Preço Médio por Litro: ${report.formattedAverageFuelPrice}');
      pdfContent.writeln('Distância Total: ${report.formattedTotalDistance}');
      pdfContent.writeln('Consumo Médio: ${report.formattedAverageConsumption}');
      pdfContent.writeln('Custo por Km: ${report.formattedCostPerKm}');
      pdfContent.writeln('Número de Registros: ${report.fuelRecordsCount}');
      pdfContent.writeln('');
      pdfContent.writeln('=== FIM DO RELATÓRIO ===');
      return pdfContent.toString();
    }, 'Erro ao exportar para PDF');
  }

}
