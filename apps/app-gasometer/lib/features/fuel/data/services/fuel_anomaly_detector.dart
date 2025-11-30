
import '../../domain/entities/fuel_record_entity.dart';

/// Serviço responsável por análise de anomalias em abastecimentos
///
/// Detecta padrões suspeitos, valores fora do normal e possíveis erros,
/// seguindo o princípio Single Responsibility.

class FuelAnomalyDetector {
  FuelAnomalyDetector();

  /// Detecta anomalias em um registro de combustível
  List<FuelAnomaly> detectAnomalies(
    FuelRecordEntity record,
    List<FuelRecordEntity> historicalRecords,
  ) {
    final anomalies = <FuelAnomaly>[];

    // Verifica preço por litro anormal
    final priceAnomaly = _detectPriceAnomaly(record, historicalRecords);
    if (priceAnomaly != null) anomalies.add(priceAnomaly);

    // Verifica consumo anormal
    final consumptionAnomaly = _detectConsumptionAnomaly(
      record,
      historicalRecords,
    );
    if (consumptionAnomaly != null) anomalies.add(consumptionAnomaly);

    // Verifica odômetro suspeito
    final odometerAnomaly = _detectOdometerAnomaly(record, historicalRecords);
    if (odometerAnomaly != null) anomalies.add(odometerAnomaly);

    // Verifica abastecimento duplicado
    final duplicateAnomaly = _detectDuplicate(record, historicalRecords);
    if (duplicateAnomaly != null) anomalies.add(duplicateAnomaly);

    return anomalies;
  }

  /// Detecta preço por litro fora do padrão
  FuelAnomaly? _detectPriceAnomaly(
    FuelRecordEntity record,
    List<FuelRecordEntity> historical,
  ) {
    if (historical.isEmpty) return null;

    // Filtra registros do mesmo tipo de combustível
    final sameFuelType = historical
        .where((r) => r.fuelType == record.fuelType)
        .toList();

    if (sameFuelType.isEmpty) return null;

    // Calcula média e desvio padrão
    final avgPrice =
        sameFuelType.fold<double>(0.0, (sum, r) => sum + r.pricePerLiter) /
        sameFuelType.length;

    final variance =
        sameFuelType.fold<double>(
          0.0,
          (sum, r) =>
              sum +
              ((r.pricePerLiter - avgPrice) * (r.pricePerLiter - avgPrice)),
        ) /
        sameFuelType.length;

    final stdDev = variance > 0 ? variance : 0;

    // Considera anomalia se > 2 desvios padrão
    final threshold = avgPrice + (2 * stdDev);
    final lowerThreshold = avgPrice - (2 * stdDev);

    if (record.pricePerLiter > threshold) {
      return FuelAnomaly(
        type: AnomalyType.unusuallyHighPrice,
        severity: AnomalySeverity.warning,
        message:
            'Preço muito alto: R\$ ${record.pricePerLiter.toStringAsFixed(2)}/L '
            '(média: R\$ ${avgPrice.toStringAsFixed(2)}/L)',
      );
    }

    if (record.pricePerLiter < lowerThreshold && record.pricePerLiter > 0) {
      return FuelAnomaly(
        type: AnomalyType.unusuallyLowPrice,
        severity: AnomalySeverity.info,
        message:
            'Preço muito baixo: R\$ ${record.pricePerLiter.toStringAsFixed(2)}/L '
            '(média: R\$ ${avgPrice.toStringAsFixed(2)}/L)',
      );
    }

    return null;
  }

  /// Detecta consumo fora do padrão
  FuelAnomaly? _detectConsumptionAnomaly(
    FuelRecordEntity record,
    List<FuelRecordEntity> historical,
  ) {
    if (historical.length < 3) return null;

    // Ordena por data
    final sorted = List<FuelRecordEntity>.from(historical)
      ..add(record)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Encontra o registro atual na lista ordenada
    final currentIndex = sorted.indexWhere((r) => r.id == record.id);
    if (currentIndex <= 0) return null;

    final previous = sorted[currentIndex - 1];

    // Calcula consumo (km/l) entre este abastecimento e o anterior
    if (record.odometer > 0 && previous.odometer > 0) {
      final distance = record.odometer - previous.odometer;

      // Distância suspeita
      if (distance <= 0) {
        return const FuelAnomaly(
          type: AnomalyType.invalidOdometer,
          severity: AnomalySeverity.error,
          message: 'Odômetro menor ou igual ao anterior',
        );
      }

      if (distance > 1500) {
        return FuelAnomaly(
          type: AnomalyType.unusuallyHighDistance,
          severity: AnomalySeverity.warning,
          message:
              'Distância muito grande desde último abastecimento: '
              '${distance.toStringAsFixed(0)} km',
        );
      }

      final consumption = distance / record.liters;

      // Consumo muito alto (muito eficiente - suspeito)
      if (consumption > 30) {
        return FuelAnomaly(
          type: AnomalyType.unusuallyHighConsumption,
          severity: AnomalySeverity.warning,
          message: 'Consumo muito alto: ${consumption.toStringAsFixed(1)} km/l',
        );
      }

      // Consumo muito baixo (pouco eficiente - possível problema)
      if (consumption < 3) {
        return FuelAnomaly(
          type: AnomalyType.unusuallyLowConsumption,
          severity: AnomalySeverity.warning,
          message:
              'Consumo muito baixo: ${consumption.toStringAsFixed(1)} km/l',
        );
      }
    }

    return null;
  }

