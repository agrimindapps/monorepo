import 'package:core/core.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';

/// Serviço responsável por calcular estatísticas de consumo de combustível
///
/// Centraliza cálculos de média de consumo, eficiência e análises,
/// seguindo o princípio Single Responsibility.

class FuelConsumptionCalculator {
  FuelConsumptionCalculator();

  /// Calcula consumo médio (km/l) de uma lista de abastecimentos
  double calculateAverageConsumption(List<FuelRecordEntity> records) {
    if (records.length < 2) return 0.0;

    // Ordena por data (mais antigo primeiro)
    final sorted = List<FuelRecordEntity>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    var totalKm = 0.0;
    var totalLiters = 0.0;

    for (var i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final previous = sorted[i - 1];

      // Calcula apenas se ambos tiverem odômetro
      if (current.odometer > 0 && previous.odometer > 0) {
        final km = current.odometer - previous.odometer;

        // Valida se a distância faz sentido (> 0 e < 2000km)
        if (km > 0 && km < 2000) {
          totalKm += km;
          totalLiters += current.liters;
        }
      }
    }

    return totalLiters > 0 ? totalKm / totalLiters : 0.0;
  }

  /// Calcula consumo de um período específico
  ConsumptionResult calculateConsumptionForPeriod(
    List<FuelRecordEntity> records,
    DateTime start,
    DateTime end,
  ) {
    final periodRecords =
        records
            .where((r) => r.date.isAfter(start) && r.date.isBefore(end))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (periodRecords.isEmpty) {
      return ConsumptionResult.empty();
    }

    final totalCost = periodRecords.fold<double>(
      0.0,
      (total, record) => total + record.totalPrice,
    );

    final totalLiters = periodRecords.fold<double>(
      0.0,
      (total, record) => total + record.liters,
    );

    final averageConsumption = calculateAverageConsumption(periodRecords);

    // Calcula distância percorrida
    var totalDistance = 0.0;
    if (periodRecords.length >= 2) {
      final firstOdometer = periodRecords.first.odometer;
      final lastOdometer = periodRecords.last.odometer;
      if (firstOdometer > 0 && lastOdometer > firstOdometer) {
        totalDistance = lastOdometer - firstOdometer;
      }
    }

    return ConsumptionResult(
      averageConsumptionKmL: averageConsumption,
      totalCost: totalCost,
      totalLiters: totalLiters,
      totalDistance: totalDistance,
      refuelCount: periodRecords.length,
      averageCostPerLiter: totalLiters > 0 ? totalCost / totalLiters : 0.0,
      period: DatePeriod(start: start, end: end),
    );
  }

  /// Calcula tendência de consumo (melhora ou piora)
  ConsumptionTrend analyzeTrend(List<FuelRecordEntity> records) {
    if (records.length < 4) {
      return ConsumptionTrend.stable;
    }

    // Divide em dois períodos
    final sorted = List<FuelRecordEntity>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final midPoint = sorted.length ~/ 2;
    final firstHalf = sorted.sublist(0, midPoint);
    final secondHalf = sorted.sublist(midPoint);

    final firstAvg = calculateAverageConsumption(firstHalf);
    final secondAvg = calculateAverageConsumption(secondHalf);

    if (firstAvg == 0 || secondAvg == 0) {
      return ConsumptionTrend.stable;
    }

    final difference = secondAvg - firstAvg;
    final percentChange = (difference / firstAvg) * 100;

    if (percentChange > 5) {
      return ConsumptionTrend.improving; // Consumo melhorou (mais km/l)
    } else if (percentChange < -5) {
      return ConsumptionTrend.worsening; // Consumo piorou (menos km/l)
    } else {
      return ConsumptionTrend.stable;
    }
  }

  /// Calcula eficiência comparada com meta
  EfficiencyComparison compareWithTarget({
    required List<FuelRecordEntity> records,
    required double targetConsumptionKmL,
  }) {
    final actual = calculateAverageConsumption(records);

    if (actual == 0) {
      return EfficiencyComparison(
        actualKmL: 0,
        targetKmL: targetConsumptionKmL,
        percentageDifference: 0,
        isMeetingTarget: false,
      );
    }

    final difference = actual - targetConsumptionKmL;
    final percentDiff = (difference / targetConsumptionKmL) * 100;

    return EfficiencyComparison(
      actualKmL: actual,
      targetKmL: targetConsumptionKmL,
      percentageDifference: percentDiff,
      isMeetingTarget: actual >= targetConsumptionKmL,
    );
  }

