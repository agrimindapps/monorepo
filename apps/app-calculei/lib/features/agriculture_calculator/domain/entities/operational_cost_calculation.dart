import 'package:equatable/equatable.dart';

/// Pure domain entity - Operational cost calculation result
///
/// Represents the complete calculation of operational costs for agricultural machinery
/// including fuel, labor, and machinery depreciation costs
class OperationalCostCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Type of operation (Preparo/Plantio/Pulverização/Colheita)
  final String operationType;

  /// Fuel consumption in liters per hectare (L/ha)
  final double fuelConsumption;

  /// Fuel price in reais per liter (R$/L)
  final double fuelPrice;

  /// Labor hours required per hectare (h/ha)
  final double laborHours;

  /// Labor cost per hour (R$/h)
  final double laborCost;

  /// Machinery value in reais (R$)
  final double machineryValue;

  /// Useful life of machinery in hours (h)
  final double usefulLife;

  /// Maintenance factor as percentage (0-100)
  final double maintenanceFactor;

  /// Area worked in hectares (ha)
  final double areaWorked;

  /// Fuel cost per hectare (R$/ha)
  /// Formula: fuelConsumption × fuelPrice
  final double fuelCostPerHa;

  /// Labor cost per hectare (R$/ha)
  /// Formula: laborHours × laborCost
  final double laborCostPerHa;

  /// Machinery cost per hectare (R$/ha)
  /// Formula: (machineryValue / usefulLife) × (1 + maintenanceFactor/100) / fieldCapacity
  final double machineryCostPerHa;

  /// Total cost per hectare (R$/ha)
  /// Formula: fuelCostPerHa + laborCostPerHa + machineryCostPerHa
  final double totalCostPerHa;

  /// Total cost for the area (R$)
  /// Formula: totalCostPerHa × areaWorked
  final double totalCost;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const OperationalCostCalculation({
    required this.id,
    required this.operationType,
    required this.fuelConsumption,
    required this.fuelPrice,
    required this.laborHours,
    required this.laborCost,
    required this.machineryValue,
    required this.usefulLife,
    required this.maintenanceFactor,
    required this.areaWorked,
    required this.fuelCostPerHa,
    required this.laborCostPerHa,
    required this.machineryCostPerHa,
    required this.totalCostPerHa,
    required this.totalCost,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory OperationalCostCalculation.empty() {
    return OperationalCostCalculation(
      id: '',
      operationType: 'Preparo',
      fuelConsumption: 0,
      fuelPrice: 0,
      laborHours: 0,
      laborCost: 0,
      machineryValue: 0,
      usefulLife: 0,
      maintenanceFactor: 0,
      areaWorked: 0,
      fuelCostPerHa: 0,
      laborCostPerHa: 0,
      machineryCostPerHa: 0,
      totalCostPerHa: 0,
      totalCost: 0,
      calculatedAt: DateTime.now(),
    );
  }

  OperationalCostCalculation copyWith({
    String? id,
    String? operationType,
    double? fuelConsumption,
    double? fuelPrice,
    double? laborHours,
    double? laborCost,
    double? machineryValue,
    double? usefulLife,
    double? maintenanceFactor,
    double? areaWorked,
    double? fuelCostPerHa,
    double? laborCostPerHa,
    double? machineryCostPerHa,
    double? totalCostPerHa,
    double? totalCost,
    DateTime? calculatedAt,
  }) {
    return OperationalCostCalculation(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      fuelConsumption: fuelConsumption ?? this.fuelConsumption,
      fuelPrice: fuelPrice ?? this.fuelPrice,
      laborHours: laborHours ?? this.laborHours,
      laborCost: laborCost ?? this.laborCost,
      machineryValue: machineryValue ?? this.machineryValue,
      usefulLife: usefulLife ?? this.usefulLife,
      maintenanceFactor: maintenanceFactor ?? this.maintenanceFactor,
      areaWorked: areaWorked ?? this.areaWorked,
      fuelCostPerHa: fuelCostPerHa ?? this.fuelCostPerHa,
      laborCostPerHa: laborCostPerHa ?? this.laborCostPerHa,
      machineryCostPerHa: machineryCostPerHa ?? this.machineryCostPerHa,
      totalCostPerHa: totalCostPerHa ?? this.totalCostPerHa,
      totalCost: totalCost ?? this.totalCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        operationType,
        fuelConsumption,
        fuelPrice,
        laborHours,
        laborCost,
        machineryValue,
        usefulLife,
        maintenanceFactor,
        areaWorked,
        fuelCostPerHa,
        laborCostPerHa,
        machineryCostPerHa,
        totalCostPerHa,
        totalCost,
        calculatedAt,
      ];
}
