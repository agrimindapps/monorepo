// Flutter imports:
import 'package:flutter/foundation.dart';

/// Log níveis disponíveis
enum LogLevel { debug, info, warning, error }

/// Serviço centralizado para gerenciamento de informações de debug
/// Garante que informações sensíveis não sejam expostas em produção
class DebugInfoService {
  static final DebugInfoService _instance = DebugInfoService._internal();
  factory DebugInfoService() => _instance;
  DebugInfoService._internal();

  /// Verificar se está em modo debug
  static bool get isDebugMode => kDebugMode;

  /// Obter informações de debug seguras
  Map<String, dynamic> getDebugInfo(Map<String, dynamic> rawData) {
    if (!isDebugMode) {
      return {'message': 'Debug info only available in debug mode'};
    }

    final sanitizedData = <String, dynamic>{};
    
    for (final entry in rawData.entries) {
      sanitizedData[entry.key] = _sanitizeValue(entry.key, entry.value);
    }

    return {
      ...sanitizedData,
      'debug_mode': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Sanitizar valores baseado na chave
  dynamic _sanitizeValue(String key, dynamic value) {
    if (value == null) return 'null';

    // Sanitizar informações sensíveis baseado na chave
    final lowerKey = key.toLowerCase();
    
    if (_isSensitiveKey(lowerKey)) {
      return _maskSensitiveData(value.toString());
    }

    // Para objetos complexos, aplicar recursivamente
    if (value is Map<String, dynamic>) {
      final sanitizedMap = <String, dynamic>{};
      for (final entry in value.entries) {
        sanitizedMap[entry.key] = _sanitizeValue(entry.key, entry.value);
      }
      return sanitizedMap;
    }

    if (value is List) {
      return value.map((item) => _sanitizeValue(key, item)).toList();
    }

    return value;
  }

  /// Verificar se a chave contém informação sensível
  bool _isSensitiveKey(String key) {
    const sensitiveKeys = [
      'password', 'token', 'secret', 'key', 'userid', 'email', 
      'phone', 'address', 'ssn', 'credit', 'card', 'api_key',
      'auth_token', 'session', 'cookie', 'private'
    ];

    return sensitiveKeys.any((sensitiveKey) => key.contains(sensitiveKey));
  }

  /// Mascarar dados sensíveis
  String _maskSensitiveData(String value) {
    if (value.length <= 4) return '***';
    if (value.length <= 8) {
      return '${value.substring(0, 1)}***${value.substring(value.length - 1)}';
    }
    return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
  }

  /// Log seguro (apenas em debug mode)
  void log(String message, {
    LogLevel level = LogLevel.debug,
    Map<String, dynamic>? data,
  }) {
    if (!isDebugMode) return;

    final sanitizedData = data != null ? getDebugInfo(data) : null;
    final timestamp = DateTime.now().toIso8601String();
    
    final prefix = _getLogPrefix(level);
    final dataStr = sanitizedData != null ? ' - Data: $sanitizedData' : '';
    
    // Use debugPrint para melhor integração com Flutter
    debugPrint('$prefix[$timestamp] $message$dataStr');
  }

  /// Obter prefix do log baseado no nível
  String _getLogPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARNING';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }

  /// Validar se dados podem ser expostos
  bool canExposeData(Map<String, dynamic> data) {
    if (!isDebugMode) return false;

    // Verificar se há chaves sensíveis não sanitizadas
    for (final key in data.keys) {
      if (_isSensitiveKey(key.toLowerCase())) {
        final value = data[key];
        if (value != null && !_isAlreadySanitized(value.toString())) {
          return false;
        }
      }
    }
    return true;
  }

  /// Verificar se dados já foram sanitizados
  bool _isAlreadySanitized(String value) {
    return value.contains('***') || value == 'null' || value.length <= 2;
  }

  /// Criar snapshot de debug para análise
  Map<String, dynamic> createDebugSnapshot(String component, Map<String, dynamic> state) {
    if (!isDebugMode) {
      return {'error': 'Debug snapshots only available in debug mode'};
    }

    return {
      'component': component,
      'state': getDebugInfo(state),
      'memory_info': _getMemoryInfo(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Obter informações básicas de memória (se disponível)
  Map<String, dynamic> _getMemoryInfo() {
    // Informações básicas que podem ser úteis para debug
    return {
      'dart_version': 'runtime',
      'debug_mode': isDebugMode,
      'platform': defaultTargetPlatform.name,
    };
  }

  /// Limpar logs antigos (implementação futura se necessário)
  void clearOldLogs() {
    if (!isDebugMode) return;
    // Implementação para limpar logs antigos se necessário
  }

  /// Obter estatísticas de uso do debug service
  Map<String, dynamic> getUsageStats() {
    if (!isDebugMode) {
      return {'message': 'Stats only available in debug mode'};
    }

    return {
      'debug_mode': isDebugMode,
      'service_initialized': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Extension para facilitar uso do DebugInfoService
extension DebugInfoServiceExtension on Object {
  /// Log this object safely
  void debugLog(String message, {LogLevel level = LogLevel.debug}) {
    final debugService = DebugInfoService();
    final data = {'object': toString(), 'type': runtimeType.toString()};
    debugService.log(message, level: level, data: data);
  }
}