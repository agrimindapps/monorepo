// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';

/// Classe utilitária para validação de dados de entrada
class ValidationUtils {
  // Limites para timestamps (1 ano para o passado, 1 ano para o futuro)
  static final DateTime _minTimestamp =
      DateTime.now().subtract(const Duration(days: 365));
  static final DateTime _maxTimestamp =
      DateTime.now().add(const Duration(days: 365));

  // Limites para valores de medição (em mm)
  static const double _minMedicaoValue = 0.0;
  static const double _maxMedicaoValue =
      1000.0; // 1000mm em um dia seria extremo

  // Limites para anos
  static const int _minYear = 1900;
  static final int _maxYear = DateTime.now().year + 10;

  // Limites para meses
  static const int _minMonth = 1;
  static const int _maxMonth = 12;

  /// Valida um timestamp
  static ValidationResult validateTimestamp(int timestamp) {
    if (timestamp <= 0) {
      return ValidationResult.error('Timestamp deve ser maior que zero');
    }

    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      if (dateTime.isBefore(_minTimestamp)) {
        return ValidationResult.error(
            'Data muito antiga: ${dateTime.toString()}');
      }

      if (dateTime.isAfter(_maxTimestamp)) {
        return ValidationResult.error(
            'Data muito futura: ${dateTime.toString()}');
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Timestamp inválido: $timestamp');
    }
  }

  /// Valida um valor de medição
  static ValidationResult validateMedicaoValue(double value) {
    if (value.isNaN) {
      return ValidationResult.error('Valor de medição é NaN');
    }

    if (value.isInfinite) {
      return ValidationResult.error('Valor de medição é infinito');
    }

    if (value < _minMedicaoValue) {
      return ValidationResult.error('Valor de medição muito baixo: $value mm');
    }

    if (value > _maxMedicaoValue) {
      return ValidationResult.error(
          'Valor de medição muito alto: $value mm (máximo: $_maxMedicaoValue mm)');
    }

    return ValidationResult.success();
  }

  /// Valida um ano
  static ValidationResult validateYear(int year) {
    if (year < _minYear || year > _maxYear) {
      return ValidationResult.error(
          'Ano inválido: $year (deve estar entre $_minYear e $_maxYear)');
    }

    return ValidationResult.success();
  }

  /// Valida um mês
  static ValidationResult validateMonth(int month) {
    if (month < _minMonth || month > _maxMonth) {
      return ValidationResult.error(
          'Mês inválido: $month (deve estar entre $_minMonth e $_maxMonth)');
    }

    return ValidationResult.success();
  }

  /// Valida uma medição completa
  static ValidationResult validateMedicao(Medicoes medicao) {
    final errors = <String>[];

    // Validar timestamp
    final timestampResult = validateTimestamp(medicao.dtMedicao);
    if (!timestampResult.isValid) {
      errors.add('Timestamp: ${timestampResult.errorMessage}');
    }

    // Validar quantidade
    final quantidadeResult = validateMedicaoValue(medicao.quantidade);
    if (!quantidadeResult.isValid) {
      errors.add('Quantidade: ${quantidadeResult.errorMessage}');
    }

    // Validar ID
    if (medicao.id.trim().isEmpty) {
      errors.add('ID não pode estar vazio');
    }

    // Validar pluviometro ID
    if (medicao.fkPluviometro.trim().isEmpty) {
      errors.add('ID do pluviômetro não pode estar vazio');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(errors.join('; '));
    }

    return ValidationResult.success();
  }

  /// Valida uma lista de medições
  static ValidationResult validateMedicoesList(List<Medicoes> medicoes) {
    if (medicoes.isEmpty) {
      return ValidationResult.warning('Lista de medições está vazia');
    }

    final errors = <String>[];
    final duplicatedIds = <String>[];
    final seenIds = <String>{};

    for (int i = 0; i < medicoes.length; i++) {
      final medicao = medicoes[i];

      // Verificar IDs duplicados
      if (seenIds.contains(medicao.id)) {
        duplicatedIds.add(medicao.id);
      } else {
        seenIds.add(medicao.id);
      }

      // Validar medição individual
      final result = validateMedicao(medicao);
      if (!result.isValid) {
        errors.add('Medição ${i + 1}: ${result.errorMessage}');
      }
    }

    if (duplicatedIds.isNotEmpty) {
      errors.add('IDs duplicados encontrados: ${duplicatedIds.join(', ')}');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(errors.join('; '));
    }

    return ValidationResult.success();
  }

