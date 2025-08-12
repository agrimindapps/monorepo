// Flutter imports:
import 'package:flutter/foundation.dart';

/// Regras e constantes para debug information
/// Centraliza regras para prevenir vazamento de informações sensíveis
class DebugRules {
  // Prevent instantiation
  DebugRules._();

  /// Verificar se debug está habilitado
  static bool get isDebugEnabled => kDebugMode;

  /// Chaves sensíveis que devem ser mascaradas
  static const List<String> sensitiveKeys = [
    'password',
    'token',
    'secret',
    'key', 
    'userid',
    'user_id',
    'email',
    'phone',
    'address',
    'ssn',
    'credit',
    'card',
    'api_key',
    'auth_token',
    'session',
    'cookie',
    'private',
    'firebase',
    'database_url',
    'project_id',
  ];

  /// Métodos que não devem estar em produção
  static const List<String> debugOnlyMethods = [
    'getDebugInfo',
    'debugPrint',
    'printDebug',
    'logDebug',
  ];

  /// Validar se método pode ser executado
  static bool canExecuteDebugMethod(String methodName) {
    if (!isDebugEnabled && debugOnlyMethods.contains(methodName)) {
      return false;
    }
    return true;
  }

  /// Mascarar valor sensível
  static String maskSensitiveValue(String value) {
    if (value.length <= 4) return '***';
    if (value.length <= 8) {
      return '${value.substring(0, 1)}***${value.substring(value.length - 1)}';
    }
    return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
  }

  /// Verificar se chave é sensível
  static bool isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    return sensitiveKeys.any((sensitiveKey) => 
      lowerKey.contains(sensitiveKey) || lowerKey == sensitiveKey
    );
  }

  /// Log seguro (wrapper para debug logging)
  static void safeLog(String message, [Object? data]) {
    if (!isDebugEnabled) return;
    
    if (data != null) {
      debugPrint('🔍 DEBUG: $message - Data: ${_sanitizeForLog(data)}');
    } else {
      debugPrint('🔍 DEBUG: $message');
    }
  }

  /// Sanitizar dados para log
  static String _sanitizeForLog(Object data) {
    final dataStr = data.toString();
    
    // Se contém informação potencialmente sensível
    if (_containsSensitiveInfo(dataStr)) {
      return 'SANITIZED_DATA';
    }
    
    return dataStr;
  }

  /// Verificar se string contém informação sensível
  static bool _containsSensitiveInfo(String text) {
    final lowerText = text.toLowerCase();
    
    // Padrões que indicam dados sensíveis
    final sensitivePatterns = [
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'), // Cartão de crédito
      RegExp(r'\b[A-Za-z0-9+/]{20,}={0,2}\b'), // Base64 encoding
      RegExp(r'\b[a-fA-F0-9]{32,}\b'), // Hashes
      RegExp(r'\b[a-zA-Z0-9+/]{40,}\b'), // Tokens
      RegExp(r'\b\w+@\w+\.\w+\b'), // Email
    ];
    
    for (final pattern in sensitivePatterns) {
      if (pattern.hasMatch(lowerText)) return true;
    }
    
    // Verificar chaves sensíveis
    for (final key in sensitiveKeys) {
      if (lowerText.contains(key)) return true;
    }
    
    return false;
  }

  /// Criar sanitized copy de Map
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> original) {
    if (!isDebugEnabled) {
      return {'message': 'Data only available in debug mode'};
    }

    final sanitized = <String, dynamic>{};
    
    for (final entry in original.entries) {
      if (isSensitiveKey(entry.key)) {
        sanitized[entry.key] = maskSensitiveValue(entry.value?.toString() ?? 'null');
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    
    return sanitized;
  }

  /// Validar se dados podem ser expostos
  static bool canExposeData(Map<String, dynamic> data) {
    if (!isDebugEnabled) return false;
    
    for (final key in data.keys) {
      if (isSensitiveKey(key)) {
        final value = data[key]?.toString();
        if (value != null && !value.contains('***')) {
          return false; // Dados sensíveis não sanitizados
        }
      }
    }
    
    return true;
  }

  /// Obter configuração de debug para ambiente
  static Map<String, dynamic> getDebugConfig() {
    return {
      'debug_enabled': isDebugEnabled,
      'sensitive_keys_count': sensitiveKeys.length,
      'debug_methods_count': debugOnlyMethods.length,
      'environment': isDebugEnabled ? 'debug' : 'production',
    };
  }
}