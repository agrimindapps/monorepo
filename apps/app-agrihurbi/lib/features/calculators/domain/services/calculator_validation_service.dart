import 'package:core/core.dart' show injectable;

import '../entities/calculator_parameter.dart';
import '../interfaces/calculator_strategy.dart';
import '../repositories/calculator_data_repository.dart';

/// Service especializado em validação de parâmetros de calculadoras
///
/// Implementa Single Responsibility Principle (SRP) - foca apenas em validação.
/// Separado do Calculator Engine para maior modularidade e testabilidade.
@injectable
class CalculatorValidationService {
  final ICalculatorDataRepository _dataRepository;

  CalculatorValidationService(this._dataRepository);

  /// Valida parâmetros usando estratégia específica
  Future<ValidationResult> validateWithStrategy(
    ICalculatorStrategy strategy,
    Map<String, dynamic> inputs,
  ) async {
    return await strategy.validateInputs(inputs);
  }

  /// Validação básica de parâmetros sem estratégia específica
  Future<ParameterValidationResult> validateParameters(
    List<CalculatorParameter> parameters,
    Map<String, dynamic> inputs,
  ) async {
    final errors = <String, String>{};
    final warnings = <String, String>{};
    final sanitizedInputs = <String, dynamic>{};

    for (final param in parameters) {
      final result = await _validateSingleParameter(param, inputs[param.id]);

      if (result.hasError) {
        errors[param.id] = result.errorMessage!;
      }

      if (result.hasWarning) {
        warnings[param.id] = result.warningMessage!;
      }

      if (result.isValid) {
        sanitizedInputs[param.id] = result.sanitizedValue;
      }
    }

    // Validações cruzadas
    final crossValidation = await _performCrossValidation(
      parameters,
      sanitizedInputs,
    );
    errors.addAll(crossValidation.errors);
    warnings.addAll(crossValidation.warnings);

    return ParameterValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      sanitizedInputs: sanitizedInputs,
    );
  }

  /// Valida ranges de um parâmetro específico
  Future<RangeValidationResult> validateParameterRange(
    String parameterType,
    dynamic value,
  ) async {
    final ranges = await _dataRepository.getValidationRanges(parameterType);
    final numValue = double.tryParse(value.toString());

    if (numValue == null) {
      return const RangeValidationResult(
        isValid: false,
        isInOptimalRange: false,
        errorMessage: 'Valor deve ser numérico',
      );
    }

    final isValid = numValue >= ranges.minValue && numValue <= ranges.maxValue;
    final isOptimal =
        numValue >= ranges.optimalMin && numValue <= ranges.optimalMax;

    String? errorMessage;
    String? warningMessage;

    if (!isValid) {
      if (numValue < ranges.minValue) {
        errorMessage =
            'Valor deve ser maior que ${ranges.minValue} ${ranges.unit}';
      } else {
        errorMessage =
            'Valor deve ser menor que ${ranges.maxValue} ${ranges.unit}';
      }
    } else if (!isOptimal) {
      if (numValue < ranges.optimalMin) {
        warningMessage =
            'Valor baixo. Recomendado: ${ranges.optimalMin}-${ranges.optimalMax} ${ranges.unit}';
      } else {
        warningMessage =
            'Valor alto. Recomendado: ${ranges.optimalMin}-${ranges.optimalMax} ${ranges.unit}';
      }
    }

    return RangeValidationResult(
      isValid: isValid,
      isInOptimalRange: isOptimal,
      errorMessage: errorMessage,
      warningMessage: warningMessage,
      sanitizedValue: numValue,
    );
  }

  /// Valida compatibilidade entre cultura e parâmetros
  Future<CompatibilityValidationResult> validateCropCompatibility(
    String cropType,
    Map<String, dynamic> inputs,
  ) async {
    final warnings = <String>[];

    // Verificar produtividade realística
    final expectedYield =
        double.tryParse(inputs['expected_yield']?.toString() ?? '0') ?? 0;
    if (await _isYieldUnrealistic(cropType, expectedYield)) {
      warnings.add(
        'Produtividade esperada (${expectedYield}t/ha) pode estar acima da média para $cropType',
      );
    }

    // Verificar coerência entre solo e cultura
    final soilTexture = inputs['soil_texture']?.toString() ?? '';
    if (await _isSoilIncompatible(cropType, soilTexture)) {
      warnings.add('$cropType pode não ser ideal para solos $soilTexture');
    }

    // Verificar matéria orgânica adequada
    final organicMatter =
        double.tryParse(inputs['organic_matter']?.toString() ?? '0') ?? 0;
    if (organicMatter < 2.0) {
      warnings.add(
        'Matéria orgânica baixa (${organicMatter.toStringAsFixed(1)}%) pode limitar produtividade de $cropType',
      );
    }

    return CompatibilityValidationResult(
      isCompatible: warnings.isEmpty,
      warnings: warnings,
    );
  }

  /// Valida disponibilidade de nutrientes no solo
  Future<NutrientValidationResult> validateSoilNutrients(
    Map<String, dynamic> inputs,
  ) async {
    final warnings = <String>[];
    final errors = <String>[];

    final soilN = double.tryParse(inputs['soil_n']?.toString() ?? '0') ?? 0;
    final soilP = double.tryParse(inputs['soil_p']?.toString() ?? '0') ?? 0;
    final soilK = double.tryParse(inputs['soil_k']?.toString() ?? '0') ?? 0;

    // Validar N
    if (soilN < 10) {
      warnings.add(
        'Nitrogênio muito baixo no solo (${soilN}mg/dm³). Considere adubação nitrogenada intensiva.',
      );
    } else if (soilN > 100) {
      warnings.add(
        'Nitrogênio muito alto no solo (${soilN}mg/dm³). Risco de lixiviação.',
      );
    }

    // Validar P
    if (soilP < 5) {
      warnings.add(
        'Fósforo muito baixo no solo (${soilP}mg/dm³). Pode limitar desenvolvimento radicular.',
      );
    } else if (soilP > 60) {
      warnings.add(
        'Fósforo muito alto no solo (${soilP}mg/dm³). Pode interferir na absorção de micronutrientes.',
      );
    }

    // Validar K
    if (soilK < 40) {
      warnings.add(
        'Potássio baixo no solo (${soilK}mg/dm³). Importante para qualidade e resistência.',
      );
    } else if (soilK > 300) {
      warnings.add(
        'Potássio muito alto no solo (${soilK}mg/dm³). Pode causar desequilíbrio nutricional.',
      );
    }

    // Validar relações entre nutrientes
    if (soilP > 0 && soilK > 0) {
      final relacaoKP = soilK / soilP;
      if (relacaoKP < 2.0) {
        warnings.add(
          'Relação K/P baixa (${relacaoKP.toStringAsFixed(1)}). Ideal: 2-4.',
        );
      } else if (relacaoKP > 6.0) {
        warnings.add(
          'Relação K/P alta (${relacaoKP.toStringAsFixed(1)}). Pode reduzir absorção de P.',
        );
      }
    }

    return NutrientValidationResult(
      isBalanced: warnings.length <= 1, // Tolerância para um warning
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida inputs obrigatórios
  ValidationRequiredResult validateRequiredInputs(
    List<CalculatorParameter> parameters,
    Map<String, dynamic> inputs,
  ) {
    final missingRequired = <String>[];

    for (final param in parameters.where((p) => p.required)) {
      if (!inputs.containsKey(param.id) ||
          inputs[param.id] == null ||
          inputs[param.id].toString().trim().isEmpty) {
        missingRequired.add(param.name);
      }
    }

    return ValidationRequiredResult(
      allRequiredPresent: missingRequired.isEmpty,
      missingFields: missingRequired,
    );
  }

  // ============= MÉTODOS PRIVADOS =============

  Future<SingleParameterValidationResult> _validateSingleParameter(
    CalculatorParameter param,
    dynamic value,
  ) async {
    // Verificar se é obrigatório
    if (param.required && (value == null || value.toString().trim().isEmpty)) {
      return SingleParameterValidationResult(
        isValid: false,
        errorMessage: '${param.name} é obrigatório',
      );
    }

    // Se não é obrigatório e está vazio, é válido
    if (!param.required && (value == null || value.toString().trim().isEmpty)) {
      return SingleParameterValidationResult(
        isValid: true,
        sanitizedValue: param.defaultValue,
      );
    }

    // Validar tipo
    final typeValidation = _validateParameterType(param, value);
    if (!typeValidation.isValid) {
      return typeValidation;
    }

    // Validar range se aplicável
    if (param.type == ParameterType.decimal ||
        param.type == ParameterType.number) {
      final rangeValidation = await validateParameterRange(param.id, value);
      if (!rangeValidation.isValid) {
        return SingleParameterValidationResult(
          isValid: false,
          errorMessage: rangeValidation.errorMessage,
        );
      }

      if (rangeValidation.warningMessage != null) {
        return SingleParameterValidationResult(
          isValid: true,
          warningMessage: rangeValidation.warningMessage,
          sanitizedValue: rangeValidation.sanitizedValue,
        );
      }

      return SingleParameterValidationResult(
        isValid: true,
        sanitizedValue: rangeValidation.sanitizedValue,
      );
    }

    // Para outros tipos, usar validação básica do parâmetro
    if (param.isValid(value)) {
      return SingleParameterValidationResult(
        isValid: true,
        sanitizedValue: value,
      );
    } else {
      return SingleParameterValidationResult(
        isValid: false,
        errorMessage:
            param.validationMessage ?? 'Valor inválido para ${param.name}',
      );
    }
  }

  SingleParameterValidationResult _validateParameterType(
    CalculatorParameter param,
    dynamic value,
  ) {
    switch (param.type) {
      case ParameterType.decimal:
      case ParameterType.number:
        final numValue = double.tryParse(value.toString());
        if (numValue == null) {
          return SingleParameterValidationResult(
            isValid: false,
            errorMessage: '${param.name} deve ser um número válido',
          );
        }
        return SingleParameterValidationResult(
          isValid: true,
          sanitizedValue: numValue,
        );

      case ParameterType.selection:
        if (param.options == null ||
            !param.options!.contains(value.toString())) {
          return SingleParameterValidationResult(
            isValid: false,
            errorMessage:
                '${param.name} deve ser uma das opções: ${param.options?.join(', ')}',
          );
        }
        return SingleParameterValidationResult(
          isValid: true,
          sanitizedValue: value.toString(),
        );

      case ParameterType.percentage:
        final numValue = double.tryParse(value.toString());
        if (numValue == null || numValue < 0 || numValue > 100) {
          return SingleParameterValidationResult(
            isValid: false,
            errorMessage:
                '${param.name} deve ser uma porcentagem entre 0 e 100',
          );
        }
        return SingleParameterValidationResult(
          isValid: true,
          sanitizedValue: numValue,
        );

      default:
        return SingleParameterValidationResult(
          isValid: true,
          sanitizedValue: value,
        );
    }
  }

  Future<CrossValidationResult> _performCrossValidation(
    List<CalculatorParameter> parameters,
    Map<String, dynamic> inputs,
  ) async {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    // Exemplo: validar se área é coerente com produção total esperada
    final area = double.tryParse(inputs['area']?.toString() ?? '0') ?? 0;
    final expectedYield =
        double.tryParse(inputs['expected_yield']?.toString() ?? '0') ?? 0;

    if (area > 0 && expectedYield > 0) {
      final totalProduction = area * expectedYield;
      if (totalProduction > 10000) {
        // > 10 mil toneladas
        warnings['area'] =
            'Produção total muito alta (${totalProduction.toStringAsFixed(0)}t). Verifique área e produtividade.';
      }
    }

    return CrossValidationResult(errors: errors, warnings: warnings);
  }

  Future<bool> _isYieldUnrealistic(
    String cropType,
    double expectedYield,
  ) async {
    // Produtividades consideradas altas por cultura
    final Map<String, double> realisticYields = {
      'Milho': 15.0,
      'Soja': 5.0,
      'Trigo': 6.0,
      'Arroz': 10.0,
      'Feijão': 4.0,
      'Café': 40.0,
      'Algodão': 5.0,
      'Cana-de-açúcar': 100.0,
      'Tomate': 80.0,
      'Batata': 40.0,
    };

    final threshold = realisticYields[cropType] ?? 10.0;
    return expectedYield > threshold * 1.3; // 30% acima do limite
  }

  Future<bool> _isSoilIncompatible(String cropType, String soilTexture) async {
    // Incompatibilidades conhecidas (simplificado)
    final incompatibilities = {
      'Arroz': ['Arenoso'], // Arroz prefere solos com retenção
      'Batata': ['Argiloso'], // Batata prefere solos mais soltos
    };

    return incompatibilities[cropType]?.contains(soilTexture) ?? false;
  }
}

// ============= RESULT CLASSES =============

class ParameterValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;
  final Map<String, dynamic> sanitizedInputs;

  const ParameterValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.sanitizedInputs,
  });
}

class SingleParameterValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;
  final dynamic sanitizedValue;

  const SingleParameterValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
    this.sanitizedValue,
  });

  bool get hasError => errorMessage != null;
  bool get hasWarning => warningMessage != null;
}

class RangeValidationResult {
  final bool isValid;
  final bool isInOptimalRange;
  final String? errorMessage;
  final String? warningMessage;
  final double? sanitizedValue;

  const RangeValidationResult({
    required this.isValid,
    required this.isInOptimalRange,
    this.errorMessage,
    this.warningMessage,
    this.sanitizedValue,
  });
}

class CompatibilityValidationResult {
  final bool isCompatible;
  final List<String> warnings;

  const CompatibilityValidationResult({
    required this.isCompatible,
    required this.warnings,
  });
}

class NutrientValidationResult {
  final bool isBalanced;
  final List<String> errors;
  final List<String> warnings;

  const NutrientValidationResult({
    required this.isBalanced,
    required this.errors,
    required this.warnings,
  });
}

class ValidationRequiredResult {
  final bool allRequiredPresent;
  final List<String> missingFields;

  const ValidationRequiredResult({
    required this.allRequiredPresent,
    required this.missingFields,
  });
}

class CrossValidationResult {
  final Map<String, String> errors;
  final Map<String, String> warnings;

  const CrossValidationResult({required this.errors, required this.warnings});
}
