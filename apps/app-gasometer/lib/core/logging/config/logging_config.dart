import 'package:core/core.dart' show Hive;

import '../entities/log_entry.dart';

/// Configurações do módulo de logging
class LoggingConfigModule {
  /// Configura o sistema de logging
  static Future<void> configure() async {
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(LogEntryAdapter());
    }
  }
}

/// Configurações padrão do sistema de logging
class LoggingConfig {
  static const String localBoxName = 'logs';
  static const int maxLocalLogs = 10000;
  static const int maxDaysToKeep = 30;
  static const int syncBatchSize = 500;
  static const Duration syncTimeout = Duration(seconds: 30);
  static const Duration syncRetryDelay = Duration(seconds: 5);
  static const Duration operationLogThreshold = Duration(milliseconds: 1000);
  static const bool logDebugInProduction = false;
  static const bool logAnalyticsEvents = true;
  static const Duration cacheCleanupInterval = Duration(hours: 6);
  static const int maxCacheSize = 1000;
  static final List<String> sensitiveKeys = [
    'password',
    'token',
    'secret',
    'key',
    'credential',
    'auth',
  ];

  /// Remove dados sensíveis dos metadados
  static Map<String, dynamic> sanitizeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return {};

    final sanitized = <String, dynamic>{};

    for (final entry in metadata.entries) {
      final key = entry.key.toLowerCase();
      final isSensitive = sensitiveKeys.any(
        (sensitive) => key.contains(sensitive),
      );

      if (isSensitive) {
        sanitized[entry.key] = '***REDACTED***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Verifica se deve logar uma operação baseado no tempo
  static bool shouldLogSlowOperation(int? durationMs) {
    if (durationMs == null) return false;
    return Duration(milliseconds: durationMs) > operationLogThreshold;
  }
}
