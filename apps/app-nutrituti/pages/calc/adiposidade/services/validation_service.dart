// Project imports:
import 'security_service.dart';

/// Resultado de validação com sucesso/erro e mensagem específica
class ValidationResult {
  final bool isValid;
  final String? message;
  final ValidationSeverity severity;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.severity = ValidationSeverity.error,
  });

  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
    );
  }

  factory ValidationResult.warning(String message) {
    return ValidationResult(
      isValid: true,
      message: message,
      severity: ValidationSeverity.warning,
    );
  }
}

/// Severidade da validação
enum ValidationSeverity {
  error,
  warning,
  info,
}

/// Service responsável por toda a lógica de validação dos campos
class AdiposidadeValidationService {
  /// Valida o campo de circunferência do quadril
  static ValidationResult validateQuadril(String value) {
    if (value.isEmpty) {
      return ValidationResult.error(
          'Necessário informar a circunferência do quadril');
    }

    // Validação de segurança primeiro
    final securityResult =
        AdiposidadeSecurityService.validateQuadrilSecurity(value);
    if (!securityResult.isSecure) {
      // Log da violação de segurança
      AdiposidadeSecurityService.logSecurityViolation(
        input: value,
        reason: securityResult.vulnerabilityReason ?? 'Entrada insegura',
        threatLevel: securityResult.threatLevel,
        fieldName: 'quadril',
      );

      return ValidationResult.error(securityResult.vulnerabilityReason ??
          'Entrada inválida por motivos de segurança');
    }

    // Usar valor sanitizado se disponível
    final processedValue = securityResult.sanitizedValue ?? value;

    try {
      final quadril = _parseDecimal(processedValue);

      if (quadril <= 0) {
        return ValidationResult.error('Circunferência deve ser maior que zero');
      }

      if (quadril < 30) {
        return ValidationResult.error('Valor muito baixo (mínimo 30cm)');
      }

      if (quadril > 200) {
        return ValidationResult.error('Valor muito alto (máximo 200cm)');
      }

      // Validação de warning para valores extremos mas válidos
      if (quadril < 50) {
        return ValidationResult.warning('Valor baixo - verifique a medição');
      }

      if (quadril > 150) {
        return ValidationResult.warning('Valor alto - verifique a medição');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Formato inválido - use apenas números');
    }
  }

  /// Valida o campo de altura
  static ValidationResult validateAltura(String value) {
    if (value.isEmpty) {
      return ValidationResult.error('Necessário informar a altura');
    }

    // Validação de segurança primeiro
    final securityResult =
        AdiposidadeSecurityService.validateAlturaSecurity(value);
    if (!securityResult.isSecure) {
      // Log da violação de segurança
      AdiposidadeSecurityService.logSecurityViolation(
        input: value,
        reason: securityResult.vulnerabilityReason ?? 'Entrada insegura',
        threatLevel: securityResult.threatLevel,
        fieldName: 'altura',
      );

      return ValidationResult.error(securityResult.vulnerabilityReason ??
          'Entrada inválida por motivos de segurança');
    }

    // Usar valor sanitizado se disponível
    final processedValue = securityResult.sanitizedValue ?? value;

    try {
      final altura = _parseDecimal(processedValue);

      if (altura <= 0) {
        return ValidationResult.error('Altura deve ser maior que zero');
      }

      if (altura < 50) {
        return ValidationResult.error('Altura muito baixa (mínimo 50cm)');
      }

      if (altura > 300) {
        return ValidationResult.error('Altura muito alta (máximo 300cm)');
      }

      // Validação de warning para valores extremos mas válidos
      if (altura < 100) {
        return ValidationResult.warning('Altura baixa - verifique a medição');
      }

      if (altura > 250) {
        return ValidationResult.warning('Altura alta - verifique a medição');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Formato inválido - use apenas números');
    }
  }

  /// Valida o campo de idade
  static ValidationResult validateIdade(String value) {
    if (value.isEmpty) {
      return ValidationResult.error('Necessário informar a idade');
    }

    // Validação de segurança primeiro
    final securityResult =
        AdiposidadeSecurityService.validateIdadeSecurity(value);
    if (!securityResult.isSecure) {
      // Log da violação de segurança
      AdiposidadeSecurityService.logSecurityViolation(
        input: value,
        reason: securityResult.vulnerabilityReason ?? 'Entrada insegura',
        threatLevel: securityResult.threatLevel,
        fieldName: 'idade',
      );

      return ValidationResult.error(securityResult.vulnerabilityReason ??
          'Entrada inválida por motivos de segurança');
    }

    // Usar valor sanitizado se disponível
    final processedValue = securityResult.sanitizedValue ?? value;

    try {
      final idade = int.parse(processedValue);

      if (idade < 5) {
        return ValidationResult.error('Idade deve ser maior que 5 anos');
      }

      if (idade > 120) {
        return ValidationResult.error('Idade deve ser menor que 120 anos');
      }

      // Validação de warning para idades extremas mas válidas
      if (idade < 18) {
        return ValidationResult.warning(
            'Atenção: Menor de idade - consulte um profissional');
      }

      if (idade > 80) {
        return ValidationResult.warning(
            'Atenção: Para idosos, consulte orientação médica específica');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
          'Formato inválido - use apenas números inteiros');
    }
  }

  /// Valida o campo de circunferência de forma individual (para validação em tempo real)
  static ValidationResult validateQuadrilRealTime(String value) {
    if (value.isEmpty) {
      return ValidationResult.success(); // Não mostra erro se está vazio
    }

    try {
      final quadril = _parseDecimal(value);

      if (quadril <= 0) {
        return ValidationResult.error('Circunferência deve ser maior que zero');
      }

      if (quadril < 30) {
        return ValidationResult.error('Valor muito baixo (mínimo 30cm)');
      }

      if (quadril > 200) {
        return ValidationResult.error('Valor muito alto (máximo 200cm)');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Formato inválido');
    }
  }

  /// Valida o campo de altura de forma individual (para validação em tempo real)
  static ValidationResult validateAlturaRealTime(String value) {
    if (value.isEmpty) {
      return ValidationResult.success(); // Não mostra erro se está vazio
    }

    try {
      final altura = _parseDecimal(value);

      if (altura <= 0) {
        return ValidationResult.error('Altura deve ser maior que zero');
      }

      if (altura < 50) {
        return ValidationResult.error('Altura muito baixa (mínimo 50cm)');
      }

      if (altura > 300) {
        return ValidationResult.error('Altura muito alta (máximo 300cm)');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Formato inválido');
    }
  }

  /// Valida o campo de idade de forma individual (para validação em tempo real)
  static ValidationResult validateIdadeRealTime(String value) {
    if (value.isEmpty) {
      return ValidationResult.success(); // Não mostra erro se está vazio
    }

    try {
      final idade = int.parse(value);

      if (idade < 5) {
        return ValidationResult.error('Idade deve ser maior que 5 anos');
      }

      if (idade > 120) {
        return ValidationResult.error('Idade deve ser menor que 120 anos');
      }

      if (idade < 18) {
        return ValidationResult.warning('Atenção: Menor de idade');
      }

      if (idade > 80) {
        return ValidationResult.warning('Atenção: Consulte orientação médica');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Formato inválido');
    }
  }

  /// Valida todos os campos antes do cálculo
  static Map<String, ValidationResult> validateAllFields({
    required String quadril,
    required String altura,
    required String idade,
  }) {
    return {
      'quadril': validateQuadril(quadril),
      'altura': validateAltura(altura),
      'idade': validateIdade(idade),
    };
  }

  /// Verifica se todos os campos são válidos
  static bool areAllFieldsValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  /// Obtém a primeira mensagem de erro encontrada
  static String? getFirstErrorMessage(Map<String, ValidationResult> results) {
    for (final result in results.values) {
      if (!result.isValid && result.message != null) {
        return result.message;
      }
    }
    return null;
  }

  /// Obtém todas as mensagens de warning
  static List<String> getWarningMessages(
      Map<String, ValidationResult> results) {
    final warnings = <String>[];
    for (final result in results.values) {
      if (result.isValid &&
          result.severity == ValidationSeverity.warning &&
          result.message != null) {
        warnings.add(result.message!);
      }
    }
    return warnings;
  }

  /// Função helper para parsing decimal (converte vírgula para ponto)
  static double _parseDecimal(String value) {
    return double.parse(value.replaceAll(',', '.'));
  }
}
