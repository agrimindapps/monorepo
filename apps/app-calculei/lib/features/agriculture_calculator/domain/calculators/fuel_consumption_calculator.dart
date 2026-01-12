/// Calculadora de Consumo de Combustível - Máquinas Agrícolas
/// Calcula consumo de diesel baseado em potência, carga e tipo de operação
library;

/// Tipos de operação agrícola
enum OperationType {
  soilPreparation, // Preparo do Solo
  planting, // Plantio
  spraying, // Pulverização
  harvesting, // Colheita
  transport, // Transporte
}

/// Fatores de carga da máquina
enum LoadFactor {
  light, // Leve (40%)
  medium, // Médio (60%)
  heavy, // Pesado (80%)
  maximum, // Máximo (100%)
}

class FuelConsumptionResult {
  /// Potência do trator (HP)
  final double tractorPower;

  /// Fator de carga
  final LoadFactor loadFactor;

  /// Tipo de operação
  final OperationType operationType;

  /// Horas trabalhadas
  final double hoursWorked;

  /// Área trabalhada (ha)
  final double areaWorked;

  /// Consumo por hora (L/h)
  final double consumptionPerHour;

  /// Consumo por hectare (L/ha)
  final double consumptionPerHectare;

  /// Consumo total (L)
  final double totalConsumption;

  /// Custo estimado (R$)
  final double estimatedCost;

  /// Capacidade de campo (ha/h)
  final double fieldCapacity;

  /// Recomendações de uso
  final List<String> recommendations;

  const FuelConsumptionResult({
    required this.tractorPower,
    required this.loadFactor,
    required this.operationType,
    required this.hoursWorked,
    required this.areaWorked,
    required this.consumptionPerHour,
    required this.consumptionPerHectare,
    required this.totalConsumption,
    required this.estimatedCost,
    required this.fieldCapacity,
    required this.recommendations,
  });
}

class FuelConsumptionCalculator {
  // Preço médio do diesel (R$/L) - pode ser atualizado
  static const double defaultDieselPrice = 5.50;

  // Consumo base: 0.15 L/HP/h (diesel)
  static const double baseConsumptionFactor = 0.15;

  // Fatores de carga (multiplicadores do consumo base)
  static const Map<LoadFactor, double> loadFactorMultipliers = {
    LoadFactor.light: 0.4,
    LoadFactor.medium: 0.6,
    LoadFactor.heavy: 0.8,
    LoadFactor.maximum: 1.0,
  };

  // Capacidade de campo por tipo de operação (ha/h)
  // Valores médios para trator de 100 HP
  static const Map<OperationType, double> fieldCapacityBase = {
    OperationType.soilPreparation: 0.8, // Mais lento
    OperationType.planting: 1.2,
    OperationType.spraying: 2.5, // Mais rápido
    OperationType.harvesting: 1.0,
    OperationType.transport: 0.0, // Não usa hectare
  };

  static const Map<LoadFactor, String> loadFactorNames = {
    LoadFactor.light: 'Leve (40%)',
    LoadFactor.medium: 'Médio (60%)',
    LoadFactor.heavy: 'Pesado (80%)',
    LoadFactor.maximum: 'Máximo (100%)',
  };

  static const Map<OperationType, String> operationTypeNames = {
    OperationType.soilPreparation: 'Preparo do Solo',
    OperationType.planting: 'Plantio',
    OperationType.spraying: 'Pulverização',
    OperationType.harvesting: 'Colheita',
    OperationType.transport: 'Transporte',
  };

