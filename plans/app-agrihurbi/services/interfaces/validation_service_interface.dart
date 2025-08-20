// Dart imports:
import 'dart:io';

// Project imports:
import '../bovino_validation_service.dart';
import '../file_validation_service.dart';
import '../image_validation_service.dart';

/// Interface base para todos os services de validação
abstract class IValidationService {
  /// Valida um valor genérico
  ValidationResult validate(dynamic value);
}

/// Interface para validação de arquivos
abstract class IFileValidationService {
  /// Valida arquivo único
  Future<FileValidationResult> validateFile(File file);
  
  /// Valida múltiplos arquivos
  Future<MultiFileValidationResult> validateFiles(List<File> files);
  
  /// Gera nome de arquivo seguro
  String generateSecureFilename(String originalName);
}

/// Interface para validação de imagens
abstract class IImageValidationService {
  /// Valida imagem única
  Future<ImageValidationResult> validateImage(File file, {bool isMiniatura = false});
  
  /// Valida múltiplas imagens
  Future<List<ImageValidationResult>> validateMultipleImages(List<File> files);
  
  /// Sanitiza nome do arquivo
  String sanitizeFileName(String fileName);
  
  /// Gera nome único para arquivo
  String generateUniqueFileName(String originalFileName);
  
  /// Verifica conteúdo suspeito
  Future<bool> hasSuspiciousContent(File file);
}

/// Interface para validação de formulários
abstract class IFormValidationService {
  /// Valida campo obrigatório
  ValidationResult validateRequired(String? value, String fieldName);
  
  /// Valida tamanho mínimo
  ValidationResult validateMinLength(String? value, int minLength, String fieldName);
  
  /// Valida tamanho máximo
  ValidationResult validateMaxLength(String? value, int maxLength, String fieldName);
  
  /// Valida email
  ValidationResult validateEmail(String? value);
  
  /// Valida telefone
  ValidationResult validatePhone(String? value);
  
  /// Valida número
  ValidationResult validateNumeric(String? value, String fieldName);
  
  /// Valida número positivo
  ValidationResult validatePositiveNumber(String? value, String fieldName);
}

/// Interface para validação específica de bovinos
abstract class IBovinoValidationService {
  /// Valida nome comum
  ValidationResult validateNomeComum(String? value);
  
  /// Valida país de origem
  ValidationResult validatePaisOrigem(String? value);
  
  /// Valida tipo de animal
  ValidationResult validateTipoAnimal(String? value);
  
  /// Valida origem/descrição
  ValidationResult validateOrigem(String? value);
  
  /// Valida características
  ValidationResult validateCaracteristicas(String? value);
  
  /// Valida duplicatas
  Future<ValidationResult> validateDuplicateNome(
    String nomeComum,
    String? currentId, 
    Future<List<dynamic>> Function() getAllBovinos,
  );
  
  /// Valida formulário completo
  Future<FormValidationResult> validateCompleteForm({
    required String? nomeComum,
    required String? paisOrigem,
    required String? tipoAnimal,
    required String? origem,
    required String? caracteristicas,
    String? currentId,
    Future<List<dynamic>> Function()? getAllBovinos,
  });
}

/// Interface para sanitização de dados
abstract class ISanitizationService {
  /// Sanitiza input genérico
  String sanitizeInput(String input);
  
  /// Sanitiza nome de arquivo
  String sanitizeFileName(String fileName);
  
  /// Remove conteúdo perigoso
  String removeDangerousContent(String input);
}

/// Interface para validação configurável
abstract class IConfigurableValidator extends IValidationService {
  /// Configurações de validação
  bool get required;
  int? get minLength;
  int? get maxLength;
  String? get pattern;
  String get fieldName;
}

/// Interface para combinação de múltiplas validações
abstract class ICompositeValidator extends IValidationService {
  /// Lista de validadores
  List<IValidationService> get validators;
  
  /// Adiciona validador
  void addValidator(IValidationService validator);
  
  /// Remove validador
  void removeValidator(IValidationService validator);
  
  /// Valida com todos os validadores
  @override
  ValidationResult validate(dynamic value);
}

/// Interface para factory de validadores
abstract class IValidatorFactory {
  /// Cria validador para campo obrigatório
  IValidationService createRequiredValidator(String fieldName);
  
  /// Cria validador para email
  IValidationService createEmailValidator();
  
  /// Cria validador para telefone
  IValidationService createPhoneValidator();
  
  /// Cria validador configurável
  IConfigurableValidator createConfigurableValidator({
    required String fieldName,
    bool required = true,
    int? minLength,
    int? maxLength,
    String? pattern,
  });
  
  /// Cria validador composto
  ICompositeValidator createCompositeValidator(List<IValidationService> validators);
}