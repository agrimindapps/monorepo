import 'package:injectable/injectable.dart';

import '../interfaces/calculator_strategy.dart';
import '../strategies/npk_calculation_strategy.dart';

/// Registry moderno para estratégias de calculadoras
/// 
/// Implementa registro automático via DI, seguindo Open/Closed Principle (OCP)
/// e Dependency Inversion Principle (DIP). Elimina hardcoding de estratégias.
@LazySingleton()
class CalculatorStrategyRegistry {
  final List<ICalculatorStrategy> _strategies;
  final Map<String, ICalculatorStrategy> _strategyMap = {};
  bool _initialized = false;

  CalculatorStrategyRegistry(this._strategies);

  /// Inicializa o registry automaticamente via DI
  void initialize() {
    if (_initialized) return;
    _strategyMap.clear();
    for (final strategy in _strategies) {
      _strategyMap[strategy.strategyId] = strategy;
    }

    _initialized = true;
  }

  /// Obtém estratégia por ID
  ICalculatorStrategy? getStrategy(String strategyId) {
    if (!_initialized) {
      initialize();
    }
    return _strategyMap[strategyId];
  }

  /// Lista todas as estratégias disponíveis
  List<ICalculatorStrategy> getAllStrategies() {
    if (!_initialized) {
      initialize();
    }
    return _strategyMap.values.toList();
  }

  /// Lista estratégias por tipo específico
  List<T> getStrategiesByType<T extends ICalculatorStrategy>() {
    if (!_initialized) {
      initialize();
    }
    return _strategyMap.values.whereType<T>().toList();
  }

  /// Lista estratégias de nutrição
  List<INutritionCalculatorStrategy> getNutritionStrategies() {
    return getStrategiesByType<INutritionCalculatorStrategy>();
  }

  /// Lista estratégias de irrigação
  List<IIrrigationCalculatorStrategy> getIrrigationStrategies() {
    return getStrategiesByType<IIrrigationCalculatorStrategy>();
  }

  /// Lista estratégias de culturas
  List<ICropCalculatorStrategy> getCropStrategies() {
    return getStrategiesByType<ICropCalculatorStrategy>();
  }

  /// Lista estratégias de pecuária
  List<ILivestockCalculatorStrategy> getLivestockStrategies() {
    return getStrategiesByType<ILivestockCalculatorStrategy>();
  }

  /// Lista estratégias de solo
  List<ISoilCalculatorStrategy> getSoilStrategies() {
    return getStrategiesByType<ISoilCalculatorStrategy>();
  }

  /// Busca estratégia compatível com inputs fornecidos
  ICalculatorStrategy? findCompatibleStrategy(Map<String, dynamic> inputs) {
    if (!_initialized) {
      initialize();
    }
    for (final strategy in _strategyMap.values) {
      if (strategy.canProcess(inputs)) {
        return strategy;
      }
    }

    return null;
  }

  /// Busca estratégias por culturas suportadas
  List<ICalculatorStrategy> getStrategiesForCrop(String cropType) {
    if (!_initialized) {
      initialize();
    }

    return _strategyMap.values
        .where((strategy) => strategy.metadata.supportedCrops.contains(cropType))
        .toList();
  }

  /// Busca estratégias por região suportada
  List<ICalculatorStrategy> getStrategiesForRegion(String region) {
    if (!_initialized) {
      initialize();
    }

    return _strategyMap.values
        .where((strategy) => strategy.metadata.supportedRegions.contains(region))
        .toList();
  }

  /// Verifica se uma estratégia está registrada
  bool hasStrategy(String strategyId) {
    if (!_initialized) {
      initialize();
    }
    return _strategyMap.containsKey(strategyId);
  }

  /// Obtém estatísticas do registry
  RegistryStatistics getStatistics() {
    if (!_initialized) {
      initialize();
    }

    final typeStats = <String, int>{};
    for (final strategy in _strategyMap.values) {
      final typeName = strategy.runtimeType.toString();
      typeStats[typeName] = (typeStats[typeName] ?? 0) + 1;
    }

    return RegistryStatistics(
      totalStrategies: _strategyMap.length,
      isInitialized: _initialized,
      typeDistribution: typeStats,
      strategyIds: _strategyMap.keys.toList(),
    );
  }

  /// Valida integridade do registry
  RegistryValidationReport validateRegistry() {
    if (!_initialized) {
      initialize();
    }

    final errors = <String>[];
    final warnings = <String>[];
    final seenIds = <String>{};
    for (final strategy in _strategies) {
      if (seenIds.contains(strategy.strategyId)) {
        errors.add('ID duplicado encontrado: ${strategy.strategyId}');
      }
      seenIds.add(strategy.strategyId);
    }
    for (final strategy in _strategyMap.values) {
      if (strategy.strategyName.isEmpty) {
        errors.add('Estratégia ${strategy.strategyId} não tem nome definido');
      }

      if (strategy.description.isEmpty) {
        warnings.add('Estratégia ${strategy.strategyId} não tem descrição');
      }

      if (strategy.parameters.isEmpty) {
        warnings.add('Estratégia ${strategy.strategyId} não define parâmetros');
      }

      if (strategy.metadata.supportedCrops.isEmpty) {
        warnings.add('Estratégia ${strategy.strategyId} não define culturas suportadas');
      }
    }
    final nutritionCount = getNutritionStrategies().length;
    final irrigationCount = getIrrigationStrategies().length;

    if (nutritionCount == 0) {
      warnings.add('Nenhuma estratégia de nutrição registrada');
    }
    if (irrigationCount == 0) {
      warnings.add('Nenhuma estratégia de irrigação registrada');
    }

    return RegistryValidationReport(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      statistics: getStatistics(),
    );
  }

  /// Obtém metadados de todas as estratégias
  List<StrategyMetadata> getAllMetadata() {
    if (!_initialized) {
      initialize();
    }

    return _strategyMap.values.map((strategy) => strategy.metadata).toList();
  }

  /// Limpa cache (para testes ou reinicialização)
  void clearCache() {
    _strategyMap.clear();
    _initialized = false;
  }
}

/// Estatísticas do registry
class RegistryStatistics {
  final int totalStrategies;
  final bool isInitialized;
  final Map<String, int> typeDistribution;
  final List<String> strategyIds;

  const RegistryStatistics({
    required this.totalStrategies,
    required this.isInitialized,
    required this.typeDistribution,
    required this.strategyIds,
  });

  @override
  String toString() {
    return 'RegistryStatistics('
        'total: $totalStrategies, '
        'initialized: $isInitialized, '
        'types: ${typeDistribution.keys.join(', ')}'
        ')';
  }
}

/// Relatório de validação do registry
class RegistryValidationReport {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final RegistryStatistics statistics;

  const RegistryValidationReport({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.statistics,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('RegistryValidationReport:');
    buffer.writeln('  Valid: $isValid');
    
    if (errors.isNotEmpty) {
      buffer.writeln('  Errors:');
      for (final error in errors) {
        buffer.writeln('    - $error');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('  Warnings:');
      for (final warning in warnings) {
        buffer.writeln('    - $warning');
      }
    }
    
    buffer.writeln('  Statistics: $statistics');
    return buffer.toString();
  }
}

/// Módulo DI para configurar automaticamente as estratégias
@module
abstract class CalculatorStrategyModule {
  /// Registra automaticamente todas as estratégias disponíveis
  /// 
  /// Esta função será chamada pelo sistema de DI para criar uma lista
  /// de todas as estratégias implementadas no sistema
  List<ICalculatorStrategy> strategies(
    NPKCalculationStrategy npkStrategy,
  ) => [
    npkStrategy,
  ];
}
