import 'package:equatable/equatable.dart';

class ReportSummaryEntity extends Equatable {
  
  const ReportSummaryEntity({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.totalFuelSpent,
    required this.totalFuelLiters,
    required this.averageFuelPrice,
    required this.fuelRecordsCount,
    required this.totalDistanceTraveled,
    required this.averageConsumption,
    required this.lastOdometerReading,
    required this.firstOdometerReading,
    this.totalMaintenanceSpent = 0.0,
    this.maintenanceRecordsCount = 0,
    this.totalExpensesSpent = 0.0,
    this.expenseRecordsCount = 0,
    required this.costPerKm,
    this.trends = const {},
    this.metadata = const {},
  });
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final String period; // 'month', 'year', 'custom'
  
  // Fuel data
  final double totalFuelSpent;
  final double totalFuelLiters;
  final double averageFuelPrice;
  final int fuelRecordsCount;
  
  // Distance data
  final double totalDistanceTraveled;
  final double averageConsumption; // km/L
  final double lastOdometerReading;
  final double firstOdometerReading;
  
  // Maintenance data (optional)
  final double totalMaintenanceSpent;
  final int maintenanceRecordsCount;
  
  // Expenses data (optional)  
  final double totalExpensesSpent;
  final int expenseRecordsCount;
  
  // Analysis
  final double costPerKm;
  final Map<String, dynamic> trends; // Growth rates, comparisons, etc.
  final Map<String, dynamic> metadata;
  
  @override
  List<Object?> get props => [
    vehicleId,
    startDate,
    endDate,
    period,
    totalFuelSpent,
    totalFuelLiters,
    averageFuelPrice,
    fuelRecordsCount,
    totalDistanceTraveled,
    averageConsumption,
    lastOdometerReading,
    firstOdometerReading,
    totalMaintenanceSpent,
    maintenanceRecordsCount,
    totalExpensesSpent,
    expenseRecordsCount,
    costPerKm,
    trends,
    metadata,
  ];
  
  ReportSummaryEntity copyWith({
    String? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
    String? period,
    double? totalFuelSpent,
    double? totalFuelLiters,
    double? averageFuelPrice,
    int? fuelRecordsCount,
    double? totalDistanceTraveled,
    double? averageConsumption,
    double? lastOdometerReading,
    double? firstOdometerReading,
    double? totalMaintenanceSpent,
    int? maintenanceRecordsCount,
    double? totalExpensesSpent,
    int? expenseRecordsCount,
    double? costPerKm,
    Map<String, dynamic>? trends,
    Map<String, dynamic>? metadata,
  }) {
    return ReportSummaryEntity(
      vehicleId: vehicleId ?? this.vehicleId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      totalFuelSpent: totalFuelSpent ?? this.totalFuelSpent,
      totalFuelLiters: totalFuelLiters ?? this.totalFuelLiters,
      averageFuelPrice: averageFuelPrice ?? this.averageFuelPrice,
      fuelRecordsCount: fuelRecordsCount ?? this.fuelRecordsCount,
      totalDistanceTraveled: totalDistanceTraveled ?? this.totalDistanceTraveled,
      averageConsumption: averageConsumption ?? this.averageConsumption,
      lastOdometerReading: lastOdometerReading ?? this.lastOdometerReading,
      firstOdometerReading: firstOdometerReading ?? this.firstOdometerReading,
      totalMaintenanceSpent: totalMaintenanceSpent ?? this.totalMaintenanceSpent,
      maintenanceRecordsCount: maintenanceRecordsCount ?? this.maintenanceRecordsCount,
      totalExpensesSpent: totalExpensesSpent ?? this.totalExpensesSpent,
      expenseRecordsCount: expenseRecordsCount ?? this.expenseRecordsCount,
      costPerKm: costPerKm ?? this.costPerKm,
      trends: trends ?? this.trends,
      metadata: metadata ?? this.metadata,
    );
  }
  
  // Helper getters
  bool get hasData => fuelRecordsCount > 0 || maintenanceRecordsCount > 0 || expenseRecordsCount > 0;
  
  bool get hasFuelData => fuelRecordsCount > 0 && totalFuelSpent > 0;
  
  bool get hasDistanceData => totalDistanceTraveled > 0;
  
  bool get hasMaintenanceData => maintenanceRecordsCount > 0;
  
  bool get hasExpenseData => expenseRecordsCount > 0;
  
  double get totalSpent => totalFuelSpent + totalMaintenanceSpent + totalExpensesSpent;
  
  int get totalRecords => fuelRecordsCount + maintenanceRecordsCount + expenseRecordsCount;
  
  // Formatted getters
  String get formattedTotalFuelSpent => 'R\$ ${totalFuelSpent.toStringAsFixed(2)}';
  
  String get formattedTotalSpent => 'R\$ ${totalSpent.toStringAsFixed(2)}';
  
  String get formattedTotalFuelLiters => '${totalFuelLiters.toStringAsFixed(1)}L';
  
  String get formattedTotalDistance => '${totalDistanceTraveled.toStringAsFixed(0)} km';
  
  String get formattedAverageConsumption => '${averageConsumption.toStringAsFixed(1)} km/L';
  
  String get formattedCostPerKm => 'R\$ ${costPerKm.toStringAsFixed(3)}/km';
  
  String get formattedAverageFuelPrice => 'R\$ ${averageFuelPrice.toStringAsFixed(3)}/L';
  
  String get periodDisplayName {
    switch (period) {
      case 'month':
        return 'Mensal';
      case 'year':
        return 'Anual';
      case 'custom':
        return 'Personalizado';
      default:
        return period;
    }
  }
  
  // Calculate growth rate compared to another report
  double calculateGrowthRate(ReportSummaryEntity previousReport, String metric) {
    switch (metric) {
      case 'fuel_spent':
        if (previousReport.totalFuelSpent == 0) return 0.0;
        return ((totalFuelSpent - previousReport.totalFuelSpent) / previousReport.totalFuelSpent) * 100;
      case 'fuel_liters':
        if (previousReport.totalFuelLiters == 0) return 0.0;
        return ((totalFuelLiters - previousReport.totalFuelLiters) / previousReport.totalFuelLiters) * 100;
      case 'distance':
        if (previousReport.totalDistanceTraveled == 0) return 0.0;
        return ((totalDistanceTraveled - previousReport.totalDistanceTraveled) / previousReport.totalDistanceTraveled) * 100;
      case 'consumption':
        if (previousReport.averageConsumption == 0) return 0.0;
        return ((averageConsumption - previousReport.averageConsumption) / previousReport.averageConsumption) * 100;
      default:
        return 0.0;
    }
  }
}