  /// Calcula custo por quilômetro rodado
  double calculateCostPerKm(List<FuelRecordEntity> records) {
    if (records.length < 2) return 0.0;

    final sorted = List<FuelRecordEntity>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    var totalCost = 0.0;
    var totalKm = 0.0;

    for (var i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final previous = sorted[i - 1];

      if (current.odometer > 0 && previous.odometer > 0) {
        final km = current.odometer - previous.odometer;

        if (km > 0 && km < 2000) {
          totalKm += km;
          totalCost += current.totalPrice;
        }
      }
    }

    return totalKm > 0 ? totalCost / totalKm : 0.0;
  }

  /// Encontra o abastecimento mais econômico
  FuelRecordEntity? findMostEconomicalRefuel(List<FuelRecordEntity> records) {
    if (records.isEmpty) return null;

    return records.reduce((curr, next) {
      return curr.pricePerLiter < next.pricePerLiter ? curr : next;
    });
  }

  /// Encontra o abastecimento mais caro
  FuelRecordEntity? findMostExpensiveRefuel(List<FuelRecordEntity> records) {
    if (records.isEmpty) return null;

    return records.reduce((curr, next) {
      return curr.pricePerLiter > next.pricePerLiter ? curr : next;
    });
  }

  /// Calcula média de preço por litro em um período
  double calculateAveragePricePerLiter(List<FuelRecordEntity> records) {
    if (records.isEmpty) return 0.0;

    final totalPrice = records.fold<double>(
      0.0,
      (total, record) => total + record.pricePerLiter,
    );

    return totalPrice / records.length;
  }

  /// Agrupa consumo por tipo de combustível
  Map<FuelType, ConsumptionSummary> groupByFuelType(
    List<FuelRecordEntity> records,
  ) {
    final grouped = <FuelType, List<FuelRecordEntity>>{};

    for (final record in records) {
      grouped.putIfAbsent(record.fuelType, () => []).add(record);
    }

    return grouped.map((fuelType, records) {
      final totalCost = records.fold<double>(0.0, (s, r) => s + r.totalPrice);
      final totalLiters = records.fold<double>(0.0, (s, r) => s + r.liters);
      final avgConsumption = calculateAverageConsumption(records);

      return MapEntry(
        fuelType,
        ConsumptionSummary(
          fuelType: fuelType,
          totalCost: totalCost,
          totalLiters: totalLiters,
          averageConsumptionKmL: avgConsumption,
          refuelCount: records.length,
        ),
      );
    });
  }
}

/// Resultado de cálculo de consumo para um período
class ConsumptionResult {
  const ConsumptionResult({
    required this.averageConsumptionKmL,
    required this.totalCost,
    required this.totalLiters,
    required this.totalDistance,
    required this.refuelCount,
    required this.averageCostPerLiter,
    required this.period,
  });

  factory ConsumptionResult.empty() {
    return ConsumptionResult(
      averageConsumptionKmL: 0,
      totalCost: 0,
      totalLiters: 0,
      totalDistance: 0,
      refuelCount: 0,
      averageCostPerLiter: 0,
      period: DatePeriod(start: DateTime.now(), end: DateTime.now()),
    );
  }

  final double averageConsumptionKmL;
  final double totalCost;
  final double totalLiters;
  final double totalDistance;
  final int refuelCount;
  final double averageCostPerLiter;
  final DatePeriod period;

  @override
  String toString() {
    return 'ConsumptionResult('
        'avg: ${averageConsumptionKmL.toStringAsFixed(2)} km/l, '
        'cost: R\$ ${totalCost.toStringAsFixed(2)}, '
        'distance: ${totalDistance.toStringAsFixed(0)} km)';
  }
}

/// Período de datas
class DatePeriod {
  const DatePeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

/// Tendência de consumo
enum ConsumptionTrend { improving, stable, worsening }

/// Comparação de eficiência com meta
class EfficiencyComparison {
  const EfficiencyComparison({
    required this.actualKmL,
    required this.targetKmL,
    required this.percentageDifference,
    required this.isMeetingTarget,
  });

  final double actualKmL;
  final double targetKmL;
  final double percentageDifference;
  final bool isMeetingTarget;

  @override
  String toString() {
    return 'EfficiencyComparison('
        'actual: ${actualKmL.toStringAsFixed(2)} km/l, '
        'target: ${targetKmL.toStringAsFixed(2)} km/l, '
        'diff: ${percentageDifference.toStringAsFixed(1)}%)';
  }
}

/// Resumo de consumo por tipo de combustível
class ConsumptionSummary {
  const ConsumptionSummary({
    required this.fuelType,
    required this.totalCost,
    required this.totalLiters,
    required this.averageConsumptionKmL,
    required this.refuelCount,
  });

  final FuelType fuelType;
  final double totalCost;
  final double totalLiters;
  final double averageConsumptionKmL;
  final int refuelCount;
}
