import 'package:injectable/injectable.dart';

import '../entities/bovine_entity.dart';
import 'livestock_validation_service.dart';

/// Service especializado para operações de formulário de bovinos
/// 
/// Responsabilidades:
/// - Gerenciar estado do formulário
/// - Validação de campos específicos
/// - Transformação de dados
/// - Lógica de negócio do formulário
@singleton
class BovineFormService {
  final LivestockValidationService _validationService;

  BovineFormService(_validationService);

  // =====================================================================
  // VALIDATION METHODS
  // =====================================================================

  /// Valida nome comum
  String? validateCommonName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome comum é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (value.trim().length > 50) {
      return 'Nome deve ter no máximo 50 caracteres';
    }
    return null;
  }

  /// Valida ID de registro
  String? validateRegistrationId(String? value) {
    // ID é opcional, se vazio será gerado automaticamente
    if (value == null || value.trim().isEmpty) {
      return null; // Válido para criação
    }
    
    if (value.length < 3) {
      return 'ID deve ter pelo menos 3 caracteres';
    }
    if (value.length > 20) {
      return 'ID deve ter no máximo 20 caracteres';
    }
    
    final regExp = RegExp(r'^[A-Z0-9\-_]{3,20}$');
    if (!regExp.hasMatch(value)) {
      return 'Use apenas letras maiúsculas, números, hífens e underscores';
    }
    
    return null;
  }

  /// Valida raça
  String? validateBreed(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Raça é obrigatória';
    }
    if (value.trim().length < 2) {
      return 'Raça deve ter pelo menos 2 caracteres';
    }
    if (value.trim().length > 30) {
      return 'Raça deve ter no máximo 30 caracteres';
    }
    return null;
  }

  /// Valida país de origem
  String? validateOriginCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'País de origem é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'País deve ter pelo menos 2 caracteres';
    }
    if (!_validationService.isValidOriginCountry(value.trim())) {
      return 'País de origem não reconhecido';
    }
    return null;
  }

  /// Valida tipo de animal
  String? validateAnimalType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tipo de animal é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Tipo deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  /// Valida origem detalhada
  String? validateOrigin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Origem é obrigatória';
    }
    if (value.trim().length < 5) {
      return 'Origem deve ter pelo menos 5 caracteres';
    }
    return null;
  }

  /// Valida características
  String? validateCharacteristics(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Características são obrigatórias';
    }
    if (value.trim().length < 10) {
      return 'Características devem ter pelo menos 10 caracteres';
    }
    return null;
  }

  /// Valida finalidade
  String? validatePurpose(String? value) {
    // Purpose é opcional
    if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
      return 'Finalidade deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  // =====================================================================
  // DATA TRANSFORMATION
  // =====================================================================

  /// Processa tags de string para lista
  List<String> processTags(String tagsString) {
    if (tagsString.trim().isEmpty) return [];
    
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.toLowerCase())
        .toSet() // Remove duplicatas
        .toList();
  }

  /// Converte lista de tags para string
  String tagsToString(List<String> tags) {
    return tags.join(', ');
  }

  /// Gera ID automático se necessário
  String generateRegistrationId(String commonName, String breed) {
    final now = DateTime.now();
    final namePrefix = commonName.trim().toUpperCase().substring(0, 
        commonName.length >= 3 ? 3 : commonName.length);
    final breedPrefix = breed.trim().toUpperCase().substring(0, 
        breed.length >= 2 ? 2 : breed.length);
    
    return '$namePrefix-$breedPrefix-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  // =====================================================================
  // BUSINESS LOGIC
  // =====================================================================

  /// Valida formulário completo
  FormValidationResult validateCompleteForm(BovineFormData formData) {
    final errors = <String, String>{};
    
    // Validação individual de campos
    final commonNameError = validateCommonName(formData.commonName);
    if (commonNameError != null) errors['commonName'] = commonNameError;
    
    final registrationIdError = validateRegistrationId(formData.registrationId);
    if (registrationIdError != null) errors['registrationId'] = registrationIdError;
    
    final breedError = validateBreed(formData.breed);
    if (breedError != null) errors['breed'] = breedError;
    
    final originCountryError = validateOriginCountry(formData.originCountry);
    if (originCountryError != null) errors['originCountry'] = originCountryError;
    
    final animalTypeError = validateAnimalType(formData.animalType);
    if (animalTypeError != null) errors['animalType'] = animalTypeError;
    
    final originError = validateOrigin(formData.origin);
    if (originError != null) errors['origin'] = originError;
    
    final characteristicsError = validateCharacteristics(formData.characteristics);
    if (characteristicsError != null) errors['characteristics'] = characteristicsError;
    
    final purposeError = validatePurpose(formData.purpose);
    if (purposeError != null) errors['purpose'] = purposeError;
    
    return FormValidationResult(
      isValid: errors.isEmpty,
      fieldErrors: errors,
    );
  }

  /// Prepara dados para criação/atualização
  BovineEntity prepareBovineData({
    required BovineFormData formData,
    required bool isEditing,
    String? existingId,
    List<String>? existingImageUrls,
    DateTime? existingCreatedAt,
  }) {
    final now = DateTime.now();
    
    // Gera ID automaticamente se necessário
    String finalRegistrationId = formData.registrationId?.trim() ?? '';
    if (finalRegistrationId.isEmpty) {
      finalRegistrationId = generateRegistrationId(
        formData.commonName ?? '',
        formData.breed ?? '',
      );
    }
    
    return BovineEntity(
      id: isEditing ? (existingId ?? '') : '',
      commonName: formData.commonName?.trim() ?? '',
      registrationId: finalRegistrationId,
      breed: formData.breed?.trim() ?? '',
      originCountry: formData.originCountry?.trim() ?? '',
      animalType: formData.animalType?.trim() ?? '',
      origin: formData.origin?.trim() ?? '',
      characteristics: formData.characteristics?.trim() ?? '',
      purpose: formData.purpose?.trim() ?? '',
      tags: processTags(formData.tagsString ?? ''),
      aptitude: formData.aptitude ?? BovineAptitude.beef,
      breedingSystem: formData.breedingSystem ?? BreedingSystem.extensive,
      imageUrls: existingImageUrls ?? [],
      isActive: formData.isActive ?? true,
      createdAt: isEditing ? (existingCreatedAt ?? now) : now,
      updatedAt: now,
    );
  }

  /// Popula dados do formulário a partir de entidade
  BovineFormData populateFromEntity(BovineEntity bovine) {
    return BovineFormData(
      commonName: bovine.commonName,
      registrationId: bovine.registrationId,
      breed: bovine.breed,
      originCountry: bovine.originCountry,
      animalType: bovine.animalType,
      origin: bovine.origin,
      characteristics: bovine.characteristics,
      purpose: bovine.purpose,
      tagsString: tagsToString(bovine.tags),
      aptitude: bovine.aptitude,
      breedingSystem: bovine.breedingSystem,
      isActive: bovine.isActive,
    );
  }

  // =====================================================================
  // HELPER METHODS
  // =====================================================================

  /// Verifica se há mudanças no formulário
  bool hasFormChanged(BovineFormData current, BovineFormData original) {
    return current.commonName != original.commonName ||
        current.registrationId != original.registrationId ||
        current.breed != original.breed ||
        current.originCountry != original.originCountry ||
        current.animalType != original.animalType ||
        current.origin != original.origin ||
        current.characteristics != original.characteristics ||
        current.purpose != original.purpose ||
        current.tagsString != original.tagsString ||
        current.aptitude != original.aptitude ||
        current.breedingSystem != original.breedingSystem ||
        current.isActive != original.isActive;
  }

  /// Conta caracteres restantes para campo
  int getRemainingChars(String? value, int maxLength) {
    final currentLength = value?.trim().length ?? 0;
    return maxLength - currentLength;
  }

  /// Verifica se campo está no limite de caracteres
  bool isNearCharLimit(String? value, int maxLength, {double threshold = 0.8}) {
    final currentLength = value?.trim().length ?? 0;
    return currentLength >= (maxLength * threshold);
  }
}

