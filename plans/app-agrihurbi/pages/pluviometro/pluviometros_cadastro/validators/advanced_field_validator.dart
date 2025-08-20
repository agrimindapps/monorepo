// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../utils/type_conversion_utils.dart';

/// Validador avançado para campos de pluviômetros
class AdvancedFieldValidator {
  /// Valida faixa de valores da quantidade
  static ValidationResult validateQuantidadeRange(double quantidade) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validação básica
    if (quantidade < 0) {
      errors.add('Quantidade não pode ser negativa');
    }

    if (quantidade > 1000) {
      errors.add('Quantidade não pode ser maior que 1000mm');
    }

    // Validações de warning para valores atípicos
    if (quantidade > 500) {
      warnings.add('Quantidade muito alta para medição diária típica');
    }

    if (quantidade > 200) {
      warnings.add('Quantidade alta - verifique se está correto');
    }

    if (quantidade == 0) {
      warnings.add('Quantidade zero - confirme se é uma medição válida');
    }

    // Validação de precisão decimal
    final decimalPlaces = _getDecimalPlaces(quantidade);
    if (decimalPlaces > 2) {
      warnings.add(
          'Quantidade com muitas casas decimais - considerando apenas 2 casas');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida formato da descrição
  static ValidationResult validateDescricaoFormat(String descricao) {
    final errors = <String>[];
    final warnings = <String>[];

    if (descricao.trim().isEmpty) {
      errors.add('Descrição é obrigatória');
    }

    if (descricao.length < 3) {
      errors.add('Descrição deve ter pelo menos 3 caracteres');
    }

    if (descricao.length > 80) {
      errors.add('Descrição deve ter no máximo 80 caracteres');
    }

    // Validação de formato
    if (!_isValidDescricaoFormat(descricao)) {
      warnings.add('Descrição contém caracteres especiais incomuns');
    }

    // Validação de conteúdo
    if (_containsNumbersOnly(descricao)) {
      warnings.add(
          'Descrição contém apenas números - considere adicionar texto descritivo');
    }

    if (_containsRepeatedChars(descricao)) {
      warnings.add(
          'Descrição contém caracteres repetidos - verifique se está correto');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida unicidade da descrição
  static Future<ValidationResult> validateDescricaoUniqueness(
      String descricao, List<Pluviometro> existingPluviometros,
      {String? excludeId}) async {
    final errors = <String>[];
    final warnings = <String>[];

    final normalizedDescricao = descricao.trim().toLowerCase();

    for (final pluviometro in existingPluviometros) {
      if (excludeId != null && pluviometro.id == excludeId) {
        continue; // Pula o próprio registro durante edição
      }

      final existingDescricao = pluviometro.descricao.trim().toLowerCase();

      if (existingDescricao == normalizedDescricao) {
        errors.add('Já existe um pluviômetro com esta descrição');
        break;
      }

      if (_isSimilarDescription(normalizedDescricao, existingDescricao)) {
        warnings.add('Descrição similar já existe: "${pluviometro.descricao}"');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida coordenadas geográficas
  static ValidationResult validateCoordinates(
      String? latitude, String? longitude) {
    final errors = <String>[];
    final warnings = <String>[];

    if (latitude != null && latitude.isNotEmpty) {
      if (!TypeConversionUtils.isValidDouble(latitude)) {
        errors.add('Latitude deve ser um número válido');
      } else {
        final lat = TypeConversionUtils.safeDoubleFromString(latitude);
        if (lat < -90 || lat > 90) {
          errors.add('Latitude deve estar entre -90 e 90');
        }
      }
    }

    if (longitude != null && longitude.isNotEmpty) {
      if (!TypeConversionUtils.isValidDouble(longitude)) {
        errors.add('Longitude deve ser um número válido');
      } else {
        final lng = TypeConversionUtils.safeDoubleFromString(longitude);
        if (lng < -180 || lng > 180) {
          errors.add('Longitude deve estar entre -180 e 180');
        }
      }
    }

    // Validação de consistência
    final hasLat = latitude != null && latitude.isNotEmpty;
    final hasLng = longitude != null && longitude.isNotEmpty;

    if (hasLat && !hasLng) {
      warnings
          .add('Latitude informada mas longitude não - localização incompleta');
    }

    if (hasLng && !hasLat) {
      warnings
          .add('Longitude informada mas latitude não - localização incompleta');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida regras de negócio específicas
  static ValidationResult validateBusinessRules(Pluviometro pluviometro) {
    final errors = <String>[];
    final warnings = <String>[];

    // Regra: Pluviômetro deve ter localização para ser útil
    if (!pluviometro.hasCoordinates()) {
      warnings.add(
          'Pluviômetro sem coordenadas - funcionalidades de localização limitadas');
    }

    // Regra: Descrição deve ser informativa
    if (pluviometro.descricao.length < 5) {
      warnings.add('Descrição muito curta - considere adicionar mais detalhes');
    }

    // Regra: Quantidade deve ser razoável para contexto
    final quantidade = pluviometro.getQuantidadeAsDouble();
    if (quantidade > 100) {
      warnings
          .add('Quantidade alta - verifique se é uma precipitação acumulada');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida contexto baseado em dados históricos
  static ValidationResult validateContextualData(
    Pluviometro pluviometro,
    List<Pluviometro> historicalData,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (historicalData.isEmpty) {
      return ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final quantidade = pluviometro.getQuantidadeAsDouble();
    final quantidades =
        historicalData.map((p) => p.getQuantidadeAsDouble()).toList();

    // Calcular estatísticas
    final media = quantidades.reduce((a, b) => a + b) / quantidades.length;
    final max = quantidades.reduce((a, b) => a > b ? a : b);
    final min = quantidades.reduce((a, b) => a < b ? a : b);

    // Validação contextual
    if (quantidade > max * 1.5) {
      warnings.add(
          'Quantidade muito acima do máximo histórico (${max.toStringAsFixed(2)}mm)');
    }

    if (quantidade > media * 3) {
      warnings.add(
          'Quantidade muito acima da média histórica (${media.toStringAsFixed(2)}mm)');
    }

    if (quantidade < min && quantidade > 0) {
      warnings.add(
          'Quantidade abaixo do mínimo histórico (${min.toStringAsFixed(2)}mm)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validação em tempo real com debounce
  static Future<ValidationResult> validateRealTime(
      String fieldName, String value,
      {Duration debounceTime = const Duration(milliseconds: 300)}) async {
    // Simula debounce
    await Future.delayed(debounceTime);

    switch (fieldName) {
      case 'descricao':
        return validateDescricaoFormat(value);
      case 'quantidade':
        if (TypeConversionUtils.isValidDouble(value)) {
          final quantidade = TypeConversionUtils.safeDoubleFromString(value);
          return validateQuantidadeRange(quantidade);
        }
        return ValidationResult(
          isValid: false,
          errors: ['Quantidade deve ser um número válido'],
          warnings: [],
        );
      case 'latitude':
        return validateCoordinates(value, null);
      case 'longitude':
        return validateCoordinates(null, value);
      default:
        return ValidationResult(isValid: true, errors: [], warnings: []);
    }
  }

  // Métodos auxiliares privados

  static int _getDecimalPlaces(double value) {
    final str = value.toString();
    if (!str.contains('.')) return 0;
    return str.split('.')[1].length;
  }

  static bool _isValidDescricaoFormat(String descricao) {
    // Aceita letras, números, espaços e alguns caracteres especiais comuns
    final pattern = RegExp(r'^[a-zA-Z0-9\s\-_.,()]+$');
    return pattern.hasMatch(descricao);
  }

  static bool _containsNumbersOnly(String descricao) {
    final pattern = RegExp(r'^\d+$');
    return pattern.hasMatch(descricao.trim());
  }

  static bool _containsRepeatedChars(String descricao) {
    final pattern = RegExp(r'(.)\1{3,}'); // 4 ou mais caracteres repetidos
    return pattern.hasMatch(descricao);
  }

  static bool _isSimilarDescription(String desc1, String desc2) {
    // Algoritmo simples de similaridade
    final minLength = desc1.length < desc2.length ? desc1.length : desc2.length;
    final maxLength = desc1.length > desc2.length ? desc1.length : desc2.length;

    if (minLength == 0) return false;

    int matches = 0;
    for (int i = 0; i < minLength; i++) {
      if (desc1[i] == desc2[i]) matches++;
    }

    final similarity = matches / maxLength;
    return similarity > 0.8; // 80% de similaridade
  }
}

/// Resultado de validação avançada
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  String get errorMessage => errors.join('\n');
  String get warningMessage => warnings.join('\n');

  String get allMessages {
    final messages = <String>[];
    if (errors.isNotEmpty) messages.add('Erros: ${errors.join(', ')}');
    if (warnings.isNotEmpty) messages.add('Avisos: ${warnings.join(', ')}');
    return messages.join('\n');
  }

  @override
  String toString() {
    if (isValid && warnings.isEmpty) return 'Validação OK';
    return allMessages;
  }
}
