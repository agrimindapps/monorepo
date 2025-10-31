import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../entities/report_summary_entity.dart';

/// Service responsible for generating report summaries from fuel records
/// 
/// This service follows the Single Responsibility Principle by focusing
/// exclusively on the core business logic of transforming fuel records
/// into comprehensive report summaries.
abstract class ReportGenerationService {
  /// Generates a comprehensive report summary for a vehicle
  /// 
  /// Analyzes fuel records within a specified date range and calculates:
  /// - Total fuel costs and consumption
  /// - Distance traveled and efficiency metrics
  /// - Average values and trends
  /// 
  /// [vehicleId] The unique identifier of the vehicle
  /// [startDate] Start date of the reporting period (inclusive)
  /// [endDate] End date of the reporting period (inclusive)
  /// [period] Period type ('month', 'year', 'custom')
  /// [fuelRecords] List of fuel records to analyze
  /// 
  /// Returns a [ReportSummaryEntity] with all calculated metrics
  Future<ReportSummaryEntity> generateReport(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
    String period,
    List<FuelRecordEntity> fuelRecords,
  );
}
