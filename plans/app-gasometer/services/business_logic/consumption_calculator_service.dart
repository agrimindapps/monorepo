// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../database/23_abastecimento_model.dart';

/// Service especializado para cálculos de consumo de combustível
/// 
/// Implementa fórmulas matematicamente corretas e validadas para
/// consumo em diferentes unidades e cenários.
class ConsumptionCalculatorService {
  
  /// Calcula consumo em km/L (quilômetros por litro)
  /// 
  /// Fórmula: distância percorrida / litros consumidos
  /// 
  /// [odometroAtual] Quilometragem atual do veículo
  /// [odometroAnterior] Quilometragem do abastecimento anterior
  /// [litros] Quantidade de combustível abastecida
  /// 
  /// Retorna null se não for possível calcular (dados inválidos)
  static double? calculateConsumptionKmL(
    double odometroAtual,
    double odometroAnterior, 
    double litros,
  ) {
    // Validação básica
    if (litros <= 0) {
      if (kDebugMode) {
        debugPrint('ConsumptionCalculator: Litros inválidos ($litros)');
      }
      return null;
    }
    
    final distancia = odometroAtual - odometroAnterior;
    
    if (distancia <= 0) {
      if (kDebugMode) {
        debugPrint('ConsumptionCalculator: Distância inválida ($distancia km)');
      }
      return null;
    }
    
    final consumo = distancia / litros;
    
    if (kDebugMode) {
      debugPrint('ConsumptionCalculator: ${distancia.toStringAsFixed(1)}km / '
          '${litros.toStringAsFixed(2)}L = ${consumo.toStringAsFixed(2)} km/L');
    }
    
    return consumo;
  }
  
  /// Calcula consumo em L/100km (litros por 100 quilômetros)
  /// 
  /// Fórmula: (litros consumidos / distância percorrida) * 100
  /// 
  /// Esta é a unidade padrão europeia e mais intuitiva para comparação
  static double? calculateConsumptionL100km(
    double odometroAtual,
    double odometroAnterior, 
    double litros,
  ) {
    final kmL = calculateConsumptionKmL(odometroAtual, odometroAnterior, litros);
    
    if (kmL == null || kmL <= 0) {
      return null;
    }
    
    // Conversão: km/L para L/100km
    final l100km = 100 / kmL;
    
    if (kDebugMode) {
      debugPrint('ConsumptionCalculator: ${kmL.toStringAsFixed(2)} km/L = '
          '${l100km.toStringAsFixed(2)} L/100km');
    }
    
    return l100km;
  }
  
  /// Calcula consumo médio de uma lista de abastecimentos
  /// 
  /// Usa método ponderado pela distância para maior precisão
  static ConsumptionSummary calculateAverageConsumption(
    List<AbastecimentoCar> abastecimentos,
  ) {
    if (abastecimentos.length < 2) {
      return ConsumptionSummary.empty();
    }
    
    // Ordena por data para garantir sequência correta
    final sorted = List<AbastecimentoCar>.from(abastecimentos)
      ..sort((a, b) => a.data.compareTo(b.data));
    
    double totalDistancia = 0;
    double totalLitros = 0;
    final consumos = <double>[];
    int validCalculations = 0;
    
    for (int i = 1; i < sorted.length; i++) {
      final anterior = sorted[i - 1];
      final atual = sorted[i];
      
      final consumoKmL = calculateConsumptionKmL(
        atual.odometro,
        anterior.odometro,
        atual.litros,
      );
      
      if (consumoKmL != null && consumoKmL > 0) {
        final distancia = atual.odometro - anterior.odometro;
        
        totalDistancia += distancia;
        totalLitros += atual.litros;
        consumos.add(consumoKmL);
        validCalculations++;
      }
    }
    
    if (validCalculations == 0) {
      return ConsumptionSummary.empty();
    }
    
    // Consumo médio ponderado pela distância
    final consumoMedioPonderado = totalDistancia / totalLitros;
    
    // Estatísticas adicionais
    consumos.sort();
    final consumoMinimo = consumos.first;
    final consumoMaximo = consumos.last;
    final consumoMediano = consumos.length.isOdd
        ? consumos[consumos.length ~/ 2]
        : (consumos[consumos.length ~/ 2 - 1] + consumos[consumos.length ~/ 2]) / 2;
    
    // Desvio padrão
    final media = consumos.reduce((a, b) => a + b) / consumos.length;
    final variancia = consumos.map((c) => pow(c - media, 2)).reduce((a, b) => a + b) / consumos.length;
    final desvioPadrao = sqrt(variancia);
    
    return ConsumptionSummary(
      isValid: true,
      averageKmL: consumoMedioPonderado,
      averageL100km: 100 / consumoMedioPonderado,
      minKmL: consumoMinimo,
      maxKmL: consumoMaximo,
      medianKmL: consumoMediano,
      standardDeviation: desvioPadrao,
      totalDistance: totalDistancia,
      totalLiters: totalLitros,
      validCalculations: validCalculations,
      totalCalculations: sorted.length - 1,
    );
  }
  