  /// Valida um pluviômetro
  static ValidationResult validatePluviometro(Pluviometro pluviometro) {
    final errors = <String>[];

    // Validar ID
    if (pluviometro.id.trim().isEmpty) {
      errors.add('ID não pode estar vazio');
    }

    // Validar descrição
    if (pluviometro.descricao.trim().isEmpty) {
      errors.add('Descrição não pode estar vazia');
    }

    // Validar coordenadas se fornecidas
    if (pluviometro.latitude != null || pluviometro.longitude != null) {
      final latResult = validateLatitude(pluviometro.latitude != null
          ? double.tryParse(pluviometro.latitude!)
          : null);
      if (!latResult.isValid) {
        errors.add('Latitude: ${latResult.errorMessage}');
      }

      final lngResult = validateLongitude(pluviometro.longitude != null
          ? double.tryParse(pluviometro.longitude!)
          : null);
      if (!lngResult.isValid) {
        errors.add('Longitude: ${lngResult.errorMessage}');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.error(errors.join('; '));
    }

    return ValidationResult.success();
  }

  /// Valida latitude
  static ValidationResult validateLatitude(double? latitude) {
    if (latitude == null) {
      return ValidationResult.success();
    }

    if (latitude < -90.0 || latitude > 90.0) {
      return ValidationResult.error('Latitude deve estar entre -90 e 90 graus');
    }

    return ValidationResult.success();
  }

  /// Valida longitude
  static ValidationResult validateLongitude(double? longitude) {
    if (longitude == null) {
      return ValidationResult.success();
    }

    if (longitude < -180.0 || longitude > 180.0) {
      return ValidationResult.error(
          'Longitude deve estar entre -180 e 180 graus');
    }

    return ValidationResult.success();
  }

  /// Sanitiza uma string removendo caracteres perigosos
  static String sanitizeString(String input) {
    if (input.isEmpty) return input;

    // Remove caracteres de controle
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Remove scripts potencialmente perigosos
    sanitized = sanitized.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '');
    sanitized =
        sanitized.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    sanitized =
        sanitized.replaceAll(RegExp(r'vbscript:', caseSensitive: false), '');

    // Remove caracteres HTML perigosos
    sanitized = sanitized.replaceAll(RegExp(r'[<>"' "']"), '');

    return sanitized.trim();
  }

  /// Valida e sanitiza dados de entrada
  static Map<String, dynamic> validateAndSanitizeInput({
    required List<Medicoes> medicoes,
    required int ano,
    required int mes,
    String? tipoVisualizacao,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validar medições
    final medicoesResult = validateMedicoesList(medicoes);
    if (!medicoesResult.isValid) {
      if (medicoesResult.isWarning) {
        warnings.add(medicoesResult.errorMessage!);
      } else {
        errors.add(medicoesResult.errorMessage!);
      }
    }

    // Validar ano
    final anoResult = validateYear(ano);
    if (!anoResult.isValid) {
      errors.add(anoResult.errorMessage!);
    }

    // Validar mês
    final mesResult = validateMonth(mes);
    if (!mesResult.isValid) {
      errors.add(mesResult.errorMessage!);
    }

    // Validar e sanitizar tipo de visualização
    String? sanitizedTipoVisualizacao;
    if (tipoVisualizacao != null) {
      sanitizedTipoVisualizacao = sanitizeString(tipoVisualizacao);
      if (!['Ano', 'Mes'].contains(sanitizedTipoVisualizacao)) {
        warnings.add('Tipo de visualização inválido, usando padrão: Ano');
        sanitizedTipoVisualizacao = 'Ano';
      }
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'sanitizedData': {
        'medicoes': medicoes,
        'ano': ano,
        'mes': mes,
        'tipoVisualizacao': sanitizedTipoVisualizacao,
      },
    };
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final bool isWarning;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.isWarning = false,
  });

  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      errorMessage: message,
      isWarning: false,
    );
  }

  factory ValidationResult.warning(String message) {
    return ValidationResult._(
      isValid: true,
      errorMessage: message,
      isWarning: true,
    );
  }
}

/// Exceções específicas para validação
class ValidationException implements Exception {
  final String message;
  final List<String> errors;

  const ValidationException(this.message, this.errors);

  @override
  String toString() => 'ValidationException: $message';
}

class InvalidTimestampException extends ValidationException {
  const InvalidTimestampException(String message) : super(message, const []);
}

class InvalidMeasurementException extends ValidationException {
  const InvalidMeasurementException(String message) : super(message, const []);
}

class InvalidInputException extends ValidationException {
  const InvalidInputException(super.message, super.errors);
}
