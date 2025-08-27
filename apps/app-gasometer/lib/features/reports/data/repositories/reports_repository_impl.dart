import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_data_source.dart';

@LazySingleton(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDataSource _dataSource;

  ReportsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ReportSummaryEntity>> generateMonthlyReport(String vehicleId, DateTime month) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final report = await _dataSource.generateReport(vehicleId, startDate, endDate, 'month');
      return Right(report);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao gerar relatório mensal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReportSummaryEntity>> generateYearlyReport(String vehicleId, int year) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      if (year < 2000 || year > DateTime.now().year + 1) {
        return const Left(ValidationFailure('Ano inválido'));
      }

      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);

      final report = await _dataSource.generateReport(vehicleId, startDate, endDate, 'year');
      return Right(report);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao gerar relatório anual: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReportSummaryEntity>> generateCustomReport(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      if (startDate.isAfter(endDate)) {
        return const Left(ValidationFailure('Data inicial não pode ser posterior à data final'));
      }

      if (endDate.isAfter(DateTime.now())) {
        return const Left(ValidationFailure('Data final não pode ser no futuro'));
      }

      final report = await _dataSource.generateReport(vehicleId, startDate, endDate, 'custom');
      return Right(report);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao gerar relatório personalizado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReportComparisonEntity>> compareMonthlyReports(String vehicleId, DateTime currentMonth, DateTime previousMonth) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      // Generate both reports in parallel for better performance
      final results = await Future.wait([
        generateMonthlyReport(vehicleId, currentMonth),
        generateMonthlyReport(vehicleId, previousMonth),
      ]);
      
      final currentResult = results[0];
      final previousResult = results[1];

      return currentResult.fold(
        (failure) => Left(failure),
        (currentReport) => previousResult.fold(
          (failure) => Left(failure),
          (previousReport) async {
            try {
              final comparison = await _dataSource.compareReports(
                vehicleId, 
                currentReport, 
                previousReport, 
                'month_to_month'
              );
              return Right(comparison);
            } catch (e) {
              return Left(UnexpectedFailure('Erro ao comparar relatórios: ${e.toString()}'));
            }
          },
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao comparar relatórios mensais: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ReportComparisonEntity>> compareYearlyReports(String vehicleId, int currentYear, int previousYear) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      // Generate both reports in parallel for better performance
      final results = await Future.wait([
        generateYearlyReport(vehicleId, currentYear),
        generateYearlyReport(vehicleId, previousYear),
      ]);
      
      final currentResult = results[0];
      final previousResult = results[1];

      return currentResult.fold(
        (failure) => Left(failure),
        (currentReport) => previousResult.fold(
          (failure) => Left(failure),
          (previousReport) async {
            try {
              final comparison = await _dataSource.compareReports(
                vehicleId, 
                currentReport, 
                previousReport, 
                'year_to_year'
              );
              return Right(comparison);
            } catch (e) {
              return Left(UnexpectedFailure('Erro ao comparar relatórios: ${e.toString()}'));
            }
          },
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao comparar relatórios anuais: ${e.toString()}'));
    }
  }



  @override
  Future<Either<Failure, Map<String, dynamic>>> getFuelEfficiencyTrends(String vehicleId, int months) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      if (months <= 0 || months > 24) {
        return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
      }

      final trends = await _dataSource.getFuelEfficiencyTrends(vehicleId, months);
      return Right(trends);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao calcular tendências: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      if (startDate.isAfter(endDate)) {
        return const Left(ValidationFailure('Data inicial não pode ser posterior à data final'));
      }

      final analysis = await _dataSource.getCostAnalysis(vehicleId, startDate, endDate);
      return Right(analysis);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao analisar custos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUsagePatterns(String vehicleId, int months) async {
    try {
      if (vehicleId.isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      if (months <= 0 || months > 24) {
        return const Left(ValidationFailure('Número de meses deve ser entre 1 e 24'));
      }

      final patterns = await _dataSource.getUsagePatterns(vehicleId, months);
      return Right(patterns);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao analisar padrões de uso: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportReportToCSV(ReportSummaryEntity report) async {
    try {
      // Simple CSV export - can be enhanced with proper CSV library
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

      return Right(csvContent.toString());
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao exportar para CSV: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportReportToPDF(ReportSummaryEntity report) async {
    try {
      // Basic PDF content structure - would need proper PDF library for actual PDF generation
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

      return Right(pdfContent.toString());
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao exportar para PDF: ${e.toString()}'));
    }
  }

}