import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../fuel/domain/repositories/fuel_repository.dart';
import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/services/cost_analysis_service.dart';
import '../../domain/services/fuel_efficiency_analyzer.dart';
import '../../domain/services/report_generation_service.dart';
import '../../domain/services/usage_pattern_analyzer.dart';

abstract class ReportsDataSource {
  Future<ReportSummaryEntity> generateReport(String vehicleId, DateTime startDate, DateTime endDate, String period);
  Future<ReportComparisonEntity> compareReports(String vehicleId, ReportSummaryEntity current, ReportSummaryEntity previous, String comparisonType);
  Future<Map<String, dynamic>> getFuelEfficiencyTrends(String vehicleId, int months);
  Future<Map<String, dynamic>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getUsagePatterns(String vehicleId, int months);
}

@LazySingleton(as: ReportsDataSource)
class ReportsDataSourceImpl implements ReportsDataSource {
  ReportsDataSourceImpl(
    this._fuelRepository,
    this._reportGenerationService,
    this._fuelEfficiencyAnalyzer,
    this._costAnalysisService,
    this._usagePatternAnalyzer,
  );

  final FuelRepository _fuelRepository;
  final ReportGenerationService _reportGenerationService;
  final FuelEfficiencyAnalyzer _fuelEfficiencyAnalyzer;
  final CostAnalysisService _costAnalysisService;
  final UsagePatternAnalyzer _usagePatternAnalyzer;

  @override
  Future<ReportSummaryEntity> generateReport(String vehicleId, DateTime startDate, DateTime endDate, String period) async {
    try {
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros de combustível: ${failure.message}'),
        (fuelRecords) => _reportGenerationService.generateReport(
          vehicleId,
          startDate,
          endDate,
          period,
          fuelRecords,
        ),
      );
    } catch (e) {
      throw CacheException('Erro ao gerar relatório: ${e.toString()}');
    }
  }

  @override
  Future<ReportComparisonEntity> compareReports(String vehicleId, ReportSummaryEntity current, ReportSummaryEntity previous, String comparisonType) async {
    try {
      return ReportComparisonEntity(
        vehicleId: vehicleId,
        currentPeriod: current,
        previousPeriod: previous,
        comparisonType: comparisonType,
      );
    } catch (e) {
      throw CacheException('Erro ao comparar relatórios: ${e.toString()}');
    }
  }


  @override
  Future<Map<String, dynamic>> getFuelEfficiencyTrends(String vehicleId, int months) async {
    try {
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) => _fuelEfficiencyAnalyzer.analyzeTrends(vehicleId, months, fuelRecords),
      );
    } catch (e) {
      throw CacheException('Erro ao calcular tendências: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) => _costAnalysisService.analyzeCosts(vehicleId, startDate, endDate, fuelRecords),
      );
    } catch (e) {
      throw CacheException('Erro ao analisar custos: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUsagePatterns(String vehicleId, int months) async {
    try {
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) => _usagePatternAnalyzer.analyzePatterns(vehicleId, months, fuelRecords),
      );
    } catch (e) {
      throw CacheException('Erro ao analisar padrões de uso: ${e.toString()}');
    }
  }
}
