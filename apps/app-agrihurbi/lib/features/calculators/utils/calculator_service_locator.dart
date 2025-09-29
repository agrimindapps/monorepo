import 'package:get_it/get_it.dart';

import '../domain/entities/calculation_result.dart';
import '../domain/entities/calculator_category.dart';
import '../domain/entities/calculator_entity.dart';
import '../domain/entities/calculator_parameter.dart';
import '../domain/registry/calculator_registry.dart';
import '../domain/services/calculator_engine.dart';
import '../domain/services/calculator_favorites_service.dart';
import '../domain/services/calculator_search_service.dart' as search_service;
import '../domain/services/result_formatter_service.dart';
import '../domain/services/unit_conversion_service.dart';
import '../domain/validation/parameter_validator.dart';
import '../presentation/providers/calculator_provider_simple.dart';

/// Service Locator para facilitar acesso aos serviços de calculadoras
/// 
/// Fornece interface simplificada para acessar todos os serviços
/// relacionados ao sistema de calculadoras
class CalculatorServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  /// Obtém instância do motor de cálculo
  static CalculatorEngine get engine => _getIt<CalculatorEngine>();

  /// Obtém instância do registry de calculadoras
  static CalculatorRegistry get registry => _getIt<CalculatorRegistry>();

  /// Obtém instância do serviço de favoritos
  static CalculatorFavoritesService get favorites => _getIt<CalculatorFavoritesService>();

  /// Obtém instância do provider de calculadoras
  static CalculatorProvider get provider => _getIt<CalculatorProvider>();

  /// Obtém calculadora específica por ID
  static CalculatorEntity? getCalculator(String calculatorId) {
    return registry.getCalculator(calculatorId);
  }

  /// Obtém todas as calculadoras disponíveis
  static List<CalculatorEntity> getAllCalculators() {
    return registry.getAllCalculators();
  }

  /// Executa cálculo usando o motor
  static Future<CalculationEngineResult> calculate({
    required String calculatorId,
    required Map<String, dynamic> parameters,
    Map<String, ParameterUnit>? preferredUnits,
    bool validateOnly = false,
  }) {
    return engine.calculate(
      calculatorId: calculatorId,
      parameters: parameters,
      preferredUnits: preferredUnits,
      validateOnly: validateOnly,
    );
  }

  /// Valida parâmetros de uma calculadora
  static Future<ValidationBatchResult> validateParameters({
    required String calculatorId,
    required Map<String, dynamic> parameters,
  }) {
    return engine.validateParameters(
      calculatorId: calculatorId,
      parameters: parameters,
    );
  }

  /// Converte unidades
  static Future<Map<String, ConversionResult>> convertUnits({
    required Map<String, double> values,
    required Map<String, ParameterUnit> fromUnits,
    required Map<String, ParameterUnit> toUnits,
  }) {
    return engine.convertUnits(
      values: values,
      fromUnits: fromUnits,
      toUnits: toUnits,
    );
  }

  /// Verifica se calculadora é favorita
  static Future<bool> isFavorite(String calculatorId) {
    return favorites.isFavorite(calculatorId);
  }

  /// Adiciona calculadora aos favoritos
  static Future<bool> addToFavorites(String calculatorId) {
    return favorites.addToFavorites(calculatorId);
  }

  /// Remove calculadora dos favoritos
  static Future<bool> removeFromFavorites(String calculatorId) {
    return favorites.removeFromFavorites(calculatorId);
  }

  /// Alterna status de favorito
  static Future<bool> toggleFavorite(String calculatorId) {
    return favorites.toggleFavorite(calculatorId);
  }

  /// Obtém estatísticas dos favoritos
  static Future<FavoritesStats> getFavoritesStats() {
    return favorites.getStats();
  }

  /// Obtém estatísticas do sistema
  static SystemStats getSystemStats() {
    final registryStats = registry.getStats();
    final engineStats = engine.getStats();

    return SystemStats(
      registryStats: registryStats,
      engineStats: engineStats,
      totalCalculators: registryStats.totalRegistered,
      activeSessions: engineStats.activeSessions,
    );
  }

  /// Valida integridade do sistema completo
  static SystemValidationResult validateSystem() {
    final registryValidation = registry.validateRegistry();
    // Note: CalculatorDependencyConfigurator não existe ainda, usando validação mock
    final dependencyValidation = DependencyValidationResult(
      isValid: true,
      errors: [],
      warnings: [],
      registryStats: registry.getStats(),
      engineStats: engine.getStats(),
    );

    return SystemValidationResult(
      isValid: registryValidation.isValid && dependencyValidation.isValid,
      registryValidation: registryValidation,
      dependencyValidation: dependencyValidation,
    );
  }

  /// Busca calculadoras por critérios usando algoritmo otimizado
  static List<CalculatorEntity> searchCalculators(
    String query, {
    CalculatorCategory? category,
    List<String>? tags,
  }) {
    final criteria = search_service.SearchCriteria(
      query: query.trim().isNotEmpty ? query : null,
      category: category,
      tags: tags ?? [],
    );

    return search_service.CalculatorSearchService.optimizedSearch(
      getAllCalculators(),
      criteria,
    );
  }

  /// Obtém sugestões de calculadoras relacionadas baseadas em categoria e tags
  static List<CalculatorEntity> getSuggestions(
    CalculatorEntity calculator, {
    int maxSuggestions = 5,
  }) {
    final criteria = search_service.SearchCriteria(
      category: calculator.category,
      tags: calculator.tags,
    );

    final suggestions = search_service.CalculatorSearchService.optimizedSearch(
      getAllCalculators(),
      criteria,
    );

    // Remove a própria calculadora das sugestões
    suggestions.removeWhere((item) => item.id == calculator.id);

    // Limita o número de sugestões
    return suggestions.take(maxSuggestions).toList();
  }

  /// Formata resultado de cálculo
  static String formatResult(
    CalculationResultValue result, {
    bool showUnit = true,
    int? forcedDecimals,
  }) {
    return ResultFormatterService.formatPrimaryResult(
      result,
      showUnit: showUnit,
      forcedDecimals: forcedDecimals,
    );
  }

  /// Formata resultado científico
  static String formatScientificResult(
    double value,
    String unit, {
    int significantDigits = 3,
    bool useScientificNotation = false,
  }) {
    return ResultFormatterService.formatScientificResult(
      value,
      unit,
      significantDigits: significantDigits,
      useScientificNotation: useScientificNotation,
    );
  }

  /// Formata percentual
  static String formatPercentage(
    double value, {
    int decimals = 1,
    bool includeSymbol = true,
  }) {
    return ResultFormatterService.formatPercentage(
      value,
      decimals: decimals,
      includeSymbol: includeSymbol,
    );
  }

  /// Limpa cache do sistema
  static void clearCache() {
    registry.clearCache();
    engine.cleanupSessions();
  }

  /// Pré-carrega calculadoras frequentes
  static void preloadFrequentCalculators() {
    registry.preloadFrequentCalculators();
  }

  /// Verifica se o sistema está inicializado corretamente
  static bool get isSystemReady {
    try {
      final stats = getSystemStats();
      return stats.totalCalculators > 0 && stats.registryStats.isInitialized;
    } catch (e) {
      return false;
    }
  }
}

/// Estatísticas do sistema completo
class SystemStats {
  final RegistryStats registryStats;
  final CalculatorEngineStats engineStats;
  final int totalCalculators;
  final int activeSessions;

  const SystemStats({
    required this.registryStats,
    required this.engineStats,
    required this.totalCalculators,
    required this.activeSessions,
  });
}

/// Resultado de validação do sistema completo
class SystemValidationResult {
  final bool isValid;
  final RegistryValidationResult registryValidation;
  final DependencyValidationResult dependencyValidation;

  const SystemValidationResult({
    required this.isValid,
    required this.registryValidation,
    required this.dependencyValidation,
  });

  List<String> get allErrors => [
    ...registryValidation.errors,
    ...dependencyValidation.errors,
  ];

  List<String> get allWarnings => [
    ...registryValidation.warnings,
    ...dependencyValidation.warnings,
  ];
}