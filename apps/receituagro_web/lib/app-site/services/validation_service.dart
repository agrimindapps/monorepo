import '../core/utils/form_validators.dart';

/// Service para validações de negócio
class ValidationService {
  /// Valida busca de defensivos
  static ValidationResult validateDefensivosSearch(String search) {
    if (search.length < 3) {
      return ValidationResult(
        isValid: false,
        message: 'Informe pelo menos 3 caracteres para realizar a busca',
      );
    }

    final sanitizedSearch = FormValidators.sanitizeInput(search);
    if (sanitizedSearch.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Termo de busca inválido',
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitizedSearch,
    );
  }

  /// Valida dados de cultura
  static ValidationResult validateCulturaData(String cultura, int status) {
    final culturaValidation = FormValidators.validateCultura(cultura);
    if (culturaValidation != null) {
      return ValidationResult(
        isValid: false,
        message: culturaValidation,
      );
    }

    final statusValidation = FormValidators.validateStatus(status.toString());
    if (statusValidation != null) {
      return ValidationResult(
        isValid: false,
        message: statusValidation,
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: FormValidators.sanitizeInput(cultura),
    );
  }

  /// Valida dados de praga
  static ValidationResult validatePragaData(
      String nomeComum, String nomeCientifico, String tipoPraga) {
    final nomeComumValidation = FormValidators.validateNomeComum(nomeComum);
    if (nomeComumValidation != null) {
      return ValidationResult(
        isValid: false,
        message: nomeComumValidation,
      );
    }

    final nomeCientificoValidation =
        FormValidators.validateNomeCientifico(nomeCientifico);
    if (nomeCientificoValidation != null) {
      return ValidationResult(
        isValid: false,
        message: nomeCientificoValidation,
      );
    }

    final tipoPragaValidation = FormValidators.validateTipoPraga(tipoPraga);
    if (tipoPragaValidation != null) {
      return ValidationResult(
        isValid: false,
        message: tipoPragaValidation,
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: {
        'nomeComum': FormValidators.sanitizeInput(nomeComum),
        'nomeCientifico': FormValidators.sanitizeInput(nomeCientifico),
        'tipoPraga': FormValidators.sanitizeInput(tipoPraga),
      },
    );
  }

  /// Valida duplicatas
  static ValidationResult validateDuplicates(
      String value, List<String> existingValues, String fieldName) {
    if (FormValidators.checkDuplicate(value, existingValues)) {
      return ValidationResult(
        isValid: false,
        message: FormValidators.getDuplicateErrorMessage(fieldName),
      );
    }

    return ValidationResult(isValid: true);
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String? message;
  final dynamic sanitizedValue;

  ValidationResult({
    required this.isValid,
    this.message,
    this.sanitizedValue,
  });
}
