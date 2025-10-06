import 'dart:math' as math;

import '../entities/medication_data.dart';
import '../entities/medication_dosage_input.dart';
import '../entities/medication_dosage_output.dart';

/// Resultado de validação de dosagem com múltiplas verificações cruzadas
class ValidationResult {
  final bool isValid;
  final double confidenceScore;
  final List<String> warnings;
  final List<String> criticalErrors;
  final Map<String, ValidationCheck> validationChecks;
  final bool requiresDoubleConfirmation;
  final String? recommendedAction;

  const ValidationResult({
    required this.isValid,
    required this.confidenceScore,
    required this.warnings,
    required this.criticalErrors,
    required this.validationChecks,
    required this.requiresDoubleConfirmation,
    this.recommendedAction,
  });

  bool get isCritical => criticalErrors.isNotEmpty || confidenceScore < 0.7;
  bool get isHighRisk => requiresDoubleConfirmation || confidenceScore < 0.8;
}

class ValidationCheck {
  final String name;
  final bool passed;
  final double score;
  final String? message;
  final DateTime timestamp;

  ValidationCheck({
    required this.name,
    required this.passed,
    required this.score,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Serviço de validação cruzada para cálculos de dosagem médica veterinária
/// 
/// Implementa múltiplos algoritmos de validação independentes para garantir
/// segurança máxima nos cálculos médicos que podem afetar vida animal.
class DosageValidationService {
  DosageValidationService._(); // Construtor privado para classe utilitária

  static const double minimumConfidenceScore = 0.85;
  static const double criticalDoseThreshold = 0.7; // 70% do limite tóxico
  static const double minimumSafetyMargin = 30.0; // 30% de margem mínima

  /// Validação completa com múltiplos algoritmos cruzados
  static ValidationResult validateCalculation(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final validationChecks = <String, ValidationCheck>{};
    final warnings = <String>[];
    final criticalErrors = <String>[];
    final algorithmValidation = _validateWithMultipleAlgorithms(input, output, medication);
    validationChecks['algorithm_cross_check'] = algorithmValidation;
    final speciesValidation = _validateSpeciesLimits(input, output, medication);
    validationChecks['species_limits'] = speciesValidation;
    final referenceValidation = _validateAgainstVeterinaryReferences(input, output, medication);
    validationChecks['veterinary_references'] = referenceValidation;
    final safetyMarginValidation = _validateSafetyMargin(input, output, medication);
    validationChecks['safety_margin'] = safetyMarginValidation;
    final toxicityValidation = _validateToxicityProximity(input, output, medication);
    validationChecks['toxicity_proximity'] = toxicityValidation;
    final interactionValidation = _validateDrugInteractions(input, output, medication);
    validationChecks['drug_interactions'] = interactionValidation;
    final conditionsValidation = _validateSpecialConditions(input, output, medication);
    validationChecks['special_conditions'] = conditionsValidation;
    for (final check in validationChecks.values) {
      if (!check.passed) {
        if (check.score < 0.5) {
          criticalErrors.add(check.message ?? 'Falha crítica na validação ${check.name}');
        } else {
          warnings.add(check.message ?? 'Aviso na validação ${check.name}');
        }
      }
    }
    final confidenceScore = _calculateConfidenceScore(validationChecks);
    final requiresDoubleConfirmation = _requiresDoubleConfirmation(
      confidenceScore, 
      criticalErrors, 
      output, 
      medication
    );
    String? recommendedAction;
    if (criticalErrors.isNotEmpty) {
      recommendedAction = 'NÃO ADMINISTRAR - Consultar veterinário especialista imediatamente';
    } else if (requiresDoubleConfirmation) {
      recommendedAction = 'Confirmação dupla necessária antes da administração';
    } else if (warnings.isNotEmpty) {
      recommendedAction = 'Monitoramento cuidadoso durante administração';
    }

    return ValidationResult(
      isValid: criticalErrors.isEmpty && confidenceScore >= minimumConfidenceScore,
      confidenceScore: confidenceScore,
      warnings: warnings,
      criticalErrors: criticalErrors,
      validationChecks: validationChecks,
      requiresDoubleConfirmation: requiresDoubleConfirmation,
      recommendedAction: recommendedAction,
    );
  }

  /// Pre-validação para identificar riscos antes do cálculo completo
  static ValidationResult preValidate(MedicationDosageInput input) {
    final validationChecks = <String, ValidationCheck>{};
    final warnings = <String>[];
    final criticalErrors = <String>[];
    if (input.weight < 0.5 || input.weight > 80.0) {
      criticalErrors.add('Peso fora da faixa segura: ${input.weight}kg');
      validationChecks['weight_range'] = ValidationCheck(
        name: 'Faixa de peso',
        passed: false,
        score: 0.0,
        message: 'Peso extremo requer validação veterinária presencial',
      );
    } else {
      validationChecks['weight_range'] = ValidationCheck(
        name: 'Faixa de peso',
        passed: true,
        score: 1.0,
      );
    }
    final criticalConditions = input.specialConditions.where((condition) =>
      condition == SpecialCondition.renalDisease ||
      condition == SpecialCondition.hepaticDisease ||
      condition == SpecialCondition.heartDisease
    ).toList();

    if (criticalConditions.length >= 2) {
      warnings.add('Múltiplas condições críticas detectadas');
      validationChecks['critical_conditions'] = ValidationCheck(
        name: 'Condições críticas',
        passed: false,
        score: 0.6,
        message: 'Combinação de condições críticas requer cuidado especial',
      );
    } else {
      validationChecks['critical_conditions'] = ValidationCheck(
        name: 'Condições críticas',
        passed: true,
        score: 1.0,
      );
    }

    final confidenceScore = _calculateConfidenceScore(validationChecks);
    
    return ValidationResult(
      isValid: criticalErrors.isEmpty,
      confidenceScore: confidenceScore,
      warnings: warnings,
      criticalErrors: criticalErrors,
      validationChecks: validationChecks,
      requiresDoubleConfirmation: criticalConditions.isNotEmpty || input.weight > 50.0,
    );
  }

  /// Validação com múltiplos algoritmos independentes
  static ValidationCheck _validateWithMultipleAlgorithms(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final expectedDose1 = _calculateDoseAlgorithm1(input, medication);
    final expectedDose2 = _calculateDoseAlgorithm2(input, medication);
    final expectedDose3 = _calculateDoseAlgorithm3(input, medication);

    final calculatedDose = output.dosagePerKg;
    const tolerance = 0.15; // 15% de tolerância
    final algorithm1Match = (calculatedDose - expectedDose1).abs() / expectedDose1 <= tolerance;
    final algorithm2Match = (calculatedDose - expectedDose2).abs() / expectedDose2 <= tolerance;
    final algorithm3Match = (calculatedDose - expectedDose3).abs() / expectedDose3 <= tolerance;
    
    final matches = [algorithm1Match, algorithm2Match, algorithm3Match].where((m) => m).length;
    final score = matches / 3.0;
    
    String? message;
    if (score < 0.67) {
      message = 'Divergência entre algoritmos de validação (${(score * 100).round()}% concordância)';
    }

    return ValidationCheck(
      name: 'Validação cruzada de algoritmos',
      passed: score >= 0.67,
      score: score,
      message: message,
    );
  }

  /// Validação de limites absolutos por espécie
  static ValidationCheck _validateSpeciesLimits(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final dosageRange = medication.getDosageRange(input.species, input.ageGroup);
    if (dosageRange == null) {
      return ValidationCheck(
        name: 'Limites por espécie',
        passed: false,
        score: 0.0,
        message: 'Faixa de dosagem não definida para esta espécie/idade',
      );
    }

    final calculatedDose = output.dosagePerKg;
    if (calculatedDose > dosageRange.maxDose) {
      return ValidationCheck(
        name: 'Limites por espécie',
        passed: false,
        score: 0.0,
        message: 'Dose acima do limite máximo para ${input.species.displayName}',
      );
    }
    
    if (calculatedDose < dosageRange.minDose * 0.8) { // 20% de tolerância abaixo
      return ValidationCheck(
        name: 'Limites por espécie',
        passed: false,
        score: 0.3,
        message: 'Dose muito abaixo do mínimo terapêutico',
      );
    }
    final rangePosition = (calculatedDose - dosageRange.minDose) / 
                         (dosageRange.maxDose - dosageRange.minDose);
    final score = math.max(0.7, 1.0 - (rangePosition - 0.5).abs());

    return ValidationCheck(
      name: 'Limites por espécie',
      passed: true,
      score: score,
    );
  }

  /// Cross-check com tabelas de referência veterinárias
  static ValidationCheck _validateAgainstVeterinaryReferences(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final referenceRanges = _getVeterinaryReferenceRanges(medication.id, input.species);
    
    if (referenceRanges == null) {
      return ValidationCheck(
        name: 'Referências veterinárias',
        passed: true,
        score: 0.8, // Score neutro quando não há referência específica
        message: 'Referência veterinária não disponível para validação cruzada',
      );
    }

    final calculatedDose = output.dosagePerKg;
    final isWithinReference = calculatedDose >= referenceRanges['min']! && 
                             calculatedDose <= referenceRanges['max']!;

    double score = 1.0;
    String? message;

    if (!isWithinReference) {
      if (calculatedDose > referenceRanges['max']!) {
        score = 0.2;
        message = 'Dose acima da referência veterinária padrão';
      } else {
        score = 0.4;
        message = 'Dose abaixo da referência veterinária padrão';
      }
    }

    return ValidationCheck(
      name: 'Referências veterinárias',
      passed: isWithinReference,
      score: score,
      message: message,
    );
  }

  /// Validação de margem de segurança mínima
  static ValidationCheck _validateSafetyMargin(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final dosageRange = medication.getDosageRange(input.species, input.ageGroup);
    if (dosageRange?.toxicDose == null) {
      return ValidationCheck(
        name: 'Margem de segurança',
        passed: true,
        score: 0.8,
        message: 'Dose tóxica não definida para cálculo de margem',
      );
    }

    final calculatedDose = output.dosagePerKg;
    final toxicDose = dosageRange!.toxicDose!;
    final safetyMargin = ((toxicDose - calculatedDose) / toxicDose) * 100;

    if (safetyMargin < minimumSafetyMargin) {
      return ValidationCheck(
        name: 'Margem de segurança',
        passed: false,
        score: math.max(0.0, safetyMargin / minimumSafetyMargin),
        message: 'Margem de segurança insuficiente: ${safetyMargin.toStringAsFixed(1)}%',
      );
    }
    final score = math.min(1.0, safetyMargin / (minimumSafetyMargin * 2));

    return ValidationCheck(
      name: 'Margem de segurança',
      passed: true,
      score: score,
    );
  }

  /// Validação de proximidade com doses tóxicas
  static ValidationCheck _validateToxicityProximity(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final dosageRange = medication.getDosageRange(input.species, input.ageGroup);
    if (dosageRange?.toxicDose == null) {
      return ValidationCheck(
        name: 'Proximidade tóxica',
        passed: true,
        score: 0.8,
      );
    }

    final calculatedDose = output.dosagePerKg;
    final toxicDose = dosageRange!.toxicDose!;
    final proximityRatio = calculatedDose / toxicDose;

    String? message;
    double score = 1.0;
    bool passed = true;

    if (proximityRatio >= 0.8) {
      passed = false;
      score = 0.0;
      message = 'PERIGO: Dose muito próxima do limite tóxico';
    } else if (proximityRatio >= criticalDoseThreshold) {
      passed = false;
      score = 0.3;
      message = 'ATENÇÃO: Dose próxima do limite crítico';
    } else if (proximityRatio >= 0.5) {
      score = 0.7;
      message = 'Monitoramento rigoroso recomendado';
    }

    return ValidationCheck(
      name: 'Proximidade tóxica',
      passed: passed,
      score: score,
      message: message,
    );
  }

  /// Validação de interações medicamentosas críticas
  static ValidationCheck _validateDrugInteractions(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    
    final criticalInteractions = medication.drugInteractions
        .where((drug) => _isCriticalInteraction(medication.id, drug))
        .toList();

    if (criticalInteractions.isNotEmpty) {
      return ValidationCheck(
        name: 'Interações medicamentosas',
        passed: false,
        score: 0.5,
        message: 'Verificar interações com: ${criticalInteractions.join(', ')}',
      );
    }

    return ValidationCheck(
      name: 'Interações medicamentosas',
      passed: true,
      score: 1.0,
    );
  }

  /// Validação de condições médicas especiais
  static ValidationCheck _validateSpecialConditions(
    MedicationDosageInput input,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    final criticalConditionCombinations = _getCriticalConditionCombinations(input.specialConditions);
    
    if (criticalConditionCombinations.isNotEmpty) {
      return ValidationCheck(
        name: 'Condições especiais',
        passed: false,
        score: 0.4,
        message: 'Combinação crítica de condições: ${criticalConditionCombinations.join(', ')}',
      );
    }
    final contraindications = medication.getContraindications(input.specialConditions);
    final absoluteContraindications = contraindications.where((c) => c.isAbsolute).toList();
    
    if (absoluteContraindications.isNotEmpty) {
      return ValidationCheck(
        name: 'Condições especiais',
        passed: false,
        score: 0.0,
        message: 'Contraindicação absoluta detectada',
      );
    }

    return ValidationCheck(
      name: 'Condições especiais',
      passed: true,
      score: 1.0,
    );
  }

  /// Calcula score de confiança baseado em todos os checks
  static double _calculateConfidenceScore(Map<String, ValidationCheck> checks) {
    if (checks.isEmpty) return 0.0;
    final weights = <String, double>{
      'algorithm_cross_check': 0.25,
      'species_limits': 0.20,
      'veterinary_references': 0.15,
      'safety_margin': 0.15,
      'toxicity_proximity': 0.15,
      'drug_interactions': 0.05,
      'special_conditions': 0.05,
    };
    
    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;
    
    for (final entry in checks.entries) {
      final weight = weights[entry.key] ?? 0.1;
      totalWeightedScore += entry.value.score * weight;
      totalWeight += weight;
    }
    
    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
  }

  /// Determina se requer confirmação dupla
  static bool _requiresDoubleConfirmation(
    double confidenceScore,
    List<String> criticalErrors,
    MedicationDosageOutput output,
    MedicationData medication,
  ) {
    if (criticalErrors.isNotEmpty) return true;
    if (confidenceScore < 0.8) return true;
    final highRiskMedications = ['meloxicam', 'enrofloxacin', 'furosemide', 'insulin_nph'];
    if (highRiskMedications.contains(medication.id)) return true;
    if (output.alerts.any((alert) => alert.level == AlertLevel.danger)) return true;
    
    return false;
  }

  /// Algoritmo 1: Cálculo linear simples baseado em peso
  static double _calculateDoseAlgorithm1(MedicationDosageInput input, MedicationData medication) {
    final dosageRange = medication.getDosageRange(input.species, input.ageGroup);
    if (dosageRange == null) return 0.0;
    
    double baseDose = (dosageRange.minDose + dosageRange.maxDose) / 2;
    if (input.specialConditions.isNotEmpty) {
      baseDose *= 0.85; // Redução conservadora
    }
    
    return baseDose;
  }

  /// Algoritmo 2: Cálculo baseado em superfície corporal
  static double _calculateDoseAlgorithm2(MedicationDosageInput input, MedicationData medication) {
    final dosageRange = medication.getDosageRange(input.species, input.ageGroup);
    if (dosageRange == null) return 0.0;
    final bodyScaleFactor = input.species == Species.cat ? 0.8 : 1.0;
    final adjustedWeight = input.weight * bodyScaleFactor;
    
    double baseDose = (dosageRange.minDose + dosageRange.maxDose) / 2;
    final surfaceAdjustment = math.pow(adjustedWeight / 10.0, 0.67);
    baseDose *= surfaceAdjustment;
    
    return baseDose;
  }

  /// Algoritmo 3: Cálculo farmacocinético básico
  static double _calculateDoseAlgorithm3(MedicationDosageInput input, MedicationData medication) {
    final dosageRange = medication.getDosageRange(input.species, input.ageGroup);
    if (dosageRange == null) return 0.0;
    
    double baseDose = dosageRange.minDose + (dosageRange.maxDose - dosageRange.minDose) * 0.6;
    switch (input.ageGroup) {
      case AgeGroup.puppy:
        baseDose *= 0.8; // Metabolismo mais lento
        break;
      case AgeGroup.senior:
        baseDose *= 0.85; // Clearance reduzido
        break;
      default:
        break;
    }
    final frequencyFactor = input.frequency.timesPerDay / 2.0;
    baseDose /= math.sqrt(frequencyFactor);
    
    return baseDose;
  }

  /// Obtém faixas de referência veterinárias conhecidas
  static Map<String, double>? _getVeterinaryReferenceRanges(String medicationId, Species species) {
    final references = <String, Map<Species, Map<String, double>>>{
      'amoxicillin': {
        Species.dog: {'min': 10.0, 'max': 20.0},
        Species.cat: {'min': 10.0, 'max': 15.0},
      },
      'meloxicam': {
        Species.dog: {'min': 0.1, 'max': 0.2},
        Species.cat: {'min': 0.05, 'max': 0.1},
      },
      'tramadol': {
        Species.dog: {'min': 2.0, 'max': 5.0},
        Species.cat: {'min': 1.0, 'max': 4.0},
      },
    };
    
    return references[medicationId]?[species];
  }

  /// Verifica se é uma interação medicamentosa crítica
  static bool _isCriticalInteraction(String medicationId, String interactionDrug) {
    final criticalInteractions = <String, List<String>>{
      'meloxicam': ['furosemide', 'corticoides'],
      'enrofloxacin': ['antacidos', 'teofilina'],
      'furosemide': ['meloxicam', 'aminoglicosideos'],
    };
    
    return criticalInteractions[medicationId]?.contains(interactionDrug.toLowerCase()) ?? false;
  }

  /// Identifica combinações críticas de condições médicas
  static List<String> _getCriticalConditionCombinations(List<SpecialCondition> conditions) {
    final criticalCombinations = <String>[];
    
    if (conditions.contains(SpecialCondition.renalDisease) && 
        conditions.contains(SpecialCondition.heartDisease)) {
      criticalCombinations.add('Doença renal + cardíaca');
    }
    
    if (conditions.contains(SpecialCondition.hepaticDisease) && 
        conditions.contains(SpecialCondition.geriatric)) {
      criticalCombinations.add('Doença hepática + idade avançada');
    }
    
    if (conditions.contains(SpecialCondition.pregnant) && 
        conditions.contains(SpecialCondition.diabetes)) {
      criticalCombinations.add('Gestação + diabetes');
    }
    
    return criticalCombinations;
  }
}