  /// Calcula autonomia estimada com base no consumo atual
  static double? calculateEstimatedRange(
    double consumoMedioKmL,
    double litrosNoTanque,
  ) {
    if (consumoMedioKmL <= 0 || litrosNoTanque <= 0) {
      return null;
    }
    
    return consumoMedioKmL * litrosNoTanque;
  }
  
  /// Calcula custo por quilômetro
  static double? calculateCostPerKm(
    double distanciaPercorrida,
    double valorTotalCombustivel,
  ) {
    if (distanciaPercorrida <= 0 || valorTotalCombustivel <= 0) {
      return null;
    }
    
    return valorTotalCombustivel / distanciaPercorrida;
  }
  
  /// Calcula projeção de consumo para uma distância específica
  static FuelConsumptionProjection projectFuelConsumption(
    double consumoMedioKmL,
    double distanciaDesejada,
    double precoMedioPorLitro,
  ) {
    if (consumoMedioKmL <= 0 || distanciaDesejada <= 0 || precoMedioPorLitro <= 0) {
      return FuelConsumptionProjection.invalid();
    }
    
    final litrosNecessarios = distanciaDesejada / consumoMedioKmL;
    final custoEstimado = litrosNecessarios * precoMedioPorLitro;
    
    return FuelConsumptionProjection(
      isValid: true,
      distanceKm: distanciaDesejada,
      requiredLiters: litrosNecessarios,
      estimatedCost: custoEstimado,
      costPerKm: custoEstimado / distanciaDesejada,
      consumptionKmL: consumoMedioKmL,
      fuelPricePerLiter: precoMedioPorLitro,
    );
  }
  
  /// Detecta anomalias no consumo
  static List<ConsumptionAnomaly> detectConsumptionAnomalies(
    List<AbastecimentoCar> abastecimentos,
    {double tolerancePercentage = 30.0}
  ) {
    final summary = calculateAverageConsumption(abastecimentos);
    if (!summary.isValid) {
      return [];
    }
    
    final anomalies = <ConsumptionAnomaly>[];
    final sorted = List<AbastecimentoCar>.from(abastecimentos)
      ..sort((a, b) => a.data.compareTo(b.data));
    
    for (int i = 1; i < sorted.length; i++) {
      final anterior = sorted[i - 1];
      final atual = sorted[i];
      
      final consumo = calculateConsumptionKmL(
        atual.odometro,
        anterior.odometro,
        atual.litros,
      );
      
      if (consumo != null) {
        final desvioPercentual = ((consumo - summary.averageKmL).abs() / summary.averageKmL) * 100;
        
        if (desvioPercentual > tolerancePercentage) {
          anomalies.add(ConsumptionAnomaly(
            abastecimento: atual,
            calculatedConsumption: consumo,
            averageConsumption: summary.averageKmL,
            deviationPercentage: desvioPercentual,
            type: consumo > summary.averageKmL 
                ? AnomalyType.unusuallyHigh 
                : AnomalyType.unusuallyLow,
          ));
        }
      }
    }
    
    return anomalies;
  }
  
  /// Valida se um cálculo de consumo é realista
  static bool isConsumptionRealistic(double consumoKmL) {
    const minRealisticConsumption = 3.0;  // km/L
    const maxRealisticConsumption = 30.0; // km/L
    
    return consumoKmL >= minRealisticConsumption && 
           consumoKmL <= maxRealisticConsumption;
  }
  