// =====================================================================
// DATA CLASSES
// =====================================================================

/// Classe para armazenar dados do formulário
class BovineFormData {
  final String? commonName;
  final String? registrationId;
  final String? breed;
  final String? originCountry;
  final String? animalType;
  final String? origin;
  final String? characteristics;
  final String? purpose;
  final String? tagsString;
  final BovineAptitude? aptitude;
  final BreedingSystem? breedingSystem;
  final bool? isActive;

  const BovineFormData({
    commonName,
    registrationId,
    breed,
    originCountry,
    animalType,
    origin,
    characteristics,
    purpose,
    tagsString,
    aptitude,
    breedingSystem,
    isActive,
  });

  BovineFormData copyWith({
    String? commonName,
    String? registrationId,
    String? breed,
    String? originCountry,
    String? animalType,
    String? origin,
    String? characteristics,
    String? purpose,
    String? tagsString,
    BovineAptitude? aptitude,
    BreedingSystem? breedingSystem,
    bool? isActive,
  }) {
    return BovineFormData(
      commonName: commonName ?? commonName,
      registrationId: registrationId ?? registrationId,
      breed: breed ?? breed,
      originCountry: originCountry ?? originCountry,
      animalType: animalType ?? animalType,
      origin: origin ?? origin,
      characteristics: characteristics ?? characteristics,
      purpose: purpose ?? purpose,
      tagsString: tagsString ?? tagsString,
      aptitude: aptitude ?? aptitude,
      breedingSystem: breedingSystem ?? breedingSystem,
      isActive: isActive ?? isActive,
    );
  }
}

/// Resultado da validação do formulário
class FormValidationResult {
  final bool isValid;
  final Map<String, String> fieldErrors;
  final List<String> generalErrors;

  const FormValidationResult({
    required isValid,
    fieldErrors = const {},
    generalErrors = const [],
  });

  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);
  String? getFieldError(String fieldName) => fieldErrors[fieldName];
  bool get hasAnyErrors => fieldErrors.isNotEmpty || generalErrors.isNotEmpty;
  int get totalErrors => fieldErrors.length + generalErrors.length;
}