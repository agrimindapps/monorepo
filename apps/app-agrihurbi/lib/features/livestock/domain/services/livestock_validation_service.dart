import 'package:injectable/injectable.dart';

import '../entities/animal_base_entity.dart';
import '../entities/bovine_entity.dart';
import '../entities/equine_entity.dart';

/// Service especializado para validação de dados de livestock
/// 
/// Responsabilidade única: Validar entidades e dados de animais
/// Seguindo Single Responsibility Principle
@singleton
class LivestockValidationService {

  /// Valida uma entidade bovine completa
  ValidationResult validateBovine(BovineEntity bovine) {
    final errors = <String>[];
    final warnings = <String>[];
    errors.addAll(_validateBaseAnimalFields(bovine));
    errors.addAll(_validateBovineSpecificFields(bovine));
    warnings.addAll(_generateBovineWarnings(bovine));

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida campos específicos de bovino
  List<String> _validateBovineSpecificFields(BovineEntity bovine) {
    final errors = <String>[];

    if (bovine.breed.trim().isEmpty) {
      errors.add('Raça é obrigatória');
    }

    if (bovine.animalType.trim().isEmpty) {
      errors.add('Tipo do animal é obrigatório');
    }

    if (bovine.origin.trim().isEmpty) {
      errors.add('Origem é obrigatória');
    }

    if (bovine.purpose.trim().isEmpty) {
      errors.add('Finalidade é obrigatória');
    }

    return errors;
  }

  /// Gera alertas para bovinos
  List<String> _generateBovineWarnings(BovineEntity bovine) {
    final warnings = <String>[];

    if (bovine.characteristics.trim().isEmpty) {
      warnings.add('Características não informadas');
    }

    if (bovine.tags.isEmpty) {
      warnings.add('Nenhuma tag associada');
    }

    if (bovine.imageUrls.isEmpty) {
      warnings.add('Nenhuma imagem associada');
    }

    return warnings;
  }

  /// Valida uma entidade equine completa
  ValidationResult validateEquine(EquineEntity equine) {
    final errors = <String>[];
    final warnings = <String>[];
    errors.addAll(_validateBaseAnimalFields(equine));
    errors.addAll(_validateEquineSpecificFields(equine));
    warnings.addAll(_generateEquineWarnings(equine));

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida campos específicos de equino
  List<String> _validateEquineSpecificFields(EquineEntity equine) {
    final errors = <String>[];

    return errors;
  }

  /// Gera alertas para equinos
  List<String> _generateEquineWarnings(EquineEntity equine) {
    final warnings = <String>[];

    if (equine.imageUrls.isEmpty) {
      warnings.add('Nenhuma imagem associada');
    }

    return warnings;
  }

  /// Valida campos base comuns a todos os animais
  List<String> _validateBaseAnimalFields(AnimalBaseEntity animal) {
    final errors = <String>[];

    if (animal.id.trim().isEmpty) {
      errors.add('ID é obrigatório');
    }

    if (animal.registrationId.trim().isEmpty) {
      errors.add('ID de registro é obrigatório');
    }

    if (animal.commonName.trim().isEmpty) {
      errors.add('Nome comum é obrigatório');
    }

    if (animal.originCountry.trim().isEmpty) {
      errors.add('País de origem é obrigatório');
    }
    if (!_isValidRegistrationIdFormat(animal.registrationId)) {
      errors.add('Formato do ID de registro inválido');
    }

    return errors;
  }

  /// Valida uma lista de bovinos
  BatchValidationResult validateBovinesBatch(List<BovineEntity> bovines) {
    final results = bovines.map((bovine) => validateBovine(bovine)).toList();
    final validCount = results.where((r) => r.isValid).length;
    final invalidCount = results.where((r) => !r.isValid).length;
    
    return BatchValidationResult(
      totalItems: bovines.length,
      validItems: validCount,
      invalidItems: invalidCount,
      results: results,
    );
  }

  /// Valida uma lista de equinos
  BatchValidationResult validateEquinesBatch(List<EquineEntity> equines) {
    final results = equines.map((equine) => validateEquine(equine)).toList();
    final validCount = results.where((r) => r.isValid).length;
    final invalidCount = results.where((r) => !r.isValid).length;
    
    return BatchValidationResult(
      totalItems: equines.length,
      validItems: validCount,
      invalidItems: invalidCount,
      results: results,
    );
  }

  /// Valida formato do ID de registro
  bool _isValidRegistrationIdFormat(String registrationId) {
    final regex = RegExp(r'^[a-zA-Z0-9]{3,}$');
    return regex.hasMatch(registrationId.trim());
  }

  /// Valida país de origem
  bool isValidOriginCountry(String country) {
    final validCountries = {
      'Brasil', 'Argentina', 'Uruguai', 'Estados Unidos', 'Canadá',
      'França', 'Inglaterra', 'Holanda', 'Alemanha', 'Suíça',
      'Austrália', 'Nova Zelândia', 'México', 'Colômbia'
    };
    
    return validCountries.contains(country.trim());
  }

  /// Valida URLs de imagem
  bool isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             (url.toLowerCase().endsWith('.jpg') ||
              url.toLowerCase().endsWith('.jpeg') ||
              url.toLowerCase().endsWith('.png') ||
              url.toLowerCase().endsWith('.webp'));
    } catch (e) {
      return false;
    }
  }

  /// Valida lista de URLs de imagem
  List<String> validateImageUrls(List<String> imageUrls) {
    final errors = <String>[];
    
    for (int i = 0; i < imageUrls.length; i++) {
      if (!isValidImageUrl(imageUrls[i])) {
        errors.add('URL da imagem ${i + 1} é inválida: ${imageUrls[i]}');
      }
    }
    
    return errors;
  }

  /// Valida regras de negócio para criação de animal
  BusinessValidationResult validateAnimalCreationRules(AnimalBaseEntity animal) {
    final issues = <String>[];
    if (animal.imageUrls.isEmpty) {
      issues.add('Animal deve ter pelo menos uma imagem');
    }
    if (!isValidOriginCountry(animal.originCountry)) {
      issues.add('País de origem não reconhecido: ${animal.originCountry}');
    }

    return BusinessValidationResult(
      hasIssues: issues.isNotEmpty,
      issues: issues,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  int get totalIssues => errors.length + warnings.length;
}

class BatchValidationResult {
  final int totalItems;
  final int validItems;
  final int invalidItems;
  final List<ValidationResult> results;

  const BatchValidationResult({
    required this.totalItems,
    required this.validItems,
    required this.invalidItems,
    required this.results,
  });

  double get validPercentage => 
    totalItems > 0 ? (validItems / totalItems * 100) : 100.0;
    
  List<ValidationResult> get invalidResults => 
    results.where((r) => !r.isValid).toList();
    
  List<String> get allErrors => 
    results.expand((r) => r.errors).toList();
}

class BusinessValidationResult {
  final bool hasIssues;
  final List<String> issues;

  const BusinessValidationResult({
    required this.hasIssues,
    required this.issues,
  });

  bool get isValid => !hasIssues;
}
