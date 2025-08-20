// Flutter imports:
import 'package:flutter/foundation.dart';

/// Serviço de segurança para validação robusta de entrada de dados
///
/// Este serviço implementa validações de segurança avançadas para prevenir
/// vulnerabilidades, ataques de injeção e entrada de dados maliciosos.
///
/// 🔒 IMPLEMENTA ISSUE #3 - SECURITY: Validação robusta de entrada
class VolumeSanguineoSecurityService {
  // Padrões maliciosos comuns
  static final List<RegExp> _maliciousPatterns = [
    RegExp(r'<[^>]*script[^>]*>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'vbscript:', caseSensitive: false),
    RegExp(r'onload\s*=', caseSensitive: false),
    RegExp(r'onerror\s*=', caseSensitive: false),
    RegExp(r'eval\s*\(', caseSensitive: false),
    RegExp(r'alert\s*\(', caseSensitive: false),
    RegExp(r'document\.', caseSensitive: false),
    RegExp(r'window\.', caseSensitive: false),
    RegExp(r'<%.*%>', caseSensitive: false),
    RegExp(r'<\?.*\?>', caseSensitive: false),
    RegExp(r'\$\{.*\}', caseSensitive: false),
    RegExp(r'@@.*@@', caseSensitive: false),
  ];

  // Caracteres permitidos para entrada numérica
  static final RegExp _allowedNumericChars = RegExp(r'^[\d\s,.\-+]*$');

  // Padrão para números válidos
  static final RegExp _validNumberPattern =
      RegExp(r'^[+-]?(\d+([.,]\d*)?|\.\d+)$');

  /// Resultado da validação de segurança
  static SecurityValidationResult validateSecureNumericInput(
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

    // 2. Verificação de tamanho excessivo (possível DoS)
    final maxAllowedLength = maxLength ?? 20;
    if (input.length > maxAllowedLength) {
      return SecurityValidationResult.insecure(
        reason: 'Entrada muito longa - possível tentativa de DoS',
        threatLevel: SecurityThreatLevel.medium,
      );
    }

    // 3. Detecção de padrões maliciosos
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

    // 11. Verificação de precisão excessiva (possível DoS)
    if (_hasExcessivePrecision(sanitized)) {
      return SecurityValidationResult.insecure(
        reason: 'Precisão decimal excessiva detectada',
        threatLevel: SecurityThreatLevel.low,
        sanitizedValue: _limitPrecision(parsedValue),
      );
    }

    return SecurityValidationResult.secure(sanitized);
  }

  /// Validação específica para peso corporal
  static SecurityValidationResult validatePesoSecurity(String input) {
    return validateSecureNumericInput(
      input,
      fieldName: 'peso corporal',
      allowNegative: false,
      minValue: 0.5, // Prematuros extremos
      maxValue: 700.0, // Casos extremos documentados
      maxLength: 10,
    );
  }

  /// Sanitiza entrada removendo caracteres perigosos
  static String _sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[^\d\s,.\-+]'), '') // Remove não-numéricos
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliza espaços
        .trim();
  }

  /// Verifica se há precisão decimal excessiva
  static bool _hasExcessivePrecision(String input) {
    if (input.contains('.') || input.contains(',')) {
      final parts = input.replaceAll(',', '.').split('.');
      if (parts.length == 2) {
        return parts[1].length > 4; // Máximo 4 casas decimais
      }
    }
    return false;
  }

  /// Limita a precisão decimal
  static String _limitPrecision(double value, {int precision = 2}) {
    final factor = 10.0 * precision;
    final rounded = (value * factor).round() / factor;
    return rounded.toString();
  }

  /// Log de violações de segurança (para monitoramento)
  static void logSecurityViolation({
    required String input,
    required String reason,
    required SecurityThreatLevel threatLevel,
    String? fieldName,
  }) {
    // Em produção, isso enviaria para um sistema de logging/monitoramento
    debugPrint('🔒 SECURITY VIOLATION: $reason');
    debugPrint('   Field: ${fieldName ?? "unknown"}');
    debugPrint('   Threat Level: ${threatLevel.name}');
    debugPrint('   Input Length: ${input.length}');
    debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
  }

  /// Verifica se a entrada é potencialmente maliciosa
  static bool isPotentiallyMalicious(String input) {
    final result = validateSecureNumericInput(input, fieldName: 'test');
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
      final result = validateSecureNumericInput(input, fieldName: 'analysis');
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
      'total_inputs': totalInputs,
      'secure_inputs': secureInputs,
      'malicious_inputs': maliciousInputs,
      'security_ratio': totalInputs > 0 ? secureInputs / totalInputs : 0.0,
      'threat_levels': threatLevels.map((k, v) => MapEntry(k.name, v)),
    };
  }
}

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
  none, // Nenhuma ameaça
  low, // Ameaça baixa - entrada malformada
  medium, // Ameaça média - possível DoS ou overflow
  high, // Ameaça alta - tentativa de injeção
  critical // Ameaça crítica - padrão malicioso conhecido
}
