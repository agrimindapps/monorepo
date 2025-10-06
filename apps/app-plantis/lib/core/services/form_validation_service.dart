import '../../features/auth/utils/validation_helpers.dart';

/// Serviço responsável APENAS por validação de formulários
/// Resolve violação SRP - separando validação do estado UI
class FormValidationService {
  /// Constantes de validação para reutilização
  static const int minNameLength = 1;
  static const int maxNameLength = 50;
  static const int minSpeciesLength = 2;
  static const int maxSpeciesLength = 100;
  static const int maxNotesLength = 500;
  static const int minIntervalDays = 1;
  static const int maxIntervalDays = 3650; // ~10 anos
  
  /// Valida nome da planta
  ValidationResult validatePlantName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.error('Nome é obrigatório');
    }
    
    final trimmedName = name.trim();
    
    if (trimmedName.length < minNameLength) {
      return ValidationResult.error('Nome deve ter pelo menos $minNameLength caractere');
    }
    
    if (trimmedName.length > maxNameLength) {
      return ValidationResult.error('Nome deve ter no máximo $maxNameLength caracteres');
    }
    if (!_isValidPlantText(trimmedName)) {
      return ValidationResult.error('Nome contém caracteres inválidos');
    }
    
    return ValidationResult.success(ValidationHelpers.sanitizePlantName(trimmedName));
  }
  
  /// Valida espécie da planta
  ValidationResult validateSpecies(String? species) {
    if (species == null || species.trim().isEmpty) {
      return ValidationResult.success(null); // Opcional
    }
    
    final trimmedSpecies = species.trim();
    
    if (trimmedSpecies.length < minSpeciesLength) {
      return ValidationResult.error('Espécie deve ter pelo menos $minSpeciesLength caracteres');
    }
    
    if (trimmedSpecies.length > maxSpeciesLength) {
      return ValidationResult.error('Espécie deve ter no máximo $maxSpeciesLength caracteres');
    }
    
    if (!_isValidPlantText(trimmedSpecies)) {
      return ValidationResult.error('Espécie contém caracteres inválidos');
    }
    
    return ValidationResult.success(ValidationHelpers.sanitizePlantName(trimmedSpecies));
  }
  
  /// Valida notas
  ValidationResult validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) {
      return ValidationResult.success(null); // Opcional
    }
    
    final trimmedNotes = notes.trim();
    
    if (trimmedNotes.length > maxNotesLength) {
      return ValidationResult.error('Notas devem ter no máximo $maxNotesLength caracteres');
    }
    
    return ValidationResult.success(ValidationHelpers.sanitizeNotes(trimmedNotes));
  }
  
  /// Valida data de plantio
  ValidationResult validatePlantingDate(DateTime? plantingDate) {
    if (plantingDate == null) {
      return ValidationResult.success(null); // Opcional
    }
    
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 30)); // 30 dias no futuro
    final minPastDate = DateTime(1900); // Limite mínimo razoável
    
    if (plantingDate.isAfter(maxFutureDate)) {
      return ValidationResult.error('Data de plantio não pode ser muito distante no futuro');
    }
    
    if (plantingDate.isBefore(minPastDate)) {
      return ValidationResult.error('Data de plantio inválida');
    }
    
    return ValidationResult.success(plantingDate);
  }
  
  /// Valida intervalo de cuidado em dias
  ValidationResult validateCareInterval(int? intervalDays, String careType) {
    if (intervalDays == null) {
      return ValidationResult.success(null); // Opcional se o cuidado estiver desabilitado
    }
    
    if (intervalDays < minIntervalDays) {
      return ValidationResult.error('$careType deve ser pelo menos $minIntervalDays dia');
    }
    
    if (intervalDays > maxIntervalDays) {
      return ValidationResult.error('$careType deve ser no máximo $maxIntervalDays dias');
    }
    
    return ValidationResult.success(intervalDays);
  }
  
  /// Valida intervalo específico de rega
  ValidationResult validateWateringInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de rega');
  }
  
  /// Valida intervalo específico de fertilização
  ValidationResult validateFertilizingInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de fertilização');
  }
  
  /// Valida intervalo específico de poda
  ValidationResult validatePruningInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de poda');
  }
  
  /// Valida intervalo específico de luz solar
  ValidationResult validateSunlightInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de exposição solar');
  }
  
  /// Valida intervalo específico de inspeção de pragas
  ValidationResult validatePestInspectionInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de inspeção de pragas');
  }
  
  /// Valida intervalo específico de replantio
  ValidationResult validateReplantingInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de replantio');
  }
  
  /// Valida quantidade de água
  ValidationResult validateWaterAmount(String? waterAmount) {
    if (waterAmount == null || waterAmount.trim().isEmpty) {
      return ValidationResult.success(null); // Opcional
    }
    
    final trimmedAmount = waterAmount.trim();
    
    if (trimmedAmount.length > 50) {
      return ValidationResult.error('Quantidade de água deve ter no máximo 50 caracteres');
    }
    
    return ValidationResult.success(trimmedAmount);
  }
  
  /// Valida configuração de cuidado habilitada
  ValidationResult validateCareConfiguration({
    required bool isEnabled,
    required int? intervalDays,
    required String careType,
  }) {
    if (!isEnabled) {
      return ValidationResult.success(null); // Desabilitado é válido
    }
    
    if (intervalDays == null || intervalDays <= 0) {
      return ValidationResult.error('$careType deve ter um intervalo válido quando habilitado');
    }
    
    return validateCareInterval(intervalDays, careType);
  }
  
  /// Valida todas as configurações de cuidado de uma vez
  PlantCareValidationResult validatePlantCareConfiguration({
    bool? enableWateringCare,
    int? wateringIntervalDays,
    bool? enableFertilizerCare,
    int? fertilizingIntervalDays,
    bool? enableSunlightCare,
    int? sunlightIntervalDays,
    bool? enablePestInspection,
    int? pestInspectionIntervalDays,
    bool? enablePruning,
    int? pruningIntervalDays,
    bool? enableReplanting,
    int? replantingIntervalDays,
    String? waterAmount,
  }) {
    final errors = <String, String>{};
    if (enableWateringCare == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: wateringIntervalDays,
        careType: 'Rega',
      );
      if (result.hasError) {
        errors['watering'] = result.error!;
      }
    }
    if (enableFertilizerCare == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: fertilizingIntervalDays,
        careType: 'Fertilização',
      );
      if (result.hasError) {
        errors['fertilizing'] = result.error!;
      }
    }
    if (enableSunlightCare == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: sunlightIntervalDays,
        careType: 'Exposição solar',
      );
      if (result.hasError) {
        errors['sunlight'] = result.error!;
      }
    }
    if (enablePestInspection == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: pestInspectionIntervalDays,
        careType: 'Inspeção de pragas',
      );
      if (result.hasError) {
        errors['pestInspection'] = result.error!;
      }
    }
    if (enablePruning == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: pruningIntervalDays,
        careType: 'Poda',
      );
      if (result.hasError) {
        errors['pruning'] = result.error!;
      }
    }
    if (enableReplanting == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: replantingIntervalDays,
        careType: 'Replantio',
      );
      if (result.hasError) {
        errors['replanting'] = result.error!;
      }
    }
    final waterAmountResult = validateWaterAmount(waterAmount);
    if (waterAmountResult.hasError) {
      errors['waterAmount'] = waterAmountResult.error!;
    }
    
    return PlantCareValidationResult(errors);
  }
  
  /// Valida formulário completo da planta
  FormValidationResult validatePlantForm({
    required String? name,
    String? species,
    String? notes,
    DateTime? plantingDate,
    bool? enableWateringCare,
    int? wateringIntervalDays,
    bool? enableFertilizerCare,
    int? fertilizingIntervalDays,
    bool? enableSunlightCare,
    int? sunlightIntervalDays,
    bool? enablePestInspection,
    int? pestInspectionIntervalDays,
    bool? enablePruning,
    int? pruningIntervalDays,
    bool? enableReplanting,
    int? replantingIntervalDays,
    String? waterAmount,
  }) {
    final errors = <String, String>{};
    final nameResult = validatePlantName(name);
    if (nameResult.hasError) {
      errors['name'] = nameResult.error!;
    }
    
    final speciesResult = validateSpecies(species);
    if (speciesResult.hasError) {
      errors['species'] = speciesResult.error!;
    }
    
    final notesResult = validateNotes(notes);
    if (notesResult.hasError) {
      errors['notes'] = notesResult.error!;
    }
    
    final plantingDateResult = validatePlantingDate(plantingDate);
    if (plantingDateResult.hasError) {
      errors['plantingDate'] = plantingDateResult.error!;
    }
    final careValidation = validatePlantCareConfiguration(
      enableWateringCare: enableWateringCare,
      wateringIntervalDays: wateringIntervalDays,
      enableFertilizerCare: enableFertilizerCare,
      fertilizingIntervalDays: fertilizingIntervalDays,
      enableSunlightCare: enableSunlightCare,
      sunlightIntervalDays: sunlightIntervalDays,
      enablePestInspection: enablePestInspection,
      pestInspectionIntervalDays: pestInspectionIntervalDays,
      enablePruning: enablePruning,
      pruningIntervalDays: pruningIntervalDays,
      enableReplanting: enableReplanting,
      replantingIntervalDays: replantingIntervalDays,
      waterAmount: waterAmount,
    );
    
    errors.addAll(careValidation.errors);
    
    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      sanitizedData: errors.isEmpty ? {
        'name': nameResult.value,
        'species': speciesResult.value,
        'notes': notesResult.value,
        'plantingDate': plantingDateResult.value,
        'waterAmount': validateWaterAmount(waterAmount).value,
      } : null,
    );
  }
  
  /// Helper para validar texto de plantas (nome, espécie)
  bool _isValidPlantText(String text) {
    final validPattern = RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\(\)\.\,\&]+$');
    return validPattern.hasMatch(text);
  }
}

/// Resultado de validação individual
class ValidationResult {
  final bool isValid;
  final String? error;
  final dynamic value;
  
  const ValidationResult._({
    required this.isValid,
    this.error,
    this.value,
  });
  
  factory ValidationResult.success(dynamic value) {
    return ValidationResult._(isValid: true, value: value);
  }
  
  factory ValidationResult.error(String error) {
    return ValidationResult._(isValid: false, error: error);
  }
  
  bool get hasError => error != null;
}

/// Resultado de validação de configurações de cuidado
class PlantCareValidationResult {
  final Map<String, String> errors;
  
  const PlantCareValidationResult(this.errors);
  
  bool get isValid => errors.isEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Resultado de validação completa do formulário
class FormValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, dynamic>? sanitizedData;
  
  const FormValidationResult({
    required this.isValid,
    required this.errors,
    this.sanitizedData,
  });
  
  bool get hasErrors => errors.isNotEmpty;
  
  String? getFieldError(String fieldName) => errors[fieldName];
  
  bool hasFieldError(String fieldName) => errors.containsKey(fieldName);
}
