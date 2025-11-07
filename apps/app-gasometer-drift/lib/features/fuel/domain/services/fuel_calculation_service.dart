import 'package:core/core.dart';

import '../entities/fuel_record_entity.dart';

/// Service especializado para cálculos e estatísticas de combustível
/// Aplica SRP (Single Responsibility Principle) - responsável apenas por cálculos
@lazySingleton
class FuelCalculationService {
  /// Calcula consumo médio a partir de uma lista de registros
  /// Apenas registros com tanque cheio são considerados para cálculo preciso
  double calculateAverageConsumption(List<FuelRecordEntity> records) {
    if (records.isEmpty) return 0.0;

    final sortedRecords = List<FuelRecordEntity>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final consumptions = <double>[];

    for (int i = 1; i < sortedRecords.length; i++) {
      final current = sortedRecords[i];
      final previous = sortedRecords[i - 1];

      // Cálculo preciso: ambos os registros devem ter tanque cheio
      if (current.fullTank && previous.fullTank) {
        final distance = current.odometer - previous.odometer;
        if (distance > 0 && current.liters > 0) {
          consumptions.add(distance / current.liters);
        }
      }
    }

    if (consumptions.isEmpty) return 0.0;

    return consumptions.reduce((a, b) => a + b) / consumptions.length;
  }

  /// Calcula total de litros
  double calculateTotalLiters(List<FuelRecordEntity> records) {
    return records.fold<double>(0, (total, record) => total + record.liters);
  }

  /// Calcula total gasto
  double calculateTotalCost(List<FuelRecordEntity> records) {
    return records.fold<double>(0, (total, record) => total + record.totalPrice);
  }

  /// Calcula preço médio por litro
  double calculateAveragePricePerLiter(List<FuelRecordEntity> records) {
    if (records.isEmpty) return 0.0;

    final totalPrice = records.fold<double>(
      0,
      (total, record) => total + record.pricePerLiter,
    );

    return totalPrice / records.length;
  }

  /// Calcula total gasto em um período específico
  double calculateTotalSpentInRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    final recordsInRange = records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();

    return calculateTotalCost(recordsInRange);
  }

  /// Calcula total de litros em um período específico
  double calculateTotalLitersInRange(
    List<FuelRecordEntity> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    final recordsInRange = records.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();

    return calculateTotalLiters(recordsInRange);
  }

  /// Calcula estatísticas completas de combustível
  FuelStatistics calculateStatistics(List<FuelRecordEntity> records) {
    if (records.isEmpty) {
      return FuelStatistics(
        totalLiters: 0.0,
        totalCost: 0.0,
        averagePrice: 0.0,
        averageConsumption: 0.0,
        totalRecords: 0,
        lastUpdated: DateTime.now(),
      );
    }

    final totalLiters = calculateTotalLiters(records);
    final totalCost = calculateTotalCost(records);
    final averagePrice = calculateAveragePricePerLiter(records);
    final averageConsumption = calculateAverageConsumption(records);

    return FuelStatistics(
      totalLiters: totalLiters,
      totalCost: totalCost,
      averagePrice: averagePrice,
      averageConsumption: averageConsumption,
      totalRecords: records.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calcula economia entre dois períodos
  double calculateSavings(
    List<FuelRecordEntity> oldPeriodRecords,
    List<FuelRecordEntity> newPeriodRecords,
  ) {
    final oldAvgPrice = calculateAveragePricePerLiter(oldPeriodRecords);
    final newAvgPrice = calculateAveragePricePerLiter(newPeriodRecords);

    return oldAvgPrice - newAvgPrice;
  }

  /// Calcula tendência de consumo (melhoria ou piora)
  /// Retorna valor positivo se o consumo está melhorando (menos combustível)
  /// Retorna valor negativo se o consumo está piorando (mais combustível)
  double calculateConsumptionTrend(
    List<FuelRecordEntity> oldPeriodRecords,
    List<FuelRecordEntity> newPeriodRecords,
  ) {
    final oldAvgConsumption = calculateAverageConsumption(oldPeriodRecords);
    final newAvgConsumption = calculateAverageConsumption(newPeriodRecords);

    if (oldAvgConsumption == 0 || newAvgConsumption == 0) return 0.0;

    return newAvgConsumption - oldAvgConsumption;
  }

  /// Calcula custo médio por km rodado
  double calculateCostPerKm(List<FuelRecordEntity> records) {
    if (records.length < 2) return 0.0;

    final sortedRecords = List<FuelRecordEntity>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalDistance =
        sortedRecords.last.odometer - sortedRecords.first.odometer;
    final totalCost = calculateTotalCost(records);

    if (totalDistance <= 0) return 0.0;

    return totalCost / totalDistance;
  }

  /// Estima custo para uma distância específica baseado no histórico
  double estimateCostForDistance(
    List<FuelRecordEntity> records,
    double distance,
  ) {
    final costPerKm = calculateCostPerKm(records);
    return costPerKm * distance;
  }

  /// Estima litros necessários para uma distância específica
  double estimateLitersForDistance(
    List<FuelRecordEntity> records,
    double distance,
  ) {
    final avgConsumption = calculateAverageConsumption(records);
    if (avgConsumption == 0) return 0.0;

    return distance / avgConsumption;
  }
}

/// Statistics for analytics caching
class FuelStatistics {
  const FuelStatistics({
    required this.totalLiters,
    required this.totalCost,
    required this.averagePrice,
    required this.averageConsumption,
    required this.totalRecords,
    required this.lastUpdated,
  });

  final double totalLiters;
  final double totalCost;
  final double averagePrice;
  final double averageConsumption;
  final int totalRecords;
  final DateTime lastUpdated;

  bool get needsRecalculation {
    final now = DateTime.now();
    const maxCacheTime = Duration(minutes: 5);
    return now.difference(lastUpdated) > maxCacheTime;
  }
}
