import '../calculators/crops/harvest_timing_calculator.dart';
import '../calculators/crops/planting_density_calculator.dart';
import '../calculators/crops/seed_rate_calculator.dart';
import '../calculators/crops/yield_prediction_calculator.dart';
import '../calculators/irrigation/water_need_calculator.dart';
import '../calculators/livestock/breeding_cycle_calculator.dart';
import '../calculators/livestock/feed_calculator.dart';
import '../calculators/livestock/grazing_calculator.dart';
import '../calculators/livestock/weight_gain_calculator.dart';
import '../calculators/nutrition/compost_calculator.dart';
import '../calculators/nutrition/fertilizer_dosing_calculator.dart';
import '../calculators/nutrition/npk_calculator.dart';
import '../calculators/nutrition/organic_fertilizer_calculator.dart';
import '../calculators/nutrition/soil_ph_calculator.dart';
import '../calculators/soil/drainage_calculator.dart';
import '../calculators/soil/soil_composition_calculator.dart';
import '../entities/calculator_entity.dart';
import '../services/calculator_engine.dart';

/// Registry central para todas as calculadoras do sistema
/// 
/// Implementa padrão Registry para gerenciar instâncias de calculadoras
/// com lazy loading e cache para otimização de performance
class CalculatorRegistry {
  static final CalculatorRegistry _instance = CalculatorRegistry._internal();
  factory CalculatorRegistry() => _instance;
  CalculatorRegistry._internal();

  final Map<String, CalculatorEntity> _calculators = {};
  final Map<String, CalculatorEntity Function()> _calculatorFactories = {};
  bool _initialized = false;

  /// Inicializa o registry com todas as calculadoras
  void initialize() {
    if (_initialized) return;

    _registerCalculatorFactories();
    _initialized = true;
  }

  /// Registra todas as factories das calculadoras
  void _registerCalculatorFactories() {
    // Irrigation Calculators
    _calculatorFactories['water_need_calculator'] = () => const WaterNeedCalculator();

    // Nutrition Calculators
    _calculatorFactories['organic_fertilizer_calculator'] = () => const OrganicFertilizerCalculator();
    _calculatorFactories['npk_calculator'] = () => const NPKCalculator();
    _calculatorFactories['soil_ph_calculator'] = () => const SoilPHCalculator();
    _calculatorFactories['fertilizer_dosing_calculator'] = () => const FertilizerDosingCalculator();
    _calculatorFactories['compost_calculator'] = () => const CompostCalculator();

    // Livestock Calculators
    _calculatorFactories['feed_calculator'] = () => const FeedCalculator();
    _calculatorFactories['breeding_cycle_calculator'] = () => const BreedingCycleCalculator();
    _calculatorFactories['grazing_calculator'] = () => const GrazingCalculator();
    _calculatorFactories['weight_gain_calculator'] = () => const WeightGainCalculator();

    // Crop Calculators
    _calculatorFactories['planting_density_calculator'] = () => const PlantingDensityCalculator();
    _calculatorFactories['harvest_timing_calculator'] = () => const HarvestTimingCalculator();
    _calculatorFactories['seed_rate_calculator'] = () => const SeedRateCalculator();
    _calculatorFactories['yield_prediction_calculator'] = () => const YieldPredictionCalculator();

    // Soil Calculators
    _calculatorFactories['soil_composition_calculator'] = () => const SoilCompositionCalculator();
    _calculatorFactories['drainage_calculator'] = () => const DrainageCalculator();
  }

  /// Obtém calculadora por ID (com lazy loading)
  CalculatorEntity? getCalculator(String calculatorId) {
    if (!_initialized) {
      throw StateError('CalculatorRegistry não foi inicializado. Chame initialize() primeiro.');
    }

    // Verifica se já está no cache
    if (_calculators.containsKey(calculatorId)) {
      return _calculators[calculatorId];
    }

    // Cria nova instância se existe factory
    final factory = _calculatorFactories[calculatorId];
    if (factory != null) {
      final calculator = factory();
      _calculators[calculatorId] = calculator;
      return calculator;
    }

    return null;
  }

  /// Obtém todas as calculadoras disponíveis
  List<CalculatorEntity> getAllCalculators() {
    if (!_initialized) {
      throw StateError('CalculatorRegistry não foi inicializado. Chame initialize() primeiro.');
    }

    final calculators = <CalculatorEntity>[];
    
    for (final calculatorId in _calculatorFactories.keys) {
      final calculator = getCalculator(calculatorId);
      if (calculator != null) {
        calculators.add(calculator);
      }
    }

    return calculators;
  }

