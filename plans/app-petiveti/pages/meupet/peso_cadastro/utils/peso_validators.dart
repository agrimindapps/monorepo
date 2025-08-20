// Project imports:
import '../../../../../../app-petiveti/utils/peso/peso_core.dart' as peso_core;
import '../../../../../../app-petiveti/utils/peso/peso_validators.dart' as peso_validators;

class PesoValidators {
  static const double minPeso = 0.01;
  static const double maxPeso = 500.0;
  static const int maxObservacoesLength = 500;

  // Delegated validation functions to centralized utils
  static String? validatePeso(double? value) {
    return peso_validators.PesoValidators.validatePesoValue(value);
  }

  static String? validatePesoString(String? value) {
    return peso_validators.PesoValidators.validatePeso(value);
  }

  static String? validateDogPeso(String? value) => peso_validators.PesoValidators.validateDogPeso(value);
  static String? validateCatPeso(String? value) => peso_validators.PesoValidators.validateCatPeso(value);
  static String? validatePesoChange(double currentPeso, double? previousPeso) => peso_validators.PesoValidators.validatePesoChange(currentPeso, previousPeso);
  static String? validatePesoForAge(double peso, DateTime birthDate, String animalType) => peso_validators.PesoValidators.validatePesoForAge(peso, birthDate, animalType);

  static String? validateAnimalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecione um animal';
    }
    return null;
  }

  static String? validateObservacoes(String? value) {
    if (value != null && value.length > maxObservacoesLength) {
      return 'Observações não podem exceder $maxObservacoesLength caracteres';
    }
    return null;
  }

  static String? validateDataPesagem(DateTime? value) {
    if (value == null) {
      return 'Data é obrigatória';
    }
    if (value.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    if (value.isBefore(oneYearAgo)) {
      return 'A data não pode ser anterior a um ano';
    }
    return null;
  }

  static bool isFormValid({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
  }) {
    return validateAnimalId(animalId) == null &&
           validatePeso(peso) == null &&
           validateDataPesagem(dataPesagem) == null &&
           validateObservacoes(observacoes) == null;
  }

  static Map<String, String?> validateAllFields({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'peso': validatePeso(peso),
      'dataPesagem': validateDataPesagem(dataPesagem),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  // Extended validation for form with string inputs
  static Map<String, String?> validateFormFields({
    required String animalId,
    required String? pesoString,
    required DateTime? dataPesagem,
    String? observacoes,
    String? animalType,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    // Validate peso based on animal type
    String? pesoError;
    if (animalType == 'Cachorro') {
      pesoError = validateDogPeso(pesoString);
    } else if (animalType == 'Gato') {
      pesoError = validateCatPeso(pesoString);
    } else {
      pesoError = validatePesoString(pesoString);
    }

    if (pesoError != null) {
      errors['peso'] = pesoError;
    }

    final dateError = validateDataPesagem(dataPesagem);
    if (dateError != null) {
      errors['dataPesagem'] = dateError;
    }

    final observacoesError = validateObservacoes(observacoes);
    if (observacoesError != null) {
      errors['observacoes'] = observacoesError;
    }

    return errors;
  }

  // Form validation with string inputs
  static bool isFormValidWithStrings({
    required String animalId,
    required String? pesoString,
    required DateTime? dataPesagem,
    String? observacoes,
    String? animalType,
  }) {
    final errors = validateFormFields(
      animalId: animalId,
      pesoString: pesoString,
      dataPesagem: dataPesagem,
      observacoes: observacoes,
      animalType: animalType,
    );
    
    return errors.values.every((error) => error == null);
  }

  // Real-time validation helpers
  static String? validatePesoRealTime(String? value, String? animalType) {
    if (value == null || value.trim().isEmpty) {
      return null; // Don't show error for empty field in real-time
    }

    if (animalType == 'Cachorro') {
      return validateDogPeso(value);
    } else if (animalType == 'Gato') {
      return validateCatPeso(value);
    } else {
      return validatePesoString(value);
    }
  }

  static String? validateObservacoesRealTime(String? value) {
    if (value != null && value.length > maxObservacoesLength) {
      return 'Máximo $maxObservacoesLength caracteres';
    }
    return null;
  }

  // Contextual validation
  static List<String> validateWithContext({
    required String animalId,
    required String? pesoString,
    required DateTime? dataPesagem,
    String? observacoes,
    String? animalType,
    DateTime? animalBirthDate,
    double? lastRegisteredPeso,
  }) {
    final warnings = <String>[];
    final errors = validateFormFields(
      animalId: animalId,
      pesoString: pesoString,
      dataPesagem: dataPesagem,
      observacoes: observacoes,
      animalType: animalType,
    );

    // Add errors as warnings
    warnings.addAll(errors.values.where((error) => error != null).cast<String>());

    // Additional contextual validations
    if (pesoString != null && pesoString.isNotEmpty) {
      final peso = peso_core.PesoCore.parsePeso(pesoString);
      if (peso != null) {
        // Check for significant weight change
        if (lastRegisteredPeso != null) {
          final changeValidation = validatePesoChange(peso, lastRegisteredPeso);
          if (changeValidation != null) {
            warnings.add('Aviso: $changeValidation');
          }
        }

        // Check for age-appropriate weight
        if (animalBirthDate != null && animalType != null) {
          final ageValidation = validatePesoForAge(peso, animalBirthDate, animalType);
          if (ageValidation != null) {
            warnings.add('Aviso: $ageValidation');
          }
        }
      }
    }

    return warnings;
  }

  // Get validation severity
  static String getValidationSeverity(String? error) {
    if (error == null) return 'valid';
    
    if (error.startsWith('Aviso:')) {
      return 'warning';
    } else if (error.contains('obrigatório')) {
      return 'error';
    } else {
      return 'error';
    }
  }

  // Format validation message for UI
  static String formatValidationMessage(String? error) {
    if (error == null) return '';
    
    // Remove 'Aviso: ' prefix if present
    if (error.startsWith('Aviso: ')) {
      return error.substring(7);
    }
    
    return error;
  }
}
