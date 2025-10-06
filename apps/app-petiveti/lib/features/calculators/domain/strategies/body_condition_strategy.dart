import 'dart:math' as math;

import '../entities/body_condition_input.dart';
import '../entities/body_condition_output.dart';
import 'calculator_strategy.dart';

/// Estratégia de cálculo para Body Condition Score (BCS)
/// Implementa algoritmos veterinários padrão para avaliação corporal
class BodyConditionStrategy extends CalculatorStrategy<BodyConditionInput, BodyConditionOutput> 
    with SpeciesAwareStrategy, WeightAwareStrategy, AgeAwareStrategy {
  
  const BodyConditionStrategy();

  @override
  String get id => 'body_condition_bcs';

  @override
  String get name => 'Calculadora de Condição Corporal (BCS)';

  @override
  String get description => 
      'Avalia estado nutricional através de palpação e observação visual, '
      'gerando score BCS de 1-9 com recomendações personalizadas';

  @override
  String get version => '1.0.0';

  @override
  BodyConditionOutput calculate(BodyConditionInput input) {
    final validationErrors = validateInput(input);
    if (validationErrors.isNotEmpty) {
      throw InvalidInputException(
        'Entrada inválida para cálculo BCS',
        validationErrors,
        errorCode: 'INVALID_BCS_INPUT',
      );
    }

    try {
      final bcsScore = _calculateBcsScore(input);
      final idealWeight = _estimateIdealWeight(input, bcsScore);
      final correctedIdealWeight = _applyCorrections(input, idealWeight);
      return BodyConditionOutputFactory.fromBcsScore(
        bcsScore: bcsScore,
        currentWeight: input.currentWeight,
        species: input.species.code,
        idealWeight: correctedIdealWeight,
        isNeutered: input.isNeutered,
        animalAge: input.animalAge,
        breed: input.animalBreed,
        hasMetabolicConditions: input.hasMetabolicConditions,
      );
    } catch (e) {
      throw CalculationException(
        'Erro durante cálculo BCS: ${e.toString()}',
        errorCode: 'BCS_CALCULATION_ERROR',
        originalError: e,
      );
    }
  }

  @override
  List<String> validateInput(BodyConditionInput input) {
    final errors = <String>[];
    errors.addAll(input.validationErrors);
    if (!supportedSpecies.contains(input.species.code)) {
      errors.add('Espécie ${input.species.displayName} não suportada');
    }
    if (input.animalAge != null && input.animalAge! < 0) {
      errors.add('Idade do animal não pode ser negativa');
    }

    if (input.animalAge != null && input.animalAge! > 300) {
      errors.add('Idade do animal parece excessiva (máximo 25 anos = 300 meses)');
    }
    final minWeight = _getMinimumWeight(input.species.code, input.animalAge);
    if (input.currentWeight < minWeight) {
      errors.add('Peso atual abaixo do mínimo fisiológico para a espécie (${minWeight}kg)');
    }

    return errors;
  }

  /// Calcula o score BCS baseado nos três parâmetros principais
  int _calculateBcsScore(BodyConditionInput input) {
    final ribScore = input.ribPalpation.score;
    final waistScore = input.waistVisibility.score;
    final abdomenScore = input.abdominalProfile.score;
    final weightedAverage = (ribScore * 0.5 + waistScore * 0.3 + abdomenScore * 0.2);
    var bcsScore = weightedAverage.round();
    bcsScore = _applyBcsAdjustments(bcsScore, ribScore, waistScore, abdomenScore);
    return math.max(1, math.min(9, bcsScore));
  }

  /// Aplica ajustes finos baseado em combinações de scores
  int _applyBcsAdjustments(int baseScore, int ribScore, int waistScore, int abdomenScore) {
    var adjustedScore = baseScore;
    if (ribScore == 1 && (waistScore > 2 || abdomenScore > 2)) {
      adjustedScore = math.max(adjustedScore - 1, 1);
    }
    if (ribScore == 5 && (waistScore < 4 || abdomenScore < 4)) {
      adjustedScore = math.min(adjustedScore + 1, 9);
    }
    if ((ribScore - waistScore).abs() > 2 || (ribScore - abdomenScore).abs() > 2) {
      adjustedScore = ((ribScore * 0.6 + baseScore * 0.4).round());
    }
    
    return adjustedScore;
  }

  /// Estima peso ideal baseado no BCS atual e dados do animal
  double _estimateIdealWeight(BodyConditionInput input, int bcsScore) {
    if (input.idealWeight != null) {
      return input.idealWeight!;
    }
    if (bcsScore == 5) {
      return input.currentWeight;
    }
    final weightAdjustmentFactor = _getBcsWeightAdjustmentFactor(bcsScore);
    final estimatedIdealWeight = input.currentWeight / (1 + weightAdjustmentFactor);
    final minWeight = _getMinimumWeight(input.species.code, input.animalAge);
    final maxWeight = _getMaximumWeight(input.species.code, input.animalBreed);
    
    return math.max(minWeight, math.min(maxWeight, estimatedIdealWeight));
  }

  /// Fator de ajuste de peso por BCS
  double _getBcsWeightAdjustmentFactor(int bcsScore) {
    const Map<int, double> adjustmentFactors = {
      1: -0.40, // 40% abaixo do ideal
      2: -0.25, // 25% abaixo do ideal
      3: -0.15, // 15% abaixo do ideal
      4: -0.05, // 5% abaixo do ideal
      5: 0.00,  // peso ideal
      6: 0.10,  // 10% acima do ideal
      7: 0.25,  // 25% acima do ideal
      8: 0.40,  // 40% acima do ideal
      9: 0.60,  // 60% acima do ideal
    };
    
    return adjustmentFactors[bcsScore] ?? 0.0;
  }

  /// Aplica correções por idade, castração, etc.
  double _applyCorrections(BodyConditionInput input, double baseIdealWeight) {
    var correctedWeight = baseIdealWeight;
    if (input.animalAge != null) {
      correctedWeight = applyAgeCorrection(
        correctedWeight, 
        input.animalAge!, 
        input.species.code
      );
    }
    if (input.isNeutered) {
      final adjustment = CalculatorLookupTables.getNeuteredAdjustment(input.species.code);
      correctedWeight *= adjustment;
    }

    return correctedWeight;
  }

  /// Peso mínimo fisiológico por espécie e idade
  double _getMinimumWeight(String species, int? ageInMonths) {
    if (species == 'cat') {
      if (ageInMonths != null && ageInMonths < 6) return 0.5; // filhotes
      return 2.0; // gatos adultos
    } else if (species == 'dog') {
      if (ageInMonths != null && ageInMonths < 6) return 1.0; // filhotes
      return 1.5; // cães adultos pequenos
    }
    return 1.0; // default
  }

  /// Peso máximo razoável por espécie
  double _getMaximumWeight(String species, String? breed) {
    if (species == 'cat') {
      return breed?.toLowerCase().contains('maine') == true ? 12.0 : 8.0;
    } else if (species == 'dog') {
      if (breed != null) {
        final breedLower = breed.toLowerCase();
        if (breedLower.contains('mastiff') || breedLower.contains('great dane')) {
          return 90.0;
        } else if (breedLower.contains('german shepherd') || breedLower.contains('rottweiler')) {
          return 50.0;
        } else if (breedLower.contains('labrador') || breedLower.contains('golden')) {
          return 40.0;
        }
      }
      return 80.0; // máximo genérico para cães
    }
    return 80.0; // default
  }

  @override
  Map<String, dynamic> getSpeciesParameters(String species) {
    const speciesParameters = {
      'dog': {
        'metabolicRate': 1.0,
        'bcsAdjustment': 0.0,
        'weightVariability': 0.15, // 15% de variação aceita
      },
      'cat': {
        'metabolicRate': 0.9,
        'bcsAdjustment': 0.0,
        'weightVariability': 0.12, // 12% de variação aceita
      },
    };

    return speciesParameters[species] ?? speciesParameters['dog']!;
  }

  @override
  List<String> get supportedSpecies => ['dog', 'cat'];

  @override
  double applyAgeCorrection(double baseValue, int ageInMonths, String species) {
    if (ageInMonths < 12) {
      return baseValue * 0.9;
    } else if (ageInMonths > 84) {
      return baseValue * 0.95;
    }
    
    return baseValue; // adultos não precisam correção
  }

  @override
  Map<String, int> get ageRanges => {
    'puppy': 12,      // até 12 meses
    'adult': 84,      // 12-84 meses (7 anos)
    'senior': 120,    // 84-120 meses (7-10 anos)
    'geriatric': 999, // > 120 meses
  };

  @override
  double applyWeightCorrection(double baseValue, double weightKg, String species) {
    final params = getSpeciesParameters(species);
    final variability = params['weightVariability'] as double;
    
    final expectedRange = baseValue * (1 - variability);
    final upperRange = baseValue * (1 + variability);
    
    if (weightKg < expectedRange) {
      return baseValue * 0.95; // reduzir um pouco o ideal
    } else if (weightKg > upperRange) {
      return baseValue * 1.05; // aumentar um pouco o ideal
    }
    
    return baseValue;
  }

  @override
  Map<String, Map<String, double>> get weightLimits => {
    'dog': {'min': 1.0, 'max': 80.0},
    'cat': {'min': 1.5, 'max': 10.0},
  };

  @override
  List<Object?> get props => [...super.props, supportedSpecies];
}