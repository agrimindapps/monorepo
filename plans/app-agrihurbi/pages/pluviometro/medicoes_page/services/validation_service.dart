// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../utils/string_extensions.dart';

/// Service responsável por validação robusta de dados críticos
class ValidationService {
  /// Valida dados de uma medição
  static ValidationResult validateMedicao(Medicoes medicao) {
    final errors = <String>[];

    // Validação do ID
    if (!medicao.id.isValidId) {
      errors.add('ID da medição inválido: deve ter pelo menos 3 caracteres');
    }

    // Validação do pluviômetro
    if (!medicao.fkPluviometro.isValidId) {
      errors
          .add('ID do pluviômetro inválido: deve ter pelo menos 3 caracteres');
    }

    // Validação da data
    if (!_isValidTimestamp(medicao.dtMedicao)) {
      errors
          .add('Data da medição inválida: timestamp fora do intervalo válido');
    }

    // Validação da quantidade
    if (!_isValidQuantidade(medicao.quantidade)) {
      errors.add('Quantidade inválida: deve ser >= 0 e <= 1000mm');
    }

    // Validação de timestamps de criação/atualização
    if (medicao.createdAt <= 0) {
      errors.add('Data de criação inválida');
    }

    if (medicao.updatedAt < medicao.createdAt) {
      errors.add('Data de atualização não pode ser anterior à criação');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida dados de um pluviômetro
  static ValidationResult validatePluviometro(Pluviometro pluviometro) {
    final errors = <String>[];

    // Validação do ID
    if (!pluviometro.id.isValidId) {
      errors
          .add('ID do pluviômetro inválido: deve ter pelo menos 3 caracteres');
    }

    // Validação da descrição
    if (pluviometro.descricao.trim().isEmpty) {
      errors.add('Descrição não pode estar vazia');
    }

    if (pluviometro.descricao.length > 200) {
      errors.add('Descrição muito longa: máximo 200 caracteres');
    }

    // Validação de coordenadas se fornecidas
    if (pluviometro.latitude != null &&
        !_isValidLatitude(pluviometro.latitude!)) {
      errors.add('Latitude inválida: deve estar entre -90 e 90');
    }

    if (pluviometro.longitude != null &&
        !_isValidLongitude(pluviometro.longitude!)) {
      errors.add('Longitude inválida: deve estar entre -180 e 180');
    }

    // Validação da quantidade
    if (!pluviometro.quantidade.isNumeric) {
      errors.add('Quantidade deve ser um valor numérico');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Valida IDs de forma segura
  static bool isValidId(String? id) {
    if (id == null || id.isEmpty) return false;

    // Verifica se contém apenas caracteres alfanuméricos e alguns especiais
    final validPattern = RegExp(r'^[a-zA-Z0-9_-]{3,50}$');
    return validPattern.hasMatch(id);
  }

  /// Valida se uma data está dentro de um intervalo razoável
  static bool isValidDate(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();
    final minDate = DateTime(2000, 1, 1); // Data mínima aceitável
    final maxDate =
        now.add(const Duration(days: 365)); // Máximo 1 ano no futuro

    return date.isAfter(minDate) && date.isBefore(maxDate);
  }

  /// Valida timestamp
  static bool _isValidTimestamp(int timestamp) {
    if (timestamp <= 0) return false;

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return isValidDate(date);
    } catch (e) {
      return false;
    }
  }

  /// Valida quantidade de precipitação
  static bool _isValidQuantidade(double quantidade) {
    // Quantidade deve ser entre 0 e 1000mm (valor extremo mas possível)
    return quantidade >= 0.0 && quantidade <= 1000.0;
  }

  /// Valida latitude
  static bool _isValidLatitude(String latitude) {
    final lat = latitude.toDoubleOrNull();
    return lat != null && lat >= -90 && lat <= 90;
  }

  /// Valida longitude
  static bool _isValidLongitude(String longitude) {
    final lng = longitude.toDoubleOrNull();
    return lng != null && lng >= -180 && lng <= 180;
  }

  /// Sanitiza string removendo caracteres perigosos
  static String sanitizeString(String input) {
    if (input.isEmpty) return input;

    // Remove caracteres de controle e caracteres potencialmente perigosos
    String result = input;
    result = result.replaceAll('<', '');
    result = result.replaceAll('>', '');
    result = result.replaceAll('"', '');
    result = result.replaceAll("'", '');
    result = result.replaceAll('&', '');
    result = result.replaceAll(
        RegExp(r'[\x00-\x1F\x7F]'), ''); // Remove control chars
    return result.trim();
  }

  /// Valida lista de medições em batch
  static BatchValidationResult validateMedicoesList(List<Medicoes> medicoes) {
    final results = <String, ValidationResult>{};
    var validCount = 0;

    for (var i = 0; i < medicoes.length; i++) {
      final result = validateMedicao(medicoes[i]);
      results['medicao_$i'] = result;
      if (result.isValid) validCount++;
    }

    return BatchValidationResult(
      totalItems: medicoes.length,
      validItems: validCount,
      invalidItems: medicoes.length - validCount,
      results: results,
    );
  }

  /// Verifica integridade de dados relacionados
  static bool verifyDataIntegrity(
      List<Medicoes> medicoes, List<Pluviometro> pluviometros) {
    // Verifica se todas as medições têm pluviômetros válidos
    final pluviometroIds = pluviometros.map((p) => p.id).toSet();

    for (final medicao in medicoes) {
      if (!pluviometroIds.contains(medicao.fkPluviometro)) {
        return false;
      }
    }

    return true;
  }

  /// Rate limiting simples para operações sensíveis
  static final Map<String, DateTime> _lastAccess = {};
  static const Duration _rateLimitDuration = Duration(seconds: 1);

  static bool isRateLimited(String operation) {
    final now = DateTime.now();
    final lastAccess = _lastAccess[operation];

    if (lastAccess != null && now.difference(lastAccess) < _rateLimitDuration) {
      return true;
    }

    _lastAccess[operation] = now;
    return false;
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  @override
  String toString() {
    if (isValid) return 'Validação OK';
    return 'Erros: ${errors.join(', ')}';
  }
}

/// Resultado de validação em batch
class BatchValidationResult {
  final int totalItems;
  final int validItems;
  final int invalidItems;
  final Map<String, ValidationResult> results;

  const BatchValidationResult({
    required this.totalItems,
    required this.validItems,
    required this.invalidItems,
    required this.results,
  });

  double get validPercentage => validItems / totalItems * 100;

  bool get hasErrors => invalidItems > 0;

  List<String> get allErrors {
    final errors = <String>[];
    for (final result in results.values) {
      errors.addAll(result.errors);
    }
    return errors;
  }
}

/// Exceção para violações de segurança
class SecurityValidationException implements Exception {
  final String message;
  final String operation;

  SecurityValidationException(this.message, this.operation);

  @override
  String toString() => 'SecurityValidationException[$operation]: $message';
}
