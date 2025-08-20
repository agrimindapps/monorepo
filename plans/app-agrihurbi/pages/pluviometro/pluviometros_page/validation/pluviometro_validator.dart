// Project imports:
import '../../../../models/pluviometros_models.dart';

/// Classe para validação de dados de pluviômetros
class PluviometroValidator {
  /// Valida um pluviômetro completo
  static ValidationResult validate(Pluviometro pluviometro) {
    final errors = <ValidationError>[];

    // Validar descrição
    final descricaoError = validateDescricao(pluviometro.descricao);
    if (descricaoError != null) errors.add(descricaoError);

    // Validar quantidade
    final quantidadeError = validateQuantidade(pluviometro.quantidade);
    if (quantidadeError != null) errors.add(quantidadeError);

    // Validar coordenadas se fornecidas
    if (pluviometro.latitude != null || pluviometro.longitude != null) {
      final coordenadasError =
          validateCoordenadas(pluviometro.latitude, pluviometro.longitude);
      if (coordenadasError != null) errors.add(coordenadasError);
    }

    // Validar grupo
    final grupoError = validateGrupo(pluviometro.fkGrupo);
    if (grupoError != null) errors.add(grupoError);

    return ValidationResult(errors: errors);
  }

  /// Valida descrição do pluviômetro
  static ValidationError? validateDescricao(String descricao) {
    // Sanitizar entrada
    final sanitized = _sanitizeString(descricao);

    if (sanitized.isEmpty) {
      return const ValidationError(
        field: 'descricao',
        code: 'required',
        message: 'Descrição é obrigatória',
        severity: ValidationSeverity.error,
      );
    }

    if (sanitized.length < 2) {
      return const ValidationError(
        field: 'descricao',
        code: 'min_length',
        message: 'Descrição deve ter pelo menos 2 caracteres',
        severity: ValidationSeverity.error,
      );
    }

    if (sanitized.length > 100) {
      return const ValidationError(
        field: 'descricao',
        code: 'max_length',
        message: 'Descrição deve ter no máximo 100 caracteres',
        severity: ValidationSeverity.error,
      );
    }

    // Verificar caracteres suspeitos
    if (_containsSuspiciousCharacters(sanitized)) {
      return const ValidationError(
        field: 'descricao',
        code: 'invalid_characters',
        message: 'Descrição contém caracteres não permitidos',
        severity: ValidationSeverity.warning,
      );
    }

    return null;
  }

  /// Valida quantidade de chuva
  static ValidationError? validateQuantidade(String quantidade) {
    // Sanitizar entrada
    final sanitized = _sanitizeNumericString(quantidade);

    if (sanitized.isEmpty) {
      return const ValidationError(
        field: 'quantidade',
        code: 'required',
        message: 'Quantidade é obrigatória',
        severity: ValidationSeverity.error,
      );
    }

    final parsedValue = double.tryParse(sanitized);
    if (parsedValue == null) {
      return const ValidationError(
        field: 'quantidade',
        code: 'invalid_format',
        message: 'Quantidade deve ser um número válido',
        severity: ValidationSeverity.error,
      );
    }

    if (parsedValue < 0) {
      return const ValidationError(
        field: 'quantidade',
        code: 'negative_value',
        message: 'Quantidade não pode ser negativa',
        severity: ValidationSeverity.error,
      );
    }

    if (parsedValue > 1000) {
      return const ValidationError(
        field: 'quantidade',
        code: 'excessive_value',
        message: 'Quantidade parece excessiva (>1000mm)',
        severity: ValidationSeverity.warning,
      );
    }

    return null;
  }

  /// Valida coordenadas geográficas
  static ValidationError? validateCoordenadas(
      String? latitude, String? longitude) {
    // Se uma coordenada está presente, ambas devem estar
    final hasLatitude = latitude != null && latitude.isNotEmpty;
    final hasLongitude = longitude != null && longitude.isNotEmpty;

    if (hasLatitude != hasLongitude) {
      return const ValidationError(
        field: 'coordenadas',
        code: 'incomplete_coordinates',
        message: 'Latitude e longitude devem ser fornecidas juntas',
        severity: ValidationSeverity.error,
      );
    }

    if (!hasLatitude || !hasLongitude) return null;

    // Validar latitude
    final latSanitized = _sanitizeNumericString(latitude);
    final lat = double.tryParse(latSanitized);
    if (lat == null) {
      return const ValidationError(
        field: 'latitude',
        code: 'invalid_format',
        message: 'Latitude deve ser um número válido',
        severity: ValidationSeverity.error,
      );
    }

    if (lat < -90 || lat > 90) {
      return const ValidationError(
        field: 'latitude',
        code: 'out_of_range',
        message: 'Latitude deve estar entre -90 e 90 graus',
        severity: ValidationSeverity.error,
      );
    }

    // Validar longitude
    final lngSanitized = _sanitizeNumericString(longitude);
    final lng = double.tryParse(lngSanitized);
    if (lng == null) {
      return const ValidationError(
        field: 'longitude',
        code: 'invalid_format',
        message: 'Longitude deve ser um número válido',
        severity: ValidationSeverity.error,
      );
    }

    if (lng < -180 || lng > 180) {
      return const ValidationError(
        field: 'longitude',
        code: 'out_of_range',
        message: 'Longitude deve estar entre -180 e 180 graus',
        severity: ValidationSeverity.error,
      );
    }

    return null;
  }