  /// Calcula consumo de combustível
  static FuelConsumptionResult calculate({
    required double tractorPowerHP,
    required LoadFactor loadFactor,
    required OperationType operationType,
    required double hoursWorked,
    double? areaWorked,
    double? fuelPricePerLiter,
  }) {
    // Validações
    if (tractorPowerHP <= 0 || tractorPowerHP > 500) {
      throw ArgumentError('Potência deve estar entre 1 e 500 HP');
    }
    if (hoursWorked <= 0 || hoursWorked > 1000) {
      throw ArgumentError('Horas trabalhadas deve estar entre 0 e 1000');
    }
    if (areaWorked != null && (areaWorked < 0 || areaWorked > 10000)) {
      throw ArgumentError('Área trabalhada deve estar entre 0 e 10000 ha');
    }

    // 1. Consumo base por hora (L/h)
    final baseConsumption = tractorPowerHP * baseConsumptionFactor;

    // 2. Consumo real por hora (base × fator de carga)
    final loadMultiplier = loadFactorMultipliers[loadFactor]!;
    final consumptionPerHour = baseConsumption * loadMultiplier;

    // 3. Capacidade de campo (ha/h)
    // Ajustada pela potência do trator (referência: 100 HP)
    double fieldCapacity = 0;
    if (operationType != OperationType.transport) {
      final baseCapacity = fieldCapacityBase[operationType]!;
      // Ajuste proporcional à potência (100 HP = 100%)
      final powerFactor = tractorPowerHP / 100.0;
      fieldCapacity = baseCapacity * powerFactor;
    }

    // 4. Consumo por hectare (L/ha)
    double consumptionPerHectare = 0;
    if (fieldCapacity > 0) {
      consumptionPerHectare = consumptionPerHour / fieldCapacity;
    }

    // 5. Consumo total
    double totalConsumption;
    double effectiveArea = areaWorked ?? 0;

    if (operationType == OperationType.transport || areaWorked == null) {
      // Para transporte ou quando área não informada, usa horas
      totalConsumption = consumptionPerHour * hoursWorked;
      // Estima área baseada em capacidade de campo
      if (fieldCapacity > 0) {
        effectiveArea = hoursWorked * fieldCapacity;
      }
    } else {
      // Para operações de campo, usa área trabalhada
      totalConsumption = consumptionPerHectare * areaWorked;
      effectiveArea = areaWorked;
    }

    // 6. Custo estimado
    final pricePerLiter = fuelPricePerLiter ?? defaultDieselPrice;
    final estimatedCost = totalConsumption * pricePerLiter;

    // 7. Recomendações
    final recommendations = _generateRecommendations(
      tractorPowerHP,
      loadFactor,
      operationType,
      consumptionPerHour,
    );

    return FuelConsumptionResult(
      tractorPower: tractorPowerHP,
      loadFactor: loadFactor,
      operationType: operationType,
      hoursWorked: hoursWorked,
      areaWorked: effectiveArea,
      consumptionPerHour: consumptionPerHour,
      consumptionPerHectare: consumptionPerHectare,
      totalConsumption: totalConsumption,
      estimatedCost: estimatedCost,
      fieldCapacity: fieldCapacity,
      recommendations: recommendations,
    );
  }

  /// Gera recomendações baseadas nos parâmetros
  static List<String> _generateRecommendations(
    double power,
    LoadFactor loadFactor,
    OperationType operationType,
    double consumptionPerHour,
  ) {
    final recommendations = <String>[];

    // Recomendação sobre fator de carga
    if (loadFactor == LoadFactor.light) {
      recommendations.add(
        '💡 Fator de carga baixo. Considere utilizar trator com menor potência para melhor eficiência.',
      );
    } else if (loadFactor == LoadFactor.maximum) {
      recommendations.add(
        '⚠️ Trabalhando em carga máxima. Monitore a temperatura do motor e faça manutenções preventivas.',
      );
    }

    // Recomendação sobre consumo
    if (consumptionPerHour > 20) {
      recommendations.add(
        '⛽ Alto consumo detectado (${consumptionPerHour.toStringAsFixed(1)} L/h). Verifique ajustes do motor e calibragem.',
      );
    }

    // Recomendação sobre tipo de operação
    switch (operationType) {
      case OperationType.soilPreparation:
        recommendations.add(
          '🚜 Preparo de solo exige maior potência. Regule profundidade para otimizar consumo.',
        );
        break;
      case OperationType.spraying:
        recommendations.add(
          '💧 Pulverização permite velocidades maiores. Aproveite para maximizar área/hora.',
        );
        break;
      case OperationType.harvesting:
        recommendations.add(
          '🌾 Colheita: velocidade adequada evita perdas e reduz consumo.',
        );
        break;
      case OperationType.transport:
        recommendations.add(
          '🚚 Transporte: evite sobrecargas e mantenha velocidade constante.',
        );
        break;
      default:
        break;
    }

    // Dica geral de economia
    recommendations.add(
      '✅ Manutenção regular reduz consumo em até 15%. Verifique filtros, óleo e pressão dos pneus.',
    );

    return recommendations;
  }

  /// Retorna nome do fator de carga
  static String getLoadFactorName(LoadFactor factor) {
    return loadFactorNames[factor] ?? '';
  }

  /// Retorna nome do tipo de operação
  static String getOperationTypeName(OperationType type) {
    return operationTypeNames[type] ?? '';
  }
}
