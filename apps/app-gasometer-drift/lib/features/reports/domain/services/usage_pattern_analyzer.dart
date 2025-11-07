import '../../../fuel/domain/entities/fuel_record_entity.dart';

/// Service specialized in analyzing vehicle usage patterns and behavior
/// 
/// This service follows the Single Responsibility Principle by focusing
/// exclusively on vehicle usage pattern analysis and trend detection.
abstract class UsagePatternAnalyzer {
  /// Analyzes vehicle usage patterns over a specified period
  /// 
  /// Examines vehicle usage behavior and patterns by:
  /// 1. Analyzing frequency of refueling events
  /// 2. Calculating average intervals between fill-ups
  /// 3. Identifying monthly usage variations
  /// 4. Classifying usage intensity for behavior insights
  ///
  /// **Algorithm Details:**
  /// - Frequency Analysis: Calculates days between refueling events
  /// - Monthly Aggregation: Groups events by month for patterns
  /// - Trend Classification: Compares first and last months
  /// - Usage Intensity: high (< 7 days), medium (7-21), low (> 21)
  ///
  /// **Business Logic:**
  /// - High frequency indicates intensive usage or short trips
  /// - Low frequency suggests occasional use or efficiency
  /// - Increasing trends may indicate lifestyle changes
  /// - Decreasing trends could suggest improved efficiency
  ///
  /// [vehicleId] The unique identifier of the vehicle
  /// [months] Number of months to analyze (minimum: 1)
  /// [fuelRecords] List of fuel records to analyze
  /// 
  /// Returns a Map containing:
  /// - `usage_frequency`: 'high', 'medium', 'low', 'insufficient_data'
  /// - `average_days_between_fills`: Average days between refueling
  /// - `monthly_usage`: List of monthly refueling counts
  /// - `usage_trend`: 'increasing', 'decreasing', 'stable'
  /// - `analysis_period_months`: Number of months analyzed
  Future<Map<String, dynamic>> analyzePatterns(
    String vehicleId,
    int months,
    List<FuelRecordEntity> fuelRecords,
  );
}
