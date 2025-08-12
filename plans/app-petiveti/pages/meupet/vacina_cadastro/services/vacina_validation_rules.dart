/// Core domain validation rules for vaccine operations
/// 
/// This class serves as the single source of truth for all vaccine-related
/// validation logic. It contains business rules, data integrity validation,
/// and domain constraints.
/// 
/// All other validation services should delegate to this class to ensure
/// consistency across the application.
class VacinaValidationRules {
  // Business rule constants
  static const int minVaccineNameLength = 2;
  static const int maxVaccineNameLength = 100;
  static const int maxObservationsLength = 500;
  static const int minDoseIntervalDays = 1;
  static const int maxFutureDateYears = 10;
  static const int minValidYear = 1900;

  // Character validation patterns
  static const Set<String> invalidCharacters = {
    '<', '>', '"', "'", '/', '&', '`'
  };
  
  static const List<String> dangerousPatterns = [
    '<script',
    'javascript:',
    'data:',
    'vbscript:',
    'onload=',
    'onerror=',
  ];

  /// Validates vaccine name according to business rules
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateVaccineName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Nome da vacina é obrigatório';
    }

    final trimmedName = name.trim();

    if (trimmedName.length < minVaccineNameLength) {
      return 'Nome da vacina deve ter pelo menos $minVaccineNameLength caracteres';
    }

    if (trimmedName.length > maxVaccineNameLength) {
      return 'Nome da vacina deve ter no máximo $maxVaccineNameLength caracteres';
    }

    // Check for invalid characters
    for (final char in invalidCharacters) {
      if (trimmedName.contains(char)) {
        return 'Nome da vacina contém caracteres inválidos';
      }
    }

    // Check for dangerous patterns
    final lowerName = trimmedName.toLowerCase();
    for (final pattern in dangerousPatterns) {
      if (lowerName.contains(pattern)) {
        return 'Nome da vacina contém conteúdo inválido';
      }
    }

    return null;
  }

  /// Validates application date according to business rules
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateApplicationDate(DateTime? date) {
    if (date == null) {
      return 'Data de aplicação é obrigatória';
    }

    final now = DateTime.now();
    final minDate = DateTime(minValidYear);
    final maxDate = now.add(const Duration(hours: 24)); // Allow up to tomorrow

    if (date.isBefore(minDate)) {
      return 'Data de aplicação muito antiga';
    }

    if (date.isAfter(maxDate)) {
      return 'Data de aplicação não pode ser no futuro';
    }

    return null;
  }

  /// Validates next dose date according to business rules
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateNextDoseDate(DateTime? nextDose, DateTime? applicationDate) {
    if (nextDose == null) {
      return 'Data da próxima dose é obrigatória';
    }

    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365 * 10));

    if (nextDose.isAfter(maxDate)) {
      return 'Data da próxima dose muito distante (máximo $maxFutureDateYears anos)';
    }

    // If application date is provided, validate interval
    if (applicationDate != null) {
      if (nextDose.isBefore(applicationDate)) {
        return 'Próxima dose deve ser após a data de aplicação';
      }

      if (!isValidDoseInterval(applicationDate, nextDose)) {
        return 'Próxima dose deve ser pelo menos $minDoseIntervalDays dia(s) após a aplicação';
      }
    }

    return null;
  }

  /// Validates observations according to business rules
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateObservations(String? observations) {
    if (observations == null || observations.trim().isEmpty) {
      return null; // Observations are optional
    }

    final trimmedObs = observations.trim();

    if (trimmedObs.length > maxObservationsLength) {
      return 'Observações devem ter no máximo $maxObservationsLength caracteres';
    }

    // Check for dangerous patterns
    final lowerObs = trimmedObs.toLowerCase();
    for (final pattern in dangerousPatterns) {
      if (lowerObs.contains(pattern)) {
        return 'Observações contêm conteúdo inválido';
      }
    }

    return null;
  }

  /// Validates animal ID according to business rules
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateAnimalId(String? animalId) {
    if (animalId == null || animalId.trim().isEmpty) {
      return 'ID do animal é obrigatório';
    }

    if (animalId.trim().isEmpty) {
      return 'ID do animal inválido';
    }

    return null;
  }

  /// Validates dose interval between application and next dose
  /// 
  /// Returns true if interval is valid (at least minimum days)
  static bool isValidDoseInterval(DateTime applicationDate, DateTime nextDoseDate) {
    final difference = nextDoseDate.difference(applicationDate).inDays;
    return difference >= minDoseIntervalDays;
  }

  /// Validates complete vaccine data
  /// 
  /// Returns map of field errors, empty if all valid
  static Map<String, String> validateCompleteVaccineData({
    required String? animalId,
    required String? vaccineName,
    required DateTime? applicationDate,
    required DateTime? nextDoseDate,
    String? observations,
  }) {
    final errors = <String, String>{};

    final animalIdError = validateAnimalId(animalId);
    if (animalIdError != null) {
      errors['animalId'] = animalIdError;
    }

    final vaccineNameError = validateVaccineName(vaccineName);
    if (vaccineNameError != null) {
      errors['vaccineName'] = vaccineNameError;
    }

    final applicationDateError = validateApplicationDate(applicationDate);
    if (applicationDateError != null) {
      errors['applicationDate'] = applicationDateError;
    }

    final nextDoseDateError = validateNextDoseDate(nextDoseDate, applicationDate);
    if (nextDoseDateError != null) {
      errors['nextDoseDate'] = nextDoseDateError;
    }

    final observationsError = validateObservations(observations);
    if (observationsError != null) {
      errors['observations'] = observationsError;
    }

    return errors;
  }

  /// Checks if vaccine data is valid (no validation errors)
  static bool isVaccineDataValid({
    required String? animalId,
    required String? vaccineName,
    required DateTime? applicationDate,
    required DateTime? nextDoseDate,
    String? observations,
  }) {
    final errors = validateCompleteVaccineData(
      animalId: animalId,
      vaccineName: vaccineName,
      applicationDate: applicationDate,
      nextDoseDate: nextDoseDate,
      observations: observations,
    );
    return errors.isEmpty;
  }

  /// Sanitizes vaccine name input
  static String sanitizeVaccineName(String input) {
    var sanitized = input.trim();
    
    // Remove invalid characters
    for (final char in invalidCharacters) {
      sanitized = sanitized.replaceAll(char, '');
    }
    
    // Remove dangerous patterns
    for (final pattern in dangerousPatterns) {
      sanitized = sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }
    
    // Replace multiple spaces with single space
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    return sanitized.trim();
  }

  /// Sanitizes observations input
  static String sanitizeObservations(String input) {
    var sanitized = input.trim();
    
    // Remove dangerous patterns
    for (final pattern in dangerousPatterns) {
      sanitized = sanitized.replaceAll(RegExp(pattern, caseSensitive: false), '');
    }
    
    // Replace multiple spaces and newlines with appropriate spacing
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    return sanitized.trim();
  }

  /// Validates business rules for vaccine creation/update
  static List<String> validateBusinessRules({
    required String? animalId,
    required String? vaccineName,
    required DateTime? applicationDate,
    required DateTime? nextDoseDate,
    String? observations,
    bool isUpdate = false,
  }) {
    final violations = <String>[];

    // Check basic validation first
    final errors = validateCompleteVaccineData(
      animalId: animalId,
      vaccineName: vaccineName,
      applicationDate: applicationDate,
      nextDoseDate: nextDoseDate,
      observations: observations,
    );

    violations.addAll(errors.values);

    // Additional business rules
    if (applicationDate != null && nextDoseDate != null) {
      final now = DateTime.now();
      
      // Warn if application date is too recent for next dose calculation
      if (applicationDate.isAfter(now.subtract(const Duration(hours: 1)))) {
        // This is just a warning, not an error
      }
      
      // Check if next dose is too far in the future
      if (nextDoseDate.isAfter(now.add(const Duration(days: 365 * 2)))) {
        violations.add('Próxima dose está muito distante no futuro (mais de 2 anos)');
      }
    }

    return violations;
  }

  /// Validates if vaccine can be deleted
  static bool canDeleteVaccine({
    required DateTime applicationDate,
    required bool hasRelatedRecords,
  }) {
    // Cannot delete if there are related records
    if (hasRelatedRecords) {
      return false;
    }

    // Cannot delete if application was very recent (less than 1 hour ago)
    final now = DateTime.now();
    final timeSinceApplication = now.difference(applicationDate);
    
    return timeSinceApplication.inHours >= 1;
  }
}