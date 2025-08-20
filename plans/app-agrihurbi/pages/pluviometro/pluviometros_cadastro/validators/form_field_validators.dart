// Project imports:
import '../constants/error_messages.dart';
import '../utils/type_conversion_utils.dart';
import 'numeric_input_validator.dart';

/// Validadores específicos para campos de formulário
class FormFieldValidators {
  /// Valida campo de descrição
  static String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ErrorMessages.descricaoRequired;
    }

    if (value.length < 3) {
      return ErrorMessages.descricaoMinLength;
    }

    if (value.length > 80) {
      return ErrorMessages.descricaoMaxLength;
    }

    // Validação de caracteres especiais
    if (!_isValidDescricaoFormat(value)) {
      return ErrorMessages.descricaoInvalidFormat;
    }

    return null;
  }

  /// Valida campo de quantidade com validação avançada
  static String? validateQuantidade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ErrorMessages.quantidadeRequired;
    }

    // Usar validação avançada do NumericInputValidator
    final validationResult =
        NumericInputValidator.validateQuantidadeInput(value);
    if (validationResult != null) {
      return validationResult;
    }

    return null;
  }

  /// Valida campo de latitude com validação avançada
  static String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo opcional
    }

    // Usar validação avançada do NumericInputValidator
    return NumericInputValidator.validateLatitudeInput(value);
  }

  /// Valida campo de longitude com validação avançada
  static String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo opcional
    }

    // Usar validação avançada do NumericInputValidator
    return NumericInputValidator.validateLongitudeInput(value);
  }

  /// Valida campo de grupo
  static String? validateGrupo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Campo opcional
    }

    if (value.length < 2) {
      return ErrorMessages.grupoMinLength;
    }

    if (value.length > 50) {
      return ErrorMessages.grupoMaxLength;
    }

    return null;
  }

  /// Validador customizável
  static String? Function(String?) customValidator({
    required String fieldName,
    bool required = false,
    int? minLength,
    int? maxLength,
    double? minValue,
    double? maxValue,
    String? pattern,
  }) {
    return (String? value) {
      if (required && (value == null || value.trim().isEmpty)) {
        return '$fieldName é obrigatório';
      }

      if (value == null || value.trim().isEmpty) {
        return null;
      }

      if (minLength != null && value.length < minLength) {
        return '$fieldName deve ter pelo menos $minLength caracteres';
      }

      if (maxLength != null && value.length > maxLength) {
        return '$fieldName deve ter no máximo $maxLength caracteres';
      }

      if (minValue != null || maxValue != null) {
        if (!TypeConversionUtils.isValidDouble(value)) {
          return '$fieldName deve ser um número válido';
        }

        final numValue = TypeConversionUtils.safeDoubleFromString(value);

        if (minValue != null && numValue < minValue) {
          return '$fieldName deve ser maior que $minValue';
        }

        if (maxValue != null && numValue > maxValue) {
          return '$fieldName deve ser menor que $maxValue';
        }
      }

      if (pattern != null) {
        final regex = RegExp(pattern);
        if (!regex.hasMatch(value)) {
          return '$fieldName tem formato inválido';
        }
      }

      return null;
    };
  }

  /// Combinador de validadores
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  // Métodos auxiliares privados

  static bool _isValidDescricaoFormat(String descricao) {
    // Aceita letras, números, espaços e alguns caracteres especiais comuns
    final pattern = RegExp(r'^[a-zA-Z0-9\s\-_.,()]+$');
    return pattern.hasMatch(descricao);
  }
}

/// Classe para validação em tempo real
class RealTimeValidator {
  static const Duration _debounceTime = Duration(milliseconds: 300);
  static final Map<String, DateTime> _lastValidation = {};

  /// Valida campo com debounce
  static Future<String?> validateWithDebounce(
    String fieldName,
    String? value,
    String? Function(String?) validator,
  ) async {
    final now = DateTime.now();
    final lastTime = _lastValidation[fieldName];

    if (lastTime != null && now.difference(lastTime) < _debounceTime) {
      return null; // Ainda dentro do período de debounce
    }

    _lastValidation[fieldName] = now;

    // Simula delay de validação
    await Future.delayed(const Duration(milliseconds: 50));

    return validator(value);
  }

  /// Limpa cache de validação
  static void clearCache() {
    _lastValidation.clear();
  }
}