  /// Valida grupo do pluviômetro
  static ValidationError? validateGrupo(String? grupo) {
    if (grupo == null || grupo.isEmpty) return null;

    final sanitized = _sanitizeString(grupo);

    if (sanitized.length > 50) {
      return const ValidationError(
        field: 'grupo',
        code: 'max_length',
        message: 'Nome do grupo deve ter no máximo 50 caracteres',
        severity: ValidationSeverity.error,
      );
    }

    if (_containsSuspiciousCharacters(sanitized)) {
      return const ValidationError(
        field: 'grupo',
        code: 'invalid_characters',
        message: 'Nome do grupo contém caracteres não permitidos',
        severity: ValidationSeverity.warning,
      );
    }

    return null;
  }

  /// Sanitiza string removendo caracteres perigosos
  static String _sanitizeString(String input) {
    return input
        .trim()
        .replaceAll(
            RegExp(r'[<>;"' "'" '\\\\]'), '') // Remove caracteres suspeitos
        .replaceAll(RegExp(r'\s+'), ' '); // Normaliza espaços
  }

  /// Sanitiza string numérica
  static String _sanitizeNumericString(String input) {
    return input
        .trim()
        .replaceAll(',', '.') // Normaliza decimal
        .replaceAll(
            RegExp(r'[^\d\.\-]'), ''); // Remove caracteres não numéricos
  }

  /// Verifica se contém caracteres suspeitos
  static bool _containsSuspiciousCharacters(String input) {
    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'data:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'onload', caseSensitive: false),
      RegExp(r'onerror', caseSensitive: false),
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(input));
  }
}

/// Resultado da validação
class ValidationResult {
  final List<ValidationError> errors;

  const ValidationResult({required this.errors});

  bool get isValid => errors.isEmpty;
  bool get hasErrors =>
      errors.any((e) => e.severity == ValidationSeverity.error);
  bool get hasWarnings =>
      errors.any((e) => e.severity == ValidationSeverity.warning);

  List<ValidationError> get errorList =>
      errors.where((e) => e.severity == ValidationSeverity.error).toList();

  List<ValidationError> get warningList =>
      errors.where((e) => e.severity == ValidationSeverity.warning).toList();

  String get summary {
    if (isValid) return 'Validação bem-sucedida';

    final errorCount = errorList.length;
    final warningCount = warningList.length;

    if (errorCount > 0 && warningCount > 0) {
      return '$errorCount erro(s) e $warningCount aviso(s) encontrado(s)';
    } else if (errorCount > 0) {
      return '$errorCount erro(s) encontrado(s)';
    } else {
      return '$warningCount aviso(s) encontrado(s)';
    }
  }
}

/// Erro de validação individual
class ValidationError {
  final String field;
  final String code;
  final String message;
  final ValidationSeverity severity;
  final Map<String, dynamic>? metadata;

  const ValidationError({
    required this.field,
    required this.code,
    required this.message,
    required this.severity,
    this.metadata,
  });

  @override
  String toString() => '$field: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          field == other.field &&
          code == other.code &&
          severity == other.severity;

  @override
  int get hashCode => Object.hash(field, code, severity);
}

/// Severidade do erro de validação
enum ValidationSeverity {
  error,
  warning,
  info,
}

/// Extensões para facilitar o uso
extension ValidationSeverityExtension on ValidationSeverity {
  bool get isError => this == ValidationSeverity.error;
  bool get isWarning => this == ValidationSeverity.warning;
  bool get isInfo => this == ValidationSeverity.info;

  String get displayName {
    switch (this) {
      case ValidationSeverity.error:
        return 'Erro';
      case ValidationSeverity.warning:
        return 'Aviso';
      case ValidationSeverity.info:
        return 'Informação';
    }
  }
}
