import '../../features/vehicles/data/models/vehicle_model.dart';

/// Interface for vehicle business operations
/// Provides contract for vehicle-related business logic
abstract class IVehicleService {
  /// Get vehicle usage statistics
  Future<VehicleStatistics> getStatistics(String vehicleId);

  /// Calculate vehicle health score
  Future<VehicleHealthScore> calculateHealthScore(String vehicleId);

  /// Get maintenance alerts
  Future<List<MaintenanceAlert>> getMaintenanceAlerts(String vehicleId);

  /// Validate vehicle data
  ValidationResult validateVehicle(VehicleModel vehicle);

  /// Get vehicle efficiency metrics
  Future<VehicleEfficiency> getEfficiencyMetrics(String vehicleId);

  /// Compare vehicles performance
  Future<VehicleComparison> compareVehicles(List<String> vehicleIds);

  /// Get vehicle recommendations
  Future<List<VehicleRecommendation>> getRecommendations(String vehicleId);
}

/// Vehicle statistics data model
class VehicleStatistics {
  final String vehicleId;
  final double totalKilometers;
  final double totalFuelCost;
  final double totalMaintenanceCost;
  final double totalExpenses;
  final double averageConsumption;
  final int totalFuelUps;
  final int totalMaintenanceRecords;

  const VehicleStatistics({
    required this.vehicleId,
    required this.totalKilometers,
    required this.totalFuelCost,
    required this.totalMaintenanceCost,
    required this.totalExpenses,
    required this.averageConsumption,
    required this.totalFuelUps,
    required this.totalMaintenanceRecords,
  });
}

/// Vehicle health score data model
class VehicleHealthScore {
  final String vehicleId;
  final double score; // 0-100
  final HealthCategory category;
  final List<HealthFactor> factors;
  final List<String> recommendations;

  const VehicleHealthScore({
    required this.vehicleId,
    required this.score,
    required this.category,
    required this.factors,
    required this.recommendations,
  });
}

/// Health category enumeration
enum HealthCategory {
  excellent,
  good,
  fair,
  poor,
  critical,
}

/// Health factor data model
class HealthFactor {
  final String name;
  final double score;
  final String description;
  final FactorImpact impact;

  const HealthFactor({
    required this.name,
    required this.score,
    required this.description,
    required this.impact,
  });
}

/// Factor impact enumeration
enum FactorImpact {
  positive,
  negative,
  neutral,
}

/// Maintenance alert data model
class MaintenanceAlert {
  final String type;
  final String message;
  final AlertSeverity severity;
  final DateTime? dueDate;
  final double? dueMileage;

  const MaintenanceAlert({
    required this.type,
    required this.message,
    required this.severity,
    this.dueDate,
    this.dueMileage,
  });
}

/// Alert severity enumeration
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Vehicle efficiency data model
class VehicleEfficiency {
  final String vehicleId;
  final double fuelEfficiency; // km/L
  final double costPerKilometer;
  final EfficiencyTrend trend;
  final Map<String, double> monthlyEfficiency;

  const VehicleEfficiency({
    required this.vehicleId,
    required this.fuelEfficiency,
    required this.costPerKilometer,
    required this.trend,
    required this.monthlyEfficiency,
  });
}

/// Efficiency trend enumeration
enum EfficiencyTrend {
  improving,
  stable,
  declining,
}

/// Vehicle comparison data model
class VehicleComparison {
  final List<VehicleStatistics> vehicleStats;
  final String mostEfficientVehicleId;
  final String mostExpensiveVehicleId;
  final Map<String, dynamic> comparisonMetrics;

  const VehicleComparison({
    required this.vehicleStats,
    required this.mostEfficientVehicleId,
    required this.mostExpensiveVehicleId,
    required this.comparisonMetrics,
  });
}

/// Vehicle recommendation data model
class VehicleRecommendation {
  final String type;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final List<String> actions;

  const VehicleRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.actions,
  });
}

/// Recommendation priority enumeration
enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}