  /// Detecta odômetro suspeito
  FuelAnomaly? _detectOdometerAnomaly(
    FuelRecordEntity record,
    List<FuelRecordEntity> historical,
  ) {
    if (historical.isEmpty || record.odometer == 0) return null;

    // Pega o último registro com odômetro válido
    final lastWithOdometer = historical
        .where((r) => r.odometer > 0)
        .fold<FuelRecordEntity?>(null, (latest, current) {
          if (latest == null) return current;
          return current.date.isAfter(latest.date) ? current : latest;
        });

    if (lastWithOdometer == null) return null;

    // Verifica se odômetro diminuiu
    if (record.odometer < lastWithOdometer.odometer) {
      return const FuelAnomaly(
        type: AnomalyType.invalidOdometer,
        severity: AnomalySeverity.error,
        message: 'Odômetro menor que registro anterior',
      );
    }

    // Verifica se aumento é muito pequeno (< 10km em dias diferentes)
    final daysDiff = record.date.difference(lastWithOdometer.date).inDays;
    final odometerDiff = record.odometer - lastWithOdometer.odometer;

    if (daysDiff > 0 && odometerDiff < 10) {
      return FuelAnomaly(
        type: AnomalyType.unusuallyLowDistance,
        severity: AnomalySeverity.info,
        message:
            'Distância muito pequena: ${odometerDiff.toStringAsFixed(0)} km '
            'em $daysDiff dia(s)',
      );
    }

    return null;
  }

  /// Detecta possível duplicação
  FuelAnomaly? _detectDuplicate(
    FuelRecordEntity record,
    List<FuelRecordEntity> historical,
  ) {
    // Verifica registros similares em intervalo de 5 minutos
    final duplicates = historical.where((r) {
      final timeDiff = record.date.difference(r.date).abs();

      return r.vehicleId == record.vehicleId &&
          r.liters == record.liters &&
          r.totalPrice == record.totalPrice &&
          timeDiff.inMinutes < 5;
    });

    if (duplicates.isNotEmpty) {
      return const FuelAnomaly(
        type: AnomalyType.possibleDuplicate,
        severity: AnomalySeverity.warning,
        message: 'Possível registro duplicado',
      );
    }

    return null;
  }

  /// Calcula score de confiabilidade de um registro (0-100)
  int calculateReliabilityScore(
    FuelRecordEntity record,
    List<FuelRecordEntity> historical,
  ) {
    var score = 100;

    final anomalies = detectAnomalies(record, historical);

    for (final anomaly in anomalies) {
      switch (anomaly.severity) {
        case AnomalySeverity.error:
          score -= 30;
        case AnomalySeverity.warning:
          score -= 15;
        case AnomalySeverity.info:
          score -= 5;
      }
    }

    // Bonus por ter todos os campos preenchidos
    if (record.odometer > 0) {
      score += 5;
    }
    if (record.gasStationName != null && record.gasStationName!.isNotEmpty) {
      score += 5;
    }
    if (record.notes != null && record.notes!.isNotEmpty) {
      score += 5;
    }

    return score.clamp(0, 100);
  }
}

/// Anomalia detectada em abastecimento
class FuelAnomaly {
  const FuelAnomaly({
    required this.type,
    required this.severity,
    required this.message,
  });

  final AnomalyType type;
  final AnomalySeverity severity;
  final String message;

  @override
  String toString() => 'FuelAnomaly($type, $severity): $message';
}

/// Tipos de anomalia
enum AnomalyType {
  unusuallyHighPrice,
  unusuallyLowPrice,
  unusuallyHighConsumption,
  unusuallyLowConsumption,
  unusuallyHighDistance,
  unusuallyLowDistance,
  invalidOdometer,
  possibleDuplicate,
}

/// Severidade da anomalia
enum AnomalySeverity { info, warning, error }
