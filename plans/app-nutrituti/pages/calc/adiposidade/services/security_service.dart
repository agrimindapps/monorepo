// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Resultado de validação de segurança
class SecurityValidationResult {
  final bool isSecure;
  final String? vulnerabilityReason;
  final String? sanitizedValue;
  final SecurityThreatLevel threatLevel;

  const SecurityValidationResult({
    required this.isSecure,
    this.vulnerabilityReason,
    this.sanitizedValue,
    this.threatLevel = SecurityThreatLevel.none,
  });

  factory SecurityValidationResult.secure(String sanitizedValue) {
    return SecurityValidationResult(
      isSecure: true,
      sanitizedValue: sanitizedValue,
      threatLevel: SecurityThreatLevel.none,
    );
  }

  factory SecurityValidationResult.insecure({
    required String reason,
    required SecurityThreatLevel threatLevel,
    String? sanitizedValue,
  }) {
    return SecurityValidationResult(
      isSecure: false,
      vulnerabilityReason: reason,
      sanitizedValue: sanitizedValue,
      threatLevel: threatLevel,
    );
  }
}

/// Níveis de ameaça de segurança
enum SecurityThreatLevel {
  none,
  low,
  medium,
  high,
  critical,
}

/// Service responsável por validações de segurança robustas para entrada numérica
class AdiposidadeSecurityService {
  // Padrões de entrada maliciosa conhecidos
  static final List<RegExp> _maliciousPatterns = [
    RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
        caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
    RegExp(r'<\s*iframe', caseSensitive: false),
    RegExp(r'<\s*object', caseSensitive: false),
    RegExp(r'<\s*embed', caseSensitive: false),
    RegExp(r'eval\s*\(', caseSensitive: false),
    RegExp(r'expression\s*\(', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'data:.*base64', caseSensitive: false),
  ];

  // Caracteres permitidos para números (incluindo vírgula/ponto, espaços, sinais)
  static final RegExp _allowedNumericChars = RegExp(r'^[\d\s,.\-+]*$');

  // Padrão para números válidos (inteiros ou decimais)
  static final RegExp _validNumberPattern =
      RegExp(r'^[+-]?(\d+([.,]\d*)?|\.\d+)$');

  /// Validação de segurança para entrada numérica
  static SecurityValidationResult validateNumericInput(
    String input, {
    required String fieldName,
    bool allowNegative = false,
    double? minValue,
    double? maxValue,
    int? maxLength,
  }) {
    // 1. Verificação de entrada vazia
    if (input.isEmpty) {
      return SecurityValidationResult.secure('');
    }

    // 2. Verificação de tamanho excessivo (DoS)
    final maxAllowedLength = maxLength ?? 20;
    if (input.length > maxAllowedLength) {
      return SecurityValidationResult.insecure(
        reason: 'Entrada muito longa - possível tentativa de DoS',
        threatLevel: SecurityThreatLevel.medium,
      );
    }

    // 3. Detecção de padrões maliciosos (XSS, Injection)
    for (final pattern in _maliciousPatterns) {
      if (pattern.hasMatch(input)) {
        return SecurityValidationResult.insecure(
          reason: 'Padrão malicioso detectado - possível tentativa de injeção',
          threatLevel: SecurityThreatLevel.high,
        );
      }
    }

    // 4. Verificação de caracteres permitidos
    if (!_allowedNumericChars.hasMatch(input)) {
      return SecurityValidationResult.insecure(
        reason: 'Caracteres não permitidos detectados',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: _sanitizeInput(input),
      );
    }

    // 5. Sanitização básica
    final sanitized = _sanitizeInput(input);

    // 6. Validação de formato numérico
    if (!_validNumberPattern.hasMatch(sanitized)) {
      return SecurityValidationResult.insecure(
        reason: 'Formato numérico inválido',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: sanitized,
      );
    }

    // 7. Verificação de parsing seguro
    double? parsedValue;
    try {
      parsedValue = double.parse(sanitized.replaceAll(',', '.'));
    } catch (e) {
      return SecurityValidationResult.insecure(
        reason: 'Erro ao processar valor numérico',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: sanitized,
      );
    }

    // 8. Verificação de valores extremos (possível overflow)
    if (parsedValue.isInfinite || parsedValue.isNaN) {
      return SecurityValidationResult.insecure(
        reason: 'Valor numérico inválido (Infinity/NaN)',
        threatLevel: SecurityThreatLevel.medium,
      );
    }

    // 9. Verificação de valores negativos se não permitidos
    if (!allowNegative && parsedValue < 0) {
      return SecurityValidationResult.insecure(
        reason: 'Valores negativos não são permitidos para $fieldName',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: parsedValue.abs().toString(),
      );
    }

    // 10. Verificação de limites de valor
    if (minValue != null && parsedValue < minValue) {
      return SecurityValidationResult.insecure(
        reason: 'Valor abaixo do mínimo permitido ($minValue)',
        threatLevel: SecurityThreatLevel.low,
      );
    }

    if (maxValue != null && parsedValue > maxValue) {
      return SecurityValidationResult.insecure(
        reason: 'Valor acima do máximo permitido ($maxValue)',
        threatLevel: SecurityThreatLevel.medium,
      );
    }

    // 11. Verificação de precision extrema (possível DoS)
    if (_hasExcessivePrecision(sanitized)) {
      return SecurityValidationResult.insecure(
        reason: 'Precisão decimal excessiva detectada',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: _limitPrecision(parsedValue),
      );
    }

    return SecurityValidationResult.secure(sanitized);
  }

