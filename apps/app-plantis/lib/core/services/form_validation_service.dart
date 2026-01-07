import 'package:core/core.dart';

import '../../features/auth/utils/validation_helpers.dart';

/// Type alias for validation results
typedef ValidationResult = Either<String, dynamic>;

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
      return const Left('Nome é obrigatório');
    }

    final trimmedName = name.trim();

    if (trimmedName.length < minNameLength) {
      return const Left('Nome deve ter pelo menos $minNameLength caractere');
    }

    if (trimmedName.length > maxNameLength) {
      return const Left('Nome deve ter no máximo $maxNameLength caracteres');
    }
    if (!_isValidPlantText(trimmedName)) {
      return const Left('Nome contém caracteres inválidos');
    }

    return Right(ValidationHelpers.sanitizePlantName(trimmedName));
  }

  /// Valida espécie da planta
  ValidationResult validateSpecies(String? species) {
    if (species == null || species.trim().isEmpty) {
      return const Right(null); // Opcional
    }

    final trimmedSpecies = species.trim();

    if (trimmedSpecies.length < minSpeciesLength) {
      return const Left(
        'Espécie deve ter pelo menos $minSpeciesLength caracteres',
      );
    }

    if (trimmedSpecies.length > maxSpeciesLength) {
      return const Left(
        'Espécie deve ter no máximo $maxSpeciesLength caracteres',
      );
    }

    if (!_isValidPlantText(trimmedSpecies)) {
      return const Left('Espécie contém caracteres inválidos');
    }

    return Right(ValidationHelpers.sanitizePlantName(trimmedSpecies));
  }

  /// Valida notas
  ValidationResult validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) {
      return const Right(null); // Opcional
    }

    final trimmedNotes = notes.trim();

    if (trimmedNotes.length > maxNotesLength) {
      return const Left('Notas devem ter no máximo $maxNotesLength caracteres');
    }

    return Right(ValidationHelpers.sanitizeNotes(trimmedNotes));
  }

  /// Valida data de plantio
  ValidationResult validatePlantingDate(DateTime? plantingDate) {
    if (plantingDate == null) {
      return const Right(null); // Opcional
    }

    final now = DateTime.now();
    final maxFutureDate = now.add(
      const Duration(days: 30),
    ); // 30 dias no futuro
    final minPastDate = DateTime(1900); // Limite mínimo razoável

    if (plantingDate.isAfter(maxFutureDate)) {
      return const Left(
        'Data de plantio não pode ser muito distante no futuro',
      );
    }

    if (plantingDate.isBefore(minPastDate)) {
      return const Left('Data de plantio inválida');
    }

    return Right(plantingDate);
  }

  /// Valida intervalo de cuidado em dias
  ValidationResult validateCareInterval(int? intervalDays, String careType) {
    if (intervalDays == null) {
      return const Right(null); // Opcional se o cuidado estiver desabilitado
    }

    if (intervalDays < minIntervalDays) {
      return Left('$careType deve ser pelo menos $minIntervalDays dia');
    }

    if (intervalDays > maxIntervalDays) {
      return Left('$careType deve ser no máximo $maxIntervalDays dias');
    }

    return Right(intervalDays);
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
    return validateCareInterval(
      intervalDays,
      'Intervalo de inspeção de pragas',
    );
  }

  /// Valida intervalo específico de replantio
  ValidationResult validateReplantingInterval(int? intervalDays) {
    return validateCareInterval(intervalDays, 'Intervalo de replantio');
  }

  /// Valida quantidade de água
  ValidationResult validateWaterAmount(String? waterAmount) {
    if (waterAmount == null || waterAmount.trim().isEmpty) {
      return const Right(null); // Opcional
    }

    final trimmedAmount = waterAmount.trim();

    if (trimmedAmount.length > 50) {
      return const Left('Quantidade de água deve ter no máximo 50 caracteres');
    }

    return Right(trimmedAmount);
  }

  /// Valida configuração de cuidado habilitada
  ValidationResult validateCareConfiguration({
    required bool isEnabled,
    required int? intervalDays,
    required String careType,
  }) {
    if (!isEnabled) {
      return const Right(null); // Desabilitado é válido
    }

    if (intervalDays == null || intervalDays <= 0) {
      return Left('$careType deve ter um intervalo válido quando habilitado');
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
      result.fold((error) => errors['watering'] = error, (_) => null);
    }
    if (enableFertilizerCare == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: fertilizingIntervalDays,
        careType: 'Fertilização',
      );
      result.fold((error) => errors['fertilizing'] = error, (_) => null);
    }
    if (enableSunlightCare == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: sunlightIntervalDays,
        careType: 'Exposição solar',
      );
      result.fold((error) => errors['sunlight'] = error, (_) => null);
    }
    if (enablePestInspection == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: pestInspectionIntervalDays,
        careType: 'Inspeção de pragas',
      );
      result.fold((error) => errors['pestInspection'] = error, (_) => null);
    }
    if (enablePruning == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: pruningIntervalDays,
        careType: 'Poda',
      );
      result.fold((error) => errors['pruning'] = error, (_) => null);
    }
    if (enableReplanting == true) {
      final result = validateCareConfiguration(
        isEnabled: true,
        intervalDays: replantingIntervalDays,
        careType: 'Replantio',
      );
      result.fold((error) => errors['replanting'] = error, (_) => null);
    }
    final waterAmountResult = validateWaterAmount(waterAmount);
    waterAmountResult.fold(
      (error) => errors['waterAmount'] = error,
      (_) => null,
    );

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
    nameResult.fold((error) => errors['name'] = error, (_) => null);

    final speciesResult = validateSpecies(species);
    speciesResult.fold((error) => errors['species'] = error, (_) => null);

    final notesResult = validateNotes(notes);
    notesResult.fold((error) => errors['notes'] = error, (_) => null);

    final plantingDateResult = validatePlantingDate(plantingDate);
    plantingDateResult.fold(
      (error) => errors['plantingDate'] = error,
      (_) => null,
    );
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
      sanitizedData: errors.isEmpty
          ? {
              'name': nameResult.fold((_) => null, (value) => value),
              'species': speciesResult.fold((_) => null, (value) => value),
              'notes': notesResult.fold((_) => null, (value) => value),
              'plantingDate': plantingDateResult.fold(
                (_) => null,
                (value) => value,
              ),
              'waterAmount': validateWaterAmount(
                waterAmount,
              ).fold((_) => null, (value) => value),
            }
          : null,
    );
  }

  /// Helper para validar texto de plantas (nome, espécie)
  bool _isValidPlantText(String text) {
    final validPattern = RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-\(\)\.\,\&]+$');
    return validPattern.hasMatch(text);
  }
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
