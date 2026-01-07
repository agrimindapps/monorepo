import '../entities/calculator_parameter.dart';

/// Sistema de validação robusto para parâmetros de calculadoras
///
/// Implementa validação por tipo, range, formato e regras de negócio específicas
class ParameterValidator {
  ParameterValidator._();

  static const Map<ParameterType, String> _typeErrorMessages = {
    ParameterType.number: 'Deve ser um número inteiro válido',
    ParameterType.decimal: 'Deve ser um número decimal válido',
    ParameterType.percentage: 'Deve ser uma porcentagem entre 0 e 100',
    ParameterType.text: 'Texto não pode estar vazio',
    ParameterType.selection: 'Deve selecionar uma opção válida',
    ParameterType.boolean: 'Deve ser verdadeiro ou falso',
    ParameterType.date: 'Deve ser uma data válida',
    ParameterType.area: 'Deve ser uma área válida (> 0)',
    ParameterType.volume: 'Deve ser um volume válido (> 0)',
    ParameterType.weight: 'Deve ser um peso válido (> 0)',
  };

  /// Valida um parâmetro individual
  static ValidationResult validateParameter(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (parameter.required && _isEmpty(value)) {
      return ValidationLeft(parameter.id, '${parameter.name} é obrigatório');
    }
    if (!parameter.required && _isEmpty(value)) {
      return ValidationRight(parameter.id);
    }
    final typeValidation = _validateByType(parameter, value);
    if (!typeValidation.isValid) {
      return typeValidation;
    }
    final rangeValidation = _validateRange(parameter, value);
    if (!rangeValidation.isValid) {
      return rangeValidation;
    }
    final optionsValidation = _validateOptions(parameter, value);
    if (!optionsValidation.isValid) {
      return optionsValidation;
    }
    final customValidation = _validateCustomRules(parameter, value);
    if (!customValidation.isValid) {
      return customValidation;
    }

    return ValidationRight(parameter.id);
  }

  /// Valida múltiplos parâmetros em batch
  static ValidationBatchResult validateParameters(
    List<CalculatorParameter> parameters,
    Map<String, dynamic> values,
  ) {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    for (final parameter in parameters) {
      final value = values[parameter.id];
      final result = validateParameter(parameter, value);

      if (!result.isValid) {
        errors[parameter.id] = result.errorMessage!;
      } else if (result.hasWarning) {
        warnings[parameter.id] = result.warningMessage!;
      }
    }

    return ValidationBatchResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida formato de coordenadas GPS
  static ValidationResult validateCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return ValidationLeft(
        'coordinates',
        'Latitude e longitude são obrigatórias',
      );
    }

    if (lat < -90 || lat > 90) {
      return ValidationLeft(
        'latitude',
        'Latitude deve estar entre -90 e 90 graus',
      );
    }

    if (lng < -180 || lng > 180) {
      return ValidationLeft(
        'longitude',
        'Longitude deve estar entre -180 e 180 graus',
      );
    }

