import 'package:equatable/equatable.dart';
import 'report_summary_entity.dart';

class ReportComparisonEntity extends Equatable {
  final String vehicleId;
  final ReportSummaryEntity currentPeriod;
  final ReportSummaryEntity previousPeriod;
  final String comparisonType; // 'month_to_month', 'year_to_year', etc.
  
  const ReportComparisonEntity({
    required this.vehicleId,
    required this.currentPeriod,
    required this.previousPeriod,
    required this.comparisonType,
  });
  
  @override
  List<Object> get props => [vehicleId, currentPeriod, previousPeriod, comparisonType];
  
  // Growth calculations
  double get fuelSpentGrowth => currentPeriod.calculateGrowthRate(previousPeriod, 'fuel_spent');
  double get fuelLitersGrowth => currentPeriod.calculateGrowthRate(previousPeriod, 'fuel_liters');
  double get distanceGrowth => currentPeriod.calculateGrowthRate(previousPeriod, 'distance');
  double get consumptionGrowth => currentPeriod.calculateGrowthRate(previousPeriod, 'consumption');
  
  // Comparison insights
  bool get isFuelSpentIncreasing => fuelSpentGrowth > 0;
  bool get isFuelLitersIncreasing => fuelLitersGrowth > 0;
  bool get isDistanceIncreasing => distanceGrowth > 0;
  bool get isConsumptionImproving => consumptionGrowth > 0; // Higher km/L is better
  
  // Summary
  bool get hasImprovedEfficiency => isConsumptionImproving;
  bool get hasReducedCosts => !isFuelSpentIncreasing;
  bool get hasIncreasedUsage => isDistanceIncreasing;
  
  // Formatted growth rates
  String get formattedFuelSpentGrowth => '${fuelSpentGrowth.abs().toStringAsFixed(1)}%';
  String get formattedFuelLitersGrowth => '${fuelLitersGrowth.abs().toStringAsFixed(1)}%';
  String get formattedDistanceGrowth => '${distanceGrowth.abs().toStringAsFixed(1)}%';
  String get formattedConsumptionGrowth => '${consumptionGrowth.abs().toStringAsFixed(1)}%';
  
  // Comparison insights text
  String get fuelSpentInsight {
    if (fuelSpentGrowth > 5) {
      return 'Gastos com combustível aumentaram significativamente';
    } else if (fuelSpentGrowth > 0) {
      return 'Pequeno aumento nos gastos com combustível';
    } else if (fuelSpentGrowth < -5) {
      return 'Gastos com combustível reduziram significativamente';
    } else if (fuelSpentGrowth < 0) {
      return 'Pequena redução nos gastos com combustível';
    } else {
      return 'Gastos com combustível mantidos estáveis';
    }
  }
  
  String get consumptionInsight {
    if (consumptionGrowth > 5) {
      return 'Eficiência de combustível melhorou significativamente';
    } else if (consumptionGrowth > 0) {
      return 'Leve melhoria na eficiência de combustível';
    } else if (consumptionGrowth < -5) {
      return 'Eficiência de combustível piorou significativamente';
    } else if (consumptionGrowth < 0) {
      return 'Leve redução na eficiência de combustível';
    } else {
      return 'Eficiência de combustível mantida estável';
    }
  }
  
  String get distanceInsight {
    if (distanceGrowth > 20) {
      return 'Uso do veículo aumentou muito este período';
    } else if (distanceGrowth > 0) {
      return 'Pequeno aumento no uso do veículo';
    } else if (distanceGrowth < -20) {
      return 'Uso do veículo reduziu muito este período';
    } else if (distanceGrowth < 0) {
      return 'Pequena redução no uso do veículo';
    } else {
      return 'Uso do veículo mantido estável';
    }
  }
  
  // Overall assessment
  String get overallAssessment {
    int positiveFactors = 0;
    int negativeFactors = 0;
    
    if (hasImprovedEfficiency) positiveFactors++;
    if (hasReducedCosts) positiveFactors++;
    if (!isConsumptionImproving && consumptionGrowth < -5) negativeFactors++;
    if (isFuelSpentIncreasing && fuelSpentGrowth > 10) negativeFactors++;
    
    if (positiveFactors > negativeFactors) {
      return 'Desempenho melhorou neste período';
    } else if (negativeFactors > positiveFactors) {
      return 'Alguns indicadores pioraram neste período';
    } else {
      return 'Desempenho mantido estável';
    }
  }
}