import '../../../fuel/domain/entities/fuel_record_entity.dart';

/// Service specialized in analyzing fuel efficiency trends over time
/// 
/// This service follows the Single Responsibility Principle by focusing
/// exclusively on fuel efficiency pattern analysis and trend detection.
abstract class FuelEfficiencyAnalyzer {
  /// Analyzes fuel efficiency trends over a specified period
  /// 
  /// Performs comprehensive fuel efficiency trend analysis by:
  /// 1. Grouping records by month to calculate monthly averages
  /// 2. Computing trend direction and percentage change
  /// 3. Providing statistical insights for monitoring
  ///
  /// **Algorithm Details:**
  /// - Monthly Aggregation: Consumption values grouped by month and averaged
  /// - Trend Calculation: Uses first and last month averages
  /// - Trend Classification: Changes >5% significant; <-5% decline; others stable
  ///
  /// **Business Logic:**
  /// - Insufficient data (< 2 records) returns 'insufficient_data'
  /// - Efficiency improvements show positive percentage change
  /// - Efficiency declines show negative percentage change
  ///
  /// [vehicleId] The unique identifier of the vehicle
  /// [months] Number of months to analyze (minimum: 1)
  /// [fuelRecords] List of fuel records to analyze
  /// 
  /// Returns a Map containing:
  /// - `trend`: 'improving', 'declining', 'stable', or 'insufficient_data'
  /// - `efficiency_change`: Percentage change in efficiency
  /// - `monthly_averages`: List of monthly consumption averages
  /// - `period_months`: Number of months analyzed
  Future<Map<String, dynamic>> analyzeTrends(
    String vehicleId,
    int months,
    List<FuelRecordEntity> fuelRecords,
  );
}