    return ValidationRight('coordinates');
  }

  /// Valida range de valores
  static ValidationResult validateValueRange(double? min, double? max) {
    if (min == null || max == null) {
      return ValidationLeft(
        'range',
        'Valores mínimo e máximo são obrigatórios',
      );
    }

    if (min >= max) {
      return ValidationLeft(
        'range',
        'Valor mínimo deve ser menor que o máximo',
      );
    }

    return ValidationRight('range');
  }

  /// Validação por tipo de dados
  static ValidationResult _validateByType(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    switch (parameter.type) {
      case ParameterType.number:
        return _validateInteger(parameter, value);
      case ParameterType.decimal:
      case ParameterType.area:
      case ParameterType.volume:
      case ParameterType.weight:
        return _validateDecimal(parameter, value);
      case ParameterType.percentage:
        return _validatePercentage(parameter, value);
      case ParameterType.text:
        return _validateText(parameter, value);
      case ParameterType.selection:
        return _validateSelection(parameter, value);
      case ParameterType.boolean:
        return _validateBoolean(parameter, value);
      case ParameterType.date:
        return _validateDate(parameter, value);
      default:
        return ValidationRight(parameter.id);
    }
  }

  static ValidationResult _validateInteger(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (value is int) return ValidationRight(parameter.id);

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        return ValidationLeft(
          parameter.id,
          _typeErrorMessages[ParameterType.number]!,
        );
      }
      return ValidationRight(parameter.id);
    }

    return ValidationLeft(
      parameter.id,
      _typeErrorMessages[ParameterType.number]!,
    );
  }

  static ValidationResult _validateDecimal(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (value is num) {
      if (parameter.type == ParameterType.area ||
          parameter.type == ParameterType.volume ||
          parameter.type == ParameterType.weight) {
        if (value <= 0) {
          return ValidationLeft(
            parameter.id,
            _typeErrorMessages[parameter.type]!,
          );
        }
      }
      return ValidationRight(parameter.id);
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        return ValidationLeft(
          parameter.id,
          _typeErrorMessages[ParameterType.decimal]!,
        );
      }
      if (parameter.type == ParameterType.area ||
          parameter.type == ParameterType.volume ||
          parameter.type == ParameterType.weight) {
        if (parsed <= 0) {
          return ValidationLeft(
            parameter.id,
            _typeErrorMessages[parameter.type]!,
          );
        }
      }

      return ValidationRight(parameter.id);
    }

    return ValidationLeft(
      parameter.id,
      _typeErrorMessages[ParameterType.decimal]!,
    );
  }

  static ValidationResult _validatePercentage(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    final numValue = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());

    if (numValue == null) {
      return ValidationLeft(
        parameter.id,
        _typeErrorMessages[ParameterType.percentage]!,
      );
    }

    if (numValue < 0 || numValue > 100) {
      return ValidationLeft(
        parameter.id,
        'Porcentagem deve estar entre 0 e 100',
      );
    }

    return ValidationRight(parameter.id);
  }

  static ValidationResult _validateText(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (value is! String || value.trim().isEmpty) {
      return ValidationLeft(
        parameter.id,
        _typeErrorMessages[ParameterType.text]!,
      );
    }

    return ValidationRight(parameter.id);
  }

  static ValidationResult _validateSelection(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (parameter.options == null || parameter.options!.isEmpty) {
      return ValidationRight(parameter.id);
    }

    if (!parameter.options!.contains(value.toString())) {
      return ValidationLeft(
        parameter.id,
        _typeErrorMessages[ParameterType.selection]!,
      );
    }

    return ValidationRight(parameter.id);
  }

  static ValidationResult _validateBoolean(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (value is! bool) {
      return ValidationLeft(
        parameter.id,
        _typeErrorMessages[ParameterType.boolean]!,
      );
    }

    return ValidationRight(parameter.id);
  }

  static ValidationResult _validateDate(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (value is! DateTime) {
      return ValidationLeft(
        parameter.id,
        _typeErrorMessages[ParameterType.date]!,
      );
    }

    return ValidationRight(parameter.id);
  }

  static ValidationResult _validateRange(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (value == null) return ValidationRight(parameter.id);

    final numValue = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());
    if (numValue == null) return ValidationRight(parameter.id);

    if (parameter.minValue != null && numValue < (parameter.minValue as num)) {
      return ValidationLeft(
        parameter.id,
        'Valor deve ser maior ou igual a ${parameter.minValue}',
      );
    }

    if (parameter.maxValue != null && numValue > (parameter.maxValue as num)) {
      return ValidationLeft(
        parameter.id,
        'Valor deve ser menor ou igual a ${parameter.maxValue}',
      );
    }

    return ValidationRight(parameter.id);
  }

  static ValidationResult _validateOptions(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (parameter.type != ParameterType.selection) {
      return ValidationRight(parameter.id);
    }

    return _validateSelection(parameter, value);
  }

  static ValidationResult _validateCustomRules(
    CalculatorParameter parameter,
    dynamic value,
  ) {
    if (parameter.id.contains('ph') && value is num) {
      if (value < 0 || value > 14) {
        return ValidationLeft(parameter.id, 'pH deve estar entre 0 e 14');
      }
    }

    if (parameter.id.contains('temperature') && value is num) {
      if (value < -50 || value > 60) {
        return ValidationResult.warning(
          parameter.id,
          'Temperatura fora do range típico (-50°C a 60°C)',
        );
      }
    }

    if (parameter.id.contains('humidity') && value is num) {
      if (value < 0 || value > 100) {
        return ValidationLeft(
          parameter.id,
          'Umidade deve estar entre 0 e 100%',
        );
      }
    }

    return ValidationRight(parameter.id);
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    return false;
  }
}

/// Resultado de validação para um parâmetro individual
class ValidationResult {
  final String parameterId;
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;

  const ValidationResult._({
    required this.parameterId,
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
  });

  factory ValidationResult.success(String parameterId) {
    return ValidationResult._(parameterId: parameterId, isValid: true);
  }

  factory ValidationResult.error(String parameterId, String message) {
    return ValidationResult._(
      parameterId: parameterId,
      isValid: false,
      errorMessage: message,
    );
  }

  factory ValidationResult.warning(String parameterId, String message) {
    return ValidationResult._(
      parameterId: parameterId,
      isValid: true,
      warningMessage: message,
    );
  }

  bool get hasWarning => warningMessage != null;
}

// Helper functions for legacy compatibility
// ignore: non_constant_identifier_names
ValidationResult ValidationRight(String parameterId) =>
    ValidationResult.success(parameterId);

// ignore: non_constant_identifier_names
ValidationResult ValidationLeft(String parameterId, String message) =>
    ValidationResult.error(parameterId, message);

/// Resultado de validação em lote
class ValidationBatchResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;

  const ValidationBatchResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  int get errorCount => errors.length;
  int get warningCount => warnings.length;
}
