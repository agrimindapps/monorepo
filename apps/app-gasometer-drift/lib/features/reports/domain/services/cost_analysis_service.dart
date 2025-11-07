import '../../../fuel/domain/entities/fuel_record_entity.dart';

/// Service specialized in analyzing vehicle cost patterns and trends
/// 
/// This service follows the Single Responsibility Principle by focusing
/// exclusively on cost analysis and price trend detection.
abstract class CostAnalysisService {
  /// Performs comprehensive cost analysis for a vehicle over a period
  /// 
  /// Analyzes fuel expenditure patterns and price trends by:
  /// 1. Calculating total costs and average expenditure per fill-up
  /// 2. Analyzing monthly price trends to identify fluctuations
  /// 3. Providing detailed cost breakdowns for budget planning
  ///
  /// **Algorithm Details:**
  /// - Data Aggregation: Sums all fuel costs within analysis period
  /// - Price Trend Analysis: Groups by month and calculates min/max/average
  /// - Statistical Analysis: Computes averages for financial insights
  ///
  /// **Business Logic:**
  /// - Empty dataset returns zero values for all metrics
  /// - Monthly price analysis identifies seasonal variations
  /// - Future integration planned for maintenance/other expenses
  ///
  /// [vehicleId] The unique identifier of the vehicle
  /// [startDate] Start date of the analysis period (inclusive)
  /// [endDate] End date of the analysis period (inclusive)
  /// [fuelRecords] List of fuel records to analyze
  /// 
  /// Returns a Map containing:
  /// - `total_cost`: Total fuel cost during period
  /// - `average_cost_per_fill`: Average cost per refueling
  /// - `cost_breakdown`: Categorized expenses
  /// - `price_trends`: Monthly price statistics
  /// - `records_analyzed`: Number of records processed
  Future<Map<String, dynamic>> analyzeCosts(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
    List<FuelRecordEntity> fuelRecords,
  );
}
