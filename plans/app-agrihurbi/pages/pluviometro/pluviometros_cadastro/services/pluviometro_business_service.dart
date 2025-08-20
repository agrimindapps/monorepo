// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../error_handling/specific_error_types.dart';
import '../utils/type_conversion_utils.dart';
import '../validators/advanced_field_validator.dart';
import 'required_fields_service.dart';

/// Service responsável pela lógica de negócio de pluviômetros
class PluviometroBusinessService {
  final RequiredFieldsService _requiredFieldsService;

  PluviometroBusinessService({RequiredFieldsService? requiredFieldsService})
      : _requiredFieldsService =
            requiredFieldsService ?? RequiredFieldsService();

  /// Valida os dados de um pluviômetro antes de salvar
  ValidationResult validatePluviometro(Pluviometro pluviometro) {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    // Validação de descrição
    final descricaoResult =
        AdvancedFieldValidator.validateDescricaoFormat(pluviometro.descricao);
    allErrors.addAll(descricaoResult.errors);
    allWarnings.addAll(descricaoResult.warnings);

    // Validação de quantidade
    final quantidade = pluviometro.getQuantidadeAsDouble();
    final quantidadeResult =
        AdvancedFieldValidator.validateQuantidadeRange(quantidade);
    allErrors.addAll(quantidadeResult.errors);
    allWarnings.addAll(quantidadeResult.warnings);

    // Validação de coordenadas
    final coordenadasResult = AdvancedFieldValidator.validateCoordinates(
      pluviometro.latitude,
      pluviometro.longitude,
    );
    allErrors.addAll(coordenadasResult.errors);
    allWarnings.addAll(coordenadasResult.warnings);

    // Validação de regras de negócio
    final businessResult =
        AdvancedFieldValidator.validateBusinessRules(pluviometro);
    allErrors.addAll(businessResult.errors);
    allWarnings.addAll(businessResult.warnings);

    // Validação de campos obrigatórios
    final requiredResult =
        _requiredFieldsService.validateRequiredFields(pluviometro);
    allErrors.addAll(requiredResult.errors);
    allWarnings.addAll(requiredResult.warnings);

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  /// Valida pluviômetro com contexto histórico
  Future<ValidationResult> validatePluviometroWithContext(
    Pluviometro pluviometro,
    List<Pluviometro> existingPluviometros,
  ) async {
    final basicResult = validatePluviometro(pluviometro);

    // Validação de unicidade
    final uniquenessResult =
        await AdvancedFieldValidator.validateDescricaoUniqueness(
      pluviometro.descricao,
      existingPluviometros,
      excludeId: pluviometro.id,
    );

    // Validação contextual
    final contextualResult = AdvancedFieldValidator.validateContextualData(
      pluviometro,
      existingPluviometros,
    );

    final allErrors = <String>[];
    final allWarnings = <String>[];

    allErrors.addAll(basicResult.errors);
    allWarnings.addAll(basicResult.warnings);

    allErrors.addAll(uniquenessResult.errors);
    allWarnings.addAll(uniquenessResult.warnings);

    allErrors.addAll(contextualResult.errors);
    allWarnings.addAll(contextualResult.warnings);

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }

  /// Cria um novo pluviômetro com valores padrão
  Future<Pluviometro> createNewPluviometro({
    required String id,
    required String descricao,
    required double quantidade,
    String? latitude,
    String? longitude,
    String? fkGrupo,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Obter valores padrão para campos obrigatórios
    final defaultFields =
        await _requiredFieldsService.getDefaultRequiredFields();

    final pluviometro = Pluviometro(
      id: id,
      createdAt: now,
      updatedAt: now,
      descricao: descricao.trim(),
      quantidade: TypeConversionUtils.doubleToString(quantidade),
      latitude: latitude?.trim() ?? defaultFields.latitude,
      longitude: longitude?.trim() ?? defaultFields.longitude,
      fkGrupo: fkGrupo?.trim() ?? defaultFields.fkGrupo,
    );

    // Preencher campos obrigatórios faltantes
    return await _requiredFieldsService.fillMissingRequiredFields(pluviometro);
  }

  /// Atualiza um pluviômetro existente
  Pluviometro updatePluviometro({
    required Pluviometro original,
    required String descricao,
    required double quantidade,
    String? latitude,
    String? longitude,
    String? fkGrupo,
  }) {
    return Pluviometro(
      id: original.id,
      createdAt: original.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      descricao: descricao.trim(),
      quantidade: TypeConversionUtils.doubleToString(quantidade),
      latitude: latitude?.trim(),
      longitude: longitude?.trim(),
      fkGrupo: fkGrupo?.trim(),
    );
  }

  /// Valida coordenadas de latitude
  bool _isValidLatitude(String latitude) {
    final lat = TypeConversionUtils.safeDoubleFromString(latitude);
    return lat >= -90 && lat <= 90;
  }

  /// Valida coordenadas de longitude
  bool _isValidLongitude(String longitude) {
    final lng = TypeConversionUtils.safeDoubleFromString(longitude);
    return lng >= -180 && lng <= 180;
  }

  /// Formata a descrição para exibição
  String formatDescricao(String descricao) {
    return descricao.trim().toUpperCase();
  }

  /// Formata a quantidade para exibição
  String formatQuantidade(double quantidade) {
    return TypeConversionUtils.doubleToString(quantidade);
  }

  /// Verifica se o pluviômetro tem localização válida
  bool hasValidLocation(Pluviometro pluviometro) {
    if (pluviometro.latitude == null || pluviometro.longitude == null) {
      return false;
    }

    return _isValidLatitude(pluviometro.latitude!) &&
        _isValidLongitude(pluviometro.longitude!);
  }

  /// Valida com exceções específicas
  void validateWithExceptions(Pluviometro pluviometro) {
    // Validação de descrição
    if (pluviometro.descricao.trim().isEmpty) {
      throw ValidationException(
        fieldName: 'descricao',
        message: 'Descrição é obrigatória',
        invalidValue: pluviometro.descricao,
      );
    }

    // Validação de quantidade
    final quantidade = pluviometro.getQuantidadeAsDouble();
    if (quantidade < 0) {
      throw ValidationException(
        fieldName: 'quantidade',
        message: 'Quantidade não pode ser negativa',
        invalidValue: quantidade,
      );
    }

    if (quantidade > 1000) {
      throw LimitExceededException(
        limitType: 'quantidade',
        currentValue: quantidade,
        maxValue: 1000,
        details: 'Valor máximo permitido é 1000mm',
      );
    }

    // Validação de coordenadas
    if (pluviometro.latitude != null && pluviometro.latitude!.isNotEmpty) {
      final lat =
          TypeConversionUtils.safeDoubleFromString(pluviometro.latitude!);
      if (lat < -90 || lat > 90) {
        throw ValidationException(
          fieldName: 'latitude',
          message: 'Latitude deve estar entre -90 e 90',
          invalidValue: lat,
        );
      }
    }

    if (pluviometro.longitude != null && pluviometro.longitude!.isNotEmpty) {
      final lng =
          TypeConversionUtils.safeDoubleFromString(pluviometro.longitude!);
      if (lng < -180 || lng > 180) {
        throw ValidationException(
          fieldName: 'longitude',
          message: 'Longitude deve estar entre -180 e 180',
          invalidValue: lng,
        );
      }
    }
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });

  String get errorMessage => errors.join('\n');
  String get warningMessage => warnings.join('\n');

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    if (isValid && warnings.isEmpty) return 'Validação OK';

    final parts = <String>[];
    if (errors.isNotEmpty) parts.add('Erros: ${errors.join(', ')}');
    if (warnings.isNotEmpty) parts.add('Avisos: ${warnings.join(', ')}');

    return parts.join(' | ');
  }
}
