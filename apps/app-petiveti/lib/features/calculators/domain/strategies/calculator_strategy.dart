import 'package:core/core.dart' show Equatable;
import '../entities/calculation_result.dart';

/// Interface base para Strategy Pattern das calculadoras
/// Permite diferentes implementações de cálculo seguindo Clean Architecture
abstract class CalculatorStrategy<TInput, TOutput extends CalculationResult>
    extends Equatable {
  const CalculatorStrategy();

  /// Identificador único da estratégia
  String get id;

  /// Nome da calculadora
  String get name;

  /// Descrição da funcionalidade
  String get description;

  /// Versão da implementação
  String get version;

  /// Executa o cálculo principal
  ///
  /// [input] - Dados de entrada tipados
  /// Retorna resultado tipado ou lança exceção
  TOutput calculate(TInput input);

  /// Valida entrada antes do cálculo
  ///
  /// [input] - Dados de entrada para validação
  /// Retorna lista de erros (vazia se válido)
  List<String> validateInput(TInput input);

  /// Verifica se entrada é válida
  bool isInputValid(TInput input) => validateInput(input).isEmpty;

  @override
  List<Object?> get props => [id, version];
}

/// Mixin para estratégias que suportam diferentes espécies
mixin SpeciesAwareStrategy {
  /// Obtém parâmetros específicos da espécie
  Map<String, dynamic> getSpeciesParameters(String species);

  /// Lista de espécies suportadas
  List<String> get supportedSpecies;
}

/// Mixin para estratégias que consideram idade
mixin AgeAwareStrategy {
  /// Aplica correções baseadas na idade
  double applyAgeCorrection(double baseValue, int ageInMonths, String species);

  /// Define faixas etárias consideradas
  Map<String, int> get ageRanges;
}

/// Mixin para estratégias que consideram peso
mixin WeightAwareStrategy {
  /// Aplica correções baseadas no peso
  double applyWeightCorrection(
    double baseValue,
    double weightKg,
    String species,
  );

  /// Limites de peso considerados normais
  Map<String, Map<String, double>> get weightLimits; // species -> {min, max}
}

/// Exception específica para erros de cálculo
class CalculationException implements Exception {
  final String message;
  final String? errorCode;
  final dynamic originalError;

  const CalculationException(
    this.message, {
    this.errorCode,
    this.originalError,
  });

  @override
  String toString() => 'CalculationException: $message';
}

/// Exception para entradas inválidas
class InvalidInputException extends CalculationException {
  final List<String> validationErrors;

  const InvalidInputException(
    super.message,
    this.validationErrors, {
    super.errorCode,
  });

  @override
  String toString() =>
      'InvalidInputException: $message\nErrors: ${validationErrors.join(', ')}';
}

/// Helper class para lookup tables comuns nas calculadoras
class CalculatorLookupTables {
  /// Tabela de pesos ideais por raça (aproximados)
  static const Map<String, Map<String, double>> idealWeightRanges = {
    'dog': {
      'chihuahua': 2.5,
      'yorkshire': 3.0,
      'pomeranian': 3.0,
      'maltese': 3.5,
      'poodle_toy': 4.0,
      'jack_russell': 7.0,
      'cocker_spaniel': 15.0,
      'beagle': 25.0,
      'border_collie': 25.0,
      'golden_retriever': 30.0,
      'labrador': 32.0,
      'german_shepherd': 35.0,
      'rottweiler': 45.0,
      'mastiff': 70.0,
      'default': 25.0, // peso médio genérico
    },
    'cat': {
      'domestic_shorthair': 4.5,
      'persian': 5.0,
      'siamese': 4.0,
      'maine_coon': 7.0,
      'ragdoll': 6.0,
      'british_shorthair': 5.5,
      'default': 4.5, // peso médio genérico
    },
  };

  /// Multiplicadores metabólicos por idade (meses)
  static const Map<int, double> ageMetabolicMultipliers = {
    3: 2.5, // filhotes muito jovens
    6: 2.0, // filhotes
    12: 1.8, // juvenis
    24: 1.6, // adultos jovens
    60: 1.4, // adultos
    84: 1.2, // seniores
    120: 1.0, // idosos
  };

  /// Fatores de correção para animais castrados
  static const Map<String, double> neuteredAdjustmentFactors = {
    'dog': 0.9, // redução de 10% no metabolismo
    'cat': 0.85, // redução de 15% no metabolismo
  };

  /// BCS para classificação de peso lookup
  static const Map<int, String> bcsClassifications = {
    1: 'Extremamente Magro',
    2: 'Muito Magro',
    3: 'Magro',
    4: 'Abaixo do Ideal',
    5: 'Ideal',
    6: 'Acima do Ideal',
    7: 'Sobrepeso',
    8: 'Obeso',
    9: 'Extremamente Obeso',
  };

  /// Percentual de gordura corporal por BCS
  static const Map<int, double> bcsBodyFatPercentage = {
    1: 5.0,
    2: 10.0,
    3: 15.0,
    4: 20.0,
    5: 25.0,
    6: 30.0,
    7: 35.0,
    8: 40.0,
    9: 45.0,
  };

  /// Busca peso ideal por espécie e raça
  static double getIdealWeight(String species, String? breed) {
    final speciesTable = idealWeightRanges[species];
    if (speciesTable == null) return 25.0; // default genérico

    return speciesTable[breed?.toLowerCase()] ?? speciesTable['default']!;
  }

  /// Busca multiplicador metabólico por idade
  static double getAgeMetabolicMultiplier(int ageInMonths) {
    final sortedAges = ageMetabolicMultipliers.keys.toList()..sort();

    for (final age in sortedAges) {
      if (ageInMonths <= age) {
        return ageMetabolicMultipliers[age]!;
      }
    }

    return 1.0; // default para idades muito avançadas
  }

  /// Busca fator de ajuste para castrados
  static double getNeuteredAdjustment(String species) {
    return neuteredAdjustmentFactors[species] ?? 0.9;
  }

  /// Busca classificação BCS
  static String getBcsClassification(int score) {
    return bcsClassifications[score] ?? 'Não Classificado';
  }

  /// Busca percentual de gordura corporal
  static double getBodyFatPercentage(int bcsScore) {
    return bcsBodyFatPercentage[bcsScore] ?? 25.0;
  }
}