  /// Validação específica para circunferência do quadril
  static SecurityValidationResult validateQuadrilSecurity(String input) {
    return validateNumericInput(
      input,
      fieldName: 'circunferência do quadril',
      allowNegative: false,
      minValue: 0.1,
      maxValue: 500.0, // Valor extremo mas seguro
      maxLength: 10,
    );
  }

  /// Validação específica para altura
  static SecurityValidationResult validateAlturaSecurity(String input) {
    return validateNumericInput(
      input,
      fieldName: 'altura',
      allowNegative: false,
      minValue: 0.1,
      maxValue: 500.0, // Valor extremo mas seguro
      maxLength: 10,
    );
  }

  /// Validação específica para idade
  static SecurityValidationResult validateIdadeSecurity(String input) {
    // Para idade, usamos validação de inteiro mais restritiva
    if (input.isEmpty) {
      return SecurityValidationResult.secure('');
    }

    // Verificação de tamanho
    if (input.length > 3) {
      return SecurityValidationResult.insecure(
        reason: 'Idade com muitos dígitos',
        threatLevel: SecurityThreatLevel.low,
      );
    }

    // Verificação de apenas números inteiros
    if (!RegExp(r'^\d+$').hasMatch(input)) {
      return SecurityValidationResult.insecure(
        reason: 'Idade deve conter apenas números inteiros',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: input.replaceAll(RegExp(r'[^\d]'), ''),
      );
    }

    final idade = int.tryParse(input);
    if (idade == null) {
      return SecurityValidationResult.insecure(
        reason: 'Formato de idade inválido',
        threatLevel: SecurityThreatLevel.low,
      );
    }

    if (idade > 200) {
      return SecurityValidationResult.insecure(
        reason: 'Idade excessivamente alta',
        threatLevel: SecurityThreatLevel.medium,
      );
    }

    return SecurityValidationResult.secure(input);
  }

  /// Sanitiza entrada removendo caracteres perigosos
  static String _sanitizeInput(String input) {
    return input
        .replaceAll(
            RegExp(r'[<>"\' ']'), '') // Remove caracteres HTML perigosos
        .replaceAll(RegExp(r'[;&|`${}()\\]'), '') // Remove caracteres de shell
        .trim(); // Remove espaços extras
  }

  /// Verifica se tem precisão decimal excessiva
  static bool _hasExcessivePrecision(String input) {
    final parts = input.split(RegExp(r'[.,]'));
    if (parts.length == 2) {
      return parts[1].length > 10; // Máximo 10 casas decimais
    }
    return false;
  }

  /// Limita a precisão decimal
  static String _limitPrecision(double value, {int precision = 2}) {
    final factor = pow(10, precision);
    final rounded = (value * factor).round() / factor;
    return rounded.toString();
  }

  /// Log de tentativas de entrada maliciosa (para monitoramento)
  static void logSecurityViolation({
    required String input,
    required String reason,
    required SecurityThreatLevel threatLevel,
    String? fieldName,
  }) {
    // Em produção, isso enviaria para um sistema de logging/monitoramento
    debugPrint('SECURITY VIOLATION: $reason');
    debugPrint('Field: ${fieldName ?? "unknown"}');
    debugPrint('Threat Level: ${threatLevel.name}');
    debugPrint(
        'Input: ${input.length > 50 ? "${input.substring(0, 50)}..." : input}');
    debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
  }

  /// Verifica se a entrada é potencialmente maliciosa
  static bool isPotentiallyMalicious(String input) {
    final result = validateNumericInput(input, fieldName: 'test');
    return !result.isSecure &&
        result.threatLevel.index >= SecurityThreatLevel.medium.index;
  }

  /// Obtém estatísticas de segurança para análise
  static Map<String, dynamic> getSecurityStats(List<String> inputs) {
    int totalInputs = inputs.length;
    int secureInputs = 0;
    int maliciousInputs = 0;
    Map<SecurityThreatLevel, int> threatLevels = {};

    for (final input in inputs) {
      final result = validateNumericInput(input, fieldName: 'analysis');
      if (result.isSecure) {
        secureInputs++;
      } else {
        if (result.threatLevel.index >= SecurityThreatLevel.medium.index) {
          maliciousInputs++;
        }
        threatLevels[result.threatLevel] =
            (threatLevels[result.threatLevel] ?? 0) + 1;
      }
    }

    return {
      'totalInputs': totalInputs,
      'secureInputs': secureInputs,
      'securityRate': totalInputs > 0 ? (secureInputs / totalInputs) * 100 : 0,
      'maliciousInputs': maliciousInputs,
      'threatLevelDistribution': threatLevels,
    };
  }
}