  /// Converte entre diferentes unidades de consumo
  static double convertKmLtoL100km(double kmL) => 100 / kmL;
  static double convertL100kmToKmL(double l100km) => 100 / l100km;
  static double convertKmLtoMilesPerGallon(double kmL) => kmL * 2.352; // Aproximação
  static double convertMilesPerGallonToKmL(double mpg) => mpg / 2.352;
}

/// Resumo estatístico do consumo
class ConsumptionSummary {
  final bool isValid;
  final double averageKmL;
  final double averageL100km;
  final double minKmL;
  final double maxKmL;
  final double medianKmL;
  final double standardDeviation;
  final double totalDistance;
  final double totalLiters;
  final int validCalculations;
  final int totalCalculations;
  
  const ConsumptionSummary({
    required this.isValid,
    required this.averageKmL,
    required this.averageL100km,
    required this.minKmL,
    required this.maxKmL,
    required this.medianKmL,
    required this.standardDeviation,
    required this.totalDistance,
    required this.totalLiters,
    required this.validCalculations,
    required this.totalCalculations,
  });
  
  factory ConsumptionSummary.empty() {
    return const ConsumptionSummary(
      isValid: false,
      averageKmL: 0,
      averageL100km: 0,
      minKmL: 0,
      maxKmL: 0,
      medianKmL: 0,
      standardDeviation: 0,
      totalDistance: 0,
      totalLiters: 0,
      validCalculations: 0,
      totalCalculations: 0,
    );
  }
  
  /// Percentual de cálculos válidos
  double get validCalculationPercentage => 
      totalCalculations > 0 ? (validCalculations / totalCalculations) * 100 : 0;
  
  /// Classificação da consistência dos dados
  String get consistencyRating {
    if (!isValid) return 'Sem dados';
    if (validCalculationPercentage >= 90) return 'Excelente';
    if (validCalculationPercentage >= 70) return 'Bom';
    if (validCalculationPercentage >= 50) return 'Regular';
    return 'Ruim';
  }
  
  @override
  String toString() => 'ConsumptionSummary(${averageKmL.toStringAsFixed(2)} km/L, '
      '$validCalculations/$totalCalculations válidos)';
}

/// Projeção de consumo para viagem
class FuelConsumptionProjection {
  final bool isValid;
  final double distanceKm;
  final double requiredLiters;
  final double estimatedCost;
  final double costPerKm;
  final double consumptionKmL;
  final double fuelPricePerLiter;
  
  const FuelConsumptionProjection({
    required this.isValid,
    required this.distanceKm,
    required this.requiredLiters,
    required this.estimatedCost,
    required this.costPerKm,
    required this.consumptionKmL,
    required this.fuelPricePerLiter,
  });
  
  factory FuelConsumptionProjection.invalid() {
    return const FuelConsumptionProjection(
      isValid: false,
      distanceKm: 0,
      requiredLiters: 0,
      estimatedCost: 0,
      costPerKm: 0,
      consumptionKmL: 0,
      fuelPricePerLiter: 0,
    );
  }
  
  @override
  String toString() => isValid 
      ? 'Projeção: ${distanceKm.toStringAsFixed(0)}km = ${requiredLiters.toStringAsFixed(1)}L (R\$ ${estimatedCost.toStringAsFixed(2)})'
      : 'Projeção inválida';
}

/// Anomalia detectada no consumo
class ConsumptionAnomaly {
  final AbastecimentoCar abastecimento;
  final double calculatedConsumption;
  final double averageConsumption;
  final double deviationPercentage;
  final AnomalyType type;
  
  const ConsumptionAnomaly({
    required this.abastecimento,
    required this.calculatedConsumption,
    required this.averageConsumption,
    required this.deviationPercentage,
    required this.type,
  });
  
  String get description {
    final direction = type == AnomalyType.unusuallyHigh ? 'alto' : 'baixo';
    return 'Consumo $direction: ${calculatedConsumption.toStringAsFixed(2)} km/L '
        '(${deviationPercentage.toStringAsFixed(1)}% de desvio da média)';
  }
  
  @override
  String toString() => 'ConsumptionAnomaly(${calculatedConsumption.toStringAsFixed(2)} km/L, '
      '${deviationPercentage.toStringAsFixed(1)}% desvio)';
}

enum AnomalyType {
  unusuallyHigh,
  unusuallyLow,
}