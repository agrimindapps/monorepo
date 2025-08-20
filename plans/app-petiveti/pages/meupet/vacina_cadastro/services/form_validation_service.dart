// Project imports:
import 'vacina_validation_rules.dart';

/// Service for form validation logic
/// 
/// This service acts as the application layer for form validation,
/// delegating to VacinaValidationRules for business logic and providing
/// form-specific enhancements like timestamp conversion and error handling.
class FormValidationService {
  
  /// Validates vaccine name field
  String? validateVaccineName(String? name) {
    return VacinaValidationRules.validateVaccineName(name);
  }

  /// Validates application date field (converts timestamp to DateTime)
  String? validateApplicationDate(int? timestamp) {
    if (timestamp == null || timestamp <= 0) {
      return 'Data de aplicação é obrigatória';
    }
    
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return VacinaValidationRules.validateApplicationDate(date);
  }

  /// Validates next dose date field (converts timestamp to DateTime)
  String? validateNextDoseDate(int? nextDoseTimestamp, int? applicationTimestamp) {
    if (nextDoseTimestamp == null || nextDoseTimestamp <= 0) {
      return 'Data da próxima dose é obrigatória';
    }
    
    final nextDoseDate = DateTime.fromMillisecondsSinceEpoch(nextDoseTimestamp);
    DateTime? applicationDate;
    
    if (applicationTimestamp != null && applicationTimestamp > 0) {
      applicationDate = DateTime.fromMillisecondsSinceEpoch(applicationTimestamp);
    }
    
    return VacinaValidationRules.validateNextDoseDate(nextDoseDate, applicationDate);
  }

  /// Validates observations field
  String? validateObservations(String? observations) {
    return VacinaValidationRules.validateObservations(observations);
  }

  /// Validates animal ID field
  String? validateAnimalId(String? animalId) {
    return VacinaValidationRules.validateAnimalId(animalId);
  }

  /// Validates all form fields at once
  Map<String, String?> validateAllFields({
    required String? animalId,
    required String? nomeVacina,
    required int? dataAplicacao,
    required int? proximaDose,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'nomeVacina': validateVaccineName(nomeVacina),
      'dataAplicacao': validateApplicationDate(dataAplicacao),
      'proximaDose': validateNextDoseDate(proximaDose, dataAplicacao),
      'observacoes': validateObservations(observacoes),
    };
  }

  /// Validates all form fields using DateTime objects directly
  Map<String, String?> validateAllFieldsWithDates({
    required String? animalId,
    required String? nomeVacina,
    required DateTime? dataAplicacao,
    required DateTime? proximaDose,
    String? observacoes,
  }) {
    final errors = VacinaValidationRules.validateCompleteVaccineData(
      animalId: animalId,
      vaccineName: nomeVacina,
      applicationDate: dataAplicacao,
      nextDoseDate: proximaDose,
      observations: observacoes,
    );
    
    // Convert to nullable map for consistency with existing API
    return {
      'animalId': errors['animalId'],
      'nomeVacina': errors['vaccineName'],
      'dataAplicacao': errors['applicationDate'],
      'proximaDose': errors['nextDoseDate'],
      'observacoes': errors['observations'],
    };
  }

  /// Checks if all validations pass
  bool isFormValid({
    required String? animalId,
    required String? nomeVacina,
    required int? dataAplicacao,
    required int? proximaDose,
    String? observacoes,
  }) {
    final errors = validateAllFields(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );
    
    return errors.values.every((error) => error == null);
  }

  /// Gets validation errors for display
  List<String> getValidationErrors({
    required String? animalId,
    required String? nomeVacina,
    required int? dataAplicacao,
    required int? proximaDose,
    String? observacoes,
  }) {
    final errors = validateAllFields(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );
    
    return errors.values
        .where((error) => error != null)
        .cast<String>()
        .toList();
  }

  /// Validates specific field based on field name
  String? validateField(String fieldName, dynamic value, {Map<String, dynamic>? context}) {
    switch (fieldName) {
      case 'nomeVacina':
        return validateVaccineName(value as String?);
      case 'dataAplicacao':
        return validateApplicationDate(value as int?);
      case 'proximaDose':
        final applicationDate = context?['dataAplicacao'] as int?;
        return validateNextDoseDate(value as int?, applicationDate);
      case 'observacoes':
        return validateObservations(value as String?);
      case 'animalId':
        return validateAnimalId(value as String?);
      default:
        return null;
    }
  }

  /// Gets field-specific validation message
  String getFieldValidationMessage(String fieldName) {
    switch (fieldName) {
      case 'nomeVacina':
        return 'Digite o nome da vacina (mínimo 2 caracteres)';
      case 'dataAplicacao':
        return 'Selecione a data de aplicação da vacina';
      case 'proximaDose':
        return 'Selecione a data da próxima dose';
      case 'observacoes':
        return 'Observações adicionais (opcional, máximo 500 caracteres)';
      case 'animalId':
        return 'Selecione o animal para vacinar';
      default:
        return 'Campo obrigatório';
    }
  }

  /// Checks if field should show validation error
  bool shouldShowFieldError(String fieldName, bool isTouched, String? error) {
    return isTouched && error != null;
  }

  /// Gets priority level for validation error
  ValidationPriority getErrorPriority(String? error) {
    if (error == null) return ValidationPriority.none;
    
    if (error.contains('obrigatório') || error.contains('selecionado')) {
      return ValidationPriority.high;
    } else if (error.contains('inválido') || error.contains('muito')) {
      return ValidationPriority.medium;
    } else {
      return ValidationPriority.low;
    }
  }

  /// Sanitizes vaccine name input before validation
  String sanitizeVaccineName(String input) {
    return VacinaValidationRules.sanitizeVaccineName(input);
  }

  /// Sanitizes observations input before validation
  String sanitizeObservations(String input) {
    return VacinaValidationRules.sanitizeObservations(input);
  }

  /// Generic input sanitization (deprecated - use specific methods)
  @Deprecated('Use sanitizeVaccineName or sanitizeObservations instead')
  String sanitizeInput(String input) {
    return VacinaValidationRules.sanitizeVaccineName(input);
  }

  /// Gets suggested corrections for common validation errors
  String? getSuggestedCorrection(String fieldName, String? error) {
    if (error == null) return null;
    
    switch (fieldName) {
      case 'nomeVacina':
        if (error.contains('2 caracteres')) {
          return 'Tente: "V8", "V10", "Raiva", "Múltipla"';
        }
        break;
      case 'dataAplicacao':
        if (error.contains('futuro')) {
          return 'Use a data de hoje ou anterior';
        }
        break;
      case 'proximaDose':
        if (error.contains('1 dia')) {
          return 'A próxima dose deve ser pelo menos amanhã';
        }
        break;
    }
    
    return null;
  }
}

/// Enum for validation error priorities
enum ValidationPriority {
  none,
  low,
  medium,
  high,
}