  /// Obtém lista de IDs das calculadoras disponíveis
  List<String> getAvailableCalculatorIds() {
    if (!_initialized) {
      throw StateError('CalculatorRegistry não foi inicializado. Chame initialize() primeiro.');
    }

    return _calculatorFactories.keys.toList();
  }

  /// Verifica se uma calculadora está registrada
  bool hasCalculator(String calculatorId) {
    return _calculatorFactories.containsKey(calculatorId);
  }

  /// Registra calculadora customizada dinamicamente
  void registerCustomCalculator(String id, CalculatorEntity Function() factory) {
    _calculatorFactories[id] = factory;
  }

  /// Remove calculadora do registry
  void unregisterCalculator(String calculatorId) {
    _calculatorFactories.remove(calculatorId);
    _calculators.remove(calculatorId);
  }

  /// Limpa cache de instâncias
  void clearCache() {
    _calculators.clear();
  }

  /// Pré-carrega calculadoras mais utilizadas
  void preloadFrequentCalculators() {
    final frequentCalculators = [
      'irrigation_calculator',
      'npk_calculator',
      'feed_calculator',
      'planting_density_calculator',
    ];

    for (final id in frequentCalculators) {
      getCalculator(id);
    }
  }

  /// Obtém estatísticas do registry
  RegistryStats getStats() {
    return RegistryStats(
      totalRegistered: _calculatorFactories.length,
      totalCached: _calculators.length,
      isInitialized: _initialized,
    );
  }

  /// Valida integridade do registry
  RegistryValidationResult validateRegistry() {
    final errors = <String>[];
    final warnings = <String>[];

    if (!_initialized) {
      errors.add('Registry não foi inicializado');
      return RegistryValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }

    // Validar cada calculadora registrada
    for (final entry in _calculatorFactories.entries) {
      final id = entry.key;
      final factory = entry.value;

      try {
        final calculator = factory();
        
        // Validações básicas
        if (calculator.id != id) {
          errors.add('Calculadora $id tem ID inconsistente: ${calculator.id}');
        }

        if (calculator.name.isEmpty) {
          errors.add('Calculadora $id não tem nome definido');
        }

        if (calculator.parameters.isEmpty) {
          warnings.add('Calculadora $id não tem parâmetros definidos');
        }

        // Testar cálculo básico
        try {
          final emptyParams = <String, dynamic>{};
          calculator.calculate(emptyParams);
        } catch (e) {
          // Esperado para parâmetros vazios, apenas verificando se não trava
        }

      } catch (e) {
        errors.add('Erro ao instanciar calculadora $id: $e');
      }
    }

    return RegistryValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Configurador para integração com sistema de DI
class CalculatorDependencyConfigurator {
  /// Configura todas as dependências das calculadoras
  static void configure() {
    // Inicializar registry
    final registry = CalculatorRegistry();
    registry.initialize();

    // Registrar no CalculatorEngine
    final engine = CalculatorEngine();
    final allCalculators = registry.getAllCalculators();
    engine.registerCalculators(allCalculators);

    // Pré-carregar calculadoras frequentes
    registry.preloadFrequentCalculators();
  }

  /// Obtém instância do motor de cálculo configurado
  static CalculatorEngine getConfiguredEngine() {
    final registry = CalculatorRegistry();
    if (!registry.getStats().isInitialized) {
      configure();
    }

    return CalculatorEngine();
  }

  /// Valida configuração completa
  static DependencyValidationResult validateConfiguration() {
    final registryValidation = CalculatorRegistry().validateRegistry();
    final engineStats = CalculatorEngine().getStats();

    final errors = <String>[];
    final warnings = <String>[];

    errors.addAll(registryValidation.errors);
    warnings.addAll(registryValidation.warnings);

    if (engineStats.totalCalculators == 0) {
      errors.add('Nenhuma calculadora registrada no motor');
    }

    if (engineStats.totalCalculators != CalculatorRegistry().getStats().totalRegistered) {
      warnings.add('Número de calculadoras no motor difere do registry');
    }

    return DependencyValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      registryStats: CalculatorRegistry().getStats(),
      engineStats: engineStats,
    );
  }
}

/// Estatísticas do registry
class RegistryStats {
  final int totalRegistered;
  final int totalCached;
  final bool isInitialized;

  const RegistryStats({
    required this.totalRegistered,
    required this.totalCached,
    required this.isInitialized,
  });
}

/// Resultado de validação do registry
class RegistryValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const RegistryValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}

/// Resultado de validação das dependências
class DependencyValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final RegistryStats registryStats;
  final CalculatorEngineStats engineStats;

  const DependencyValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.registryStats,
    required this.engineStats,
  });
}