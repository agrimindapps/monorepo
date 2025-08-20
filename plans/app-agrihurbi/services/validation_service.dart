// Dart imports:
import 'dart:io';

// Project imports:
import 'bovino_validation_service.dart';
import 'file_validation_service.dart';
import 'image_validation_service.dart';

/// Serviço centralizado de validação
/// Unifica todas as validações do app em uma interface consistente
class ValidationService {
  // Singleton pattern
  static ValidationService? _instance;
  static ValidationService get instance => _instance ??= ValidationService._();
  ValidationService._();

  /// Valida arquivos de imagem
  static Future<ImageValidationResult> validateImage(
    File file, {
    bool isMiniatura = false,
  }) async {
    return ImageValidationService.validateImage(file, isMiniatura: isMiniatura);
  }

  /// Valida múltiplas imagens
  static Future<List<ImageValidationResult>> validateMultipleImages(
    List<File> files,
  ) async {
    return ImageValidationService.validateMultipleImages(files);
  }

  /// Valida arquivos genéricos
  static Future<FileValidationResult> validateFile(File file) async {
    return FileValidationService.validateFile(file);
  }

  /// Valida múltiplos arquivos
  static Future<MultiFileValidationResult> validateFiles(List<File> files) async {
    return FileValidationService.validateFiles(files);
  }

  /// Validações específicas de bovinos
  static ValidationResult validateBovinoNomeComum(String? value) {
    return BovinoValidationService.validateNomeComum(value);
  }

  static ValidationResult validateBovinoPaisOrigem(String? value) {
    return BovinoValidationService.validatePaisOrigem(value);
  }

  static ValidationResult validateBovinoTipoAnimal(String? value) {
    return BovinoValidationService.validateTipoAnimal(value);
  }

  static ValidationResult validateBovinoOrigem(String? value) {
    return BovinoValidationService.validateOrigem(value);
  }

  static ValidationResult validateBovinoCaracteristicas(String? value) {
    return BovinoValidationService.validateCaracteristicas(value);
  }

  static Future<ValidationResult> validateBovinoDuplicate(
    String nomeComum,
    String? currentId,
    Future<List<dynamic>> Function() getAllBovinos,
  ) async {
    return BovinoValidationService.validateDuplicateNome(
      nomeComum,
      currentId,
      getAllBovinos,
    );
  }

  static Future<FormValidationResult> validateBovinoCompleteForm({
    required String? nomeComum,
    required String? paisOrigem,
    required String? tipoAnimal,
    required String? origem,
    required String? caracteristicas,
    String? currentId,
    Future<List<dynamic>> Function()? getAllBovinos,
  }) async {
    return BovinoValidationService.validateCompleteForm(
      nomeComum: nomeComum,
      paisOrigem: paisOrigem,
      tipoAnimal: tipoAnimal,
      origem: origem,
      caracteristicas: caracteristicas,
      currentId: currentId,
      getAllBovinos: getAllBovinos,
    );
  }

  /// Validações comuns para campos de texto
  static ValidationResult validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('$fieldName é obrigatório');
    }
    return ValidationResult.success();
  }

  static ValidationResult validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.trim().length < minLength) {
      return ValidationResult.error(
        '$fieldName deve ter pelo menos $minLength caracteres',
      );
    }
    return ValidationResult.success();
  }

  static ValidationResult validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.trim().length > maxLength) {
      return ValidationResult.error(
        '$fieldName não pode ter mais de $maxLength caracteres',
      );
    }
    return ValidationResult.success();
  }

  static ValidationResult validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('Email é obrigatório');
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationResult.error('Email inválido');
    }

    return ValidationResult.success();
  }

  static ValidationResult validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(); // Optional field
    }

    final phoneRegex = RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return ValidationResult.warning(
        'Formato recomendado: (11) 99999-9999',
      );
    }

    return ValidationResult.success();
  }

  static ValidationResult validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('$fieldName é obrigatório');
    }

    final numeric = double.tryParse(value.trim());
    if (numeric == null) {
      return ValidationResult.error('$fieldName deve ser um número válido');
    }

    return ValidationResult.success();
  }

  static ValidationResult validatePositiveNumber(
    String? value,
    String fieldName,
  ) {
    final numericResult = validateNumeric(value, fieldName);
    if (!numericResult.isValid) {
      return numericResult;
    }

    final number = double.parse(value!.trim());
    if (number <= 0) {
      return ValidationResult.error('$fieldName deve ser maior que zero');
    }

    return ValidationResult.success();
  }

  /// Sanitização de inputs
  static String sanitizeInput(String input) {
    return BovinoValidationService.sanitizeInput(input);
  }

  static String sanitizeFileName(String fileName) {
    return ImageValidationService.sanitizeFileName(fileName);
  }

  static String generateUniqueFileName(String originalFileName) {
    return ImageValidationService.generateUniqueFileName(originalFileName);
  }

  static String generateSecureFilename(String originalName) {
    return FileValidationService.generateSecureFilename(originalName);
  }

  /// Validações de segurança
  static Future<bool> hasSuspiciousContent(File file) async {
    return ImageValidationService.hasSuspiciousContent(file);
  }

  /// Validação combinada para múltiplos campos
  static FormValidationResult validateMultipleFields(
    List<ValidationResult> results,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    for (final result in results) {
      if (!result.isValid && result.message != null) {
        errors.add(result.message!);
      } else if (result.isWarning && result.message != null) {
        warnings.add(result.message!);
      }
    }

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Interface comum para todos os tipos de validação
abstract class IValidationService {
  ValidationResult validate(dynamic value);
}

/// Validador genérico que pode ser configurado
class ConfigurableValidator implements IValidationService {
  final bool required;
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final String fieldName;

  const ConfigurableValidator({
    required this.fieldName,
    this.required = true,
    this.minLength,
    this.maxLength,
    this.pattern,
  });

  @override
  ValidationResult validate(dynamic value) {
    final stringValue = value?.toString();

    if (required) {
      final requiredResult = ValidationService.validateRequired(stringValue, fieldName);
      if (!requiredResult.isValid) return requiredResult;
    }

    if (stringValue != null && stringValue.isNotEmpty) {
      if (minLength != null) {
        final minResult = ValidationService.validateMinLength(stringValue, minLength!, fieldName);
        if (!minResult.isValid) return minResult;
      }

      if (maxLength != null) {
        final maxResult = ValidationService.validateMaxLength(stringValue, maxLength!, fieldName);
        if (!maxResult.isValid) return maxResult;
      }

      if (pattern != null) {
        final regex = RegExp(pattern!);
        if (!regex.hasMatch(stringValue)) {
          return ValidationResult.error('$fieldName tem formato inválido');
        }
      }
    }

    return ValidationResult.success();
  }
}