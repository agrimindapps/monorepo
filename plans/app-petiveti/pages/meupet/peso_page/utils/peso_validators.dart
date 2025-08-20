// Project imports:
import '../../../../../../app-petiveti/utils/peso/peso_validators.dart' as peso_validators;

class PesoValidators {
  static const double minPeso = 0.01;
  static const double maxPeso = 500.0;
  static const int maxObservacoesLength = 500;

  // Delegated validation functions to centralized utils
  static String? validatePeso(String? value) => peso_validators.PesoValidators.validatePeso(value);
  static String? validateDogPeso(String? value) => peso_validators.PesoValidators.validateDogPeso(value);
  static String? validateCatPeso(String? value) => peso_validators.PesoValidators.validateCatPeso(value);
  static String? validatePesoChange(double currentPeso, double? previousPeso) => peso_validators.PesoValidators.validatePesoChange(currentPeso, previousPeso);
  static String? validatePesoForAge(double peso, DateTime birthDate, String animalType) => peso_validators.PesoValidators.validatePesoForAge(peso, birthDate, animalType);

  // Date validation functions
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Data é obrigatória';
    }
    
    final now = DateTime.now();
    
    if (date.isAfter(now)) {
      return 'Data não pode ser no futuro';
    }
    
    if (date.year < 1900) {
      return 'Data muito antiga';
    }
    
    // Check if date is more than 10 years old
    final tenYearsAgo = now.subtract(const Duration(days: 365 * 10));
    if (date.isBefore(tenYearsAgo)) {
      return 'Data muito antiga para um registro de peso';
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

  // Animal validation
  static String? validateAnimalSelection(String? animalId) {
    if (animalId == null || animalId.trim().isEmpty) {
      return 'Selecione um animal';
    }
    
    return null;
  }

  static String? validateAnimalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecione um animal';
    }
    return null;
  }

  // Observations validation
  static String? validateObservations(String? value) {
    if (value != null && value.length > 500) {
      return 'Observações devem ter no máximo 500 caracteres';
    }
    
    // Check for invalid characters
    if (value != null && !_hasValidCharacters(value)) {
      return 'Observações contêm caracteres inválidos';
    }
    
    return null;
  }

  static String? validateObservacoes(String? value) {
    if (value != null && value.length > maxObservacoesLength) {
      return 'Observações não podem exceder $maxObservacoesLength caracteres';
    }
    return null;
  }

  // Range validations
  static String? validatePesoRange(double? min, double? max) {
    if (min != null && max != null) {
      if (min > max) {
        return 'Peso mínimo não pode ser maior que o máximo';
      }
      
      if (min < 0) {
        return 'Peso mínimo deve ser positivo';
      }
      
      if (max > 200) {
        return 'Peso máximo muito alto';
      }
    }
    
    return null;
  }

  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      if (start.isAfter(end)) {
        return 'Data inicial não pode ser posterior à data final';
      }
      
      final now = DateTime.now();
      if (start.isAfter(now) || end.isAfter(now)) {
        return 'Datas não podem ser no futuro';
      }
      
      // Check for reasonable date range (not more than 20 years)
      final twentyYearsAgo = now.subtract(const Duration(days: 365 * 20));
      if (start.isBefore(twentyYearsAgo)) {
        return 'Data inicial muito antiga';
      }
    }
    
    return null;
  }

  // Combined validators
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) return error;
    }
    return null;
  }

  static Map<String, String?> validatePesoForm({
    required String? peso,
    required DateTime? date,
    required String? animalId,
    String? observations,
    String? animalType,
  }) {
    final errors = <String, String?>{};

    // Validate peso based on animal type
    String? pesoError;
    if (animalType == 'Cachorro') {
      pesoError = validateDogPeso(peso);
    } else if (animalType == 'Gato') {
      pesoError = validateCatPeso(peso);
    } else {
      pesoError = validatePeso(peso);
    }

    if (pesoError != null) {
      errors['peso'] = pesoError;
    }

    // Validate other fields
    final dateError = validateDate(date);
    if (dateError != null) {
      errors['date'] = dateError;
    }

    final animalError = validateAnimalSelection(animalId);
    if (animalError != null) {
      errors['animal'] = animalError;
    }

    final observationsError = validateObservations(observations);
    if (observationsError != null) {
      errors['observations'] = observationsError;
    }

    return errors;
  }

  static bool isFormValid({
    required String? peso,
    required DateTime? date,
    required String? animalId,
    String? observations,
    String? animalType,
  }) {
    final errors = validatePesoForm(
      peso: peso,
      date: date,
      animalId: animalId,
      observations: observations,
      animalType: animalType,
    );
    
    return errors.isEmpty;
  }

  static Map<String, String?> validateAllFields({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
  }) {
    return {
      'animalId': validateAnimalId(animalId),
      'peso': peso_validators.PesoValidators.validatePesoValue(peso),
      'dataPesagem': validateDataPesagem(dataPesagem),
      'observacoes': validateObservacoes(observacoes),
    };
  }

  static bool isFormValidWithValues({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
  }) {
    return validateAnimalId(animalId) == null &&
           peso_validators.PesoValidators.validatePesoValue(peso) == null &&
           validateDataPesagem(dataPesagem) == null &&
           validateObservacoes(observacoes) == null;
  }

  // Search validation
  static String? validateSearchQuery(String? query) {
    if (query != null && query.length > 100) {
      return 'Termo de busca muito longo';
    }
    
    return null;
  }

  // Helper functions
  static bool _hasValidCharacters(String input) {
    // Allow letters, numbers, spaces, and common punctuation
    final validPattern = RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\.,;:!?\-()]+$');
    return validPattern.hasMatch(input);
  }
}
