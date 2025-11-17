import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

/// Níveis de severidade para logging
enum LogLevel {
  /// Informações de debug (apenas em modo debug)
  debug,

  /// Informações gerais sobre operações
  info,

  /// Avisos sobre situações não críticas
  warning,

  /// Erros que afetam funcionalidade
  error,

  /// Erros críticos que podem causar crash ou perda de dados
  critical,
}

/// Serviço centralizado de logging para operações financeiras com suporte para:
/// - Logs estruturados com metadata
/// - Diferentes níveis de severidade
/// - Integração com Firebase Crashlytics
/// - Logging específico para operações financeiras (auditoria)
/// - Sanitização de dados sensíveis
///
/// Complementa o LoggingService existente com funcionalidades específicas
/// para logging de dados financeiros e auditoria
class FinancialLoggingService {
  final FirebaseCrashlytics? _crashlytics;
  final bool _enableCrashlytics;

  FinancialLoggingService({
    FirebaseCrashlytics? crashlytics,
    bool enableCrashlytics = true,
  }) : _crashlytics = crashlytics,
       _enableCrashlytics = enableCrashlytics;

  /// Factory para criar instância com Crashlytics ativado
  factory FinancialLoggingService.withCrashlytics() {
    return FinancialLoggingService(
      crashlytics: FirebaseCrashlytics.instance,
      enableCrashlytics: true,
    );
  }

  /// Factory para criar instância sem Crashlytics (testes)
  factory FinancialLoggingService.withoutCrashlytics() {
    return FinancialLoggingService(crashlytics: null, enableCrashlytics: false);
  }

  /// Log estruturado com metadata
  void log({
    required LogLevel level,
    required String message,
    Map<String, dynamic>? metadata,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final enrichedMessage = _buildEnrichedMessage(message, metadata);
    final sanitizedMessage = _sanitizeMessage(enrichedMessage);

    // Console logging (apenas em debug ou para erros)
    if (kDebugMode || level.index >= LogLevel.error.index) {
      _logToConsole(level, sanitizedMessage, error, stackTrace);
    }

    // Crashlytics logging (apenas warning e acima)
    if (_enableCrashlytics &&
        _crashlytics != null &&
        level.index >= LogLevel.warning.index) {
      _logToCrashlytics(level, sanitizedMessage, error, stackTrace);
    }
  }

  /// Log para console com formatação colorida
  void _logToConsole(
    LogLevel level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final icon = _getLogIcon(level);
    final timestamp = DateTime.now().toIso8601String();

    debugPrint('$icon [$timestamp] [${level.name.toUpperCase()}] $message');

    if (error != null) {
      debugPrint('  Error: $error');
    }

    if (stackTrace != null && level.index >= LogLevel.error.index) {
      debugPrint('  Stack trace:');
      debugPrint('  ${stackTrace.toString().split('\n').take(5).join('\n  ')}');
    }
  }

  /// Log para Firebase Crashlytics
  void _logToCrashlytics(
    LogLevel level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    try {
      // Log mensagem
      _crashlytics?.log('${level.name.toUpperCase()}: $message');

      // Record error para warning e acima
      if (level.index >= LogLevel.error.index && error != null) {
        _crashlytics?.recordError(
          error,
          stackTrace,
          fatal: level == LogLevel.critical,
          reason: message,
        );
      }
    } catch (e) {
      // Falha silenciosa no Crashlytics não deve afetar a aplicação
      if (kDebugMode) {
        debugPrint('⚠️ Failed to log to Crashlytics: $e');
      }
    }
  }

  /// Constrói mensagem enriquecida com metadata
  String _buildEnrichedMessage(String message, Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return message;

    final buffer = StringBuffer(message);
    buffer.writeln();
    buffer.writeln('  Metadata:');

    metadata.forEach((key, value) {
      final sanitizedValue = _sanitizeValue(key, value);
      buffer.writeln('    $key: $sanitizedValue');
    });

    return buffer.toString();
  }

  /// Sanitiza mensagem removendo dados sensíveis
  String _sanitizeMessage(String message) {
    return message
        // Senhas
        .replaceAll(
          RegExp(r'password[\s:=][\w]+', caseSensitive: false),
          'password=[REDACTED]',
        )
        // Tokens
        .replaceAll(
          RegExp(r'token[\s:=][\w\-._]+', caseSensitive: false),
          'token=[REDACTED]',
        )
        // API Keys
        .replaceAll(
          RegExp(r'key[\s:=][\w\-._]+', caseSensitive: false),
          'key=[REDACTED]',
        )
        // Secrets
        .replaceAll(
          RegExp(r'secret[\s:=][\w\-._]+', caseSensitive: false),
          'secret=[REDACTED]',
        )
        // Emails
        .replaceAll(
          RegExp(r'[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}'),
          '[EMAIL_REDACTED]',
        )
        // Cartões de crédito
        .replaceAll(
          RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
          '[CARD_REDACTED]',
        )
        // CPF
        .replaceAll(
          RegExp(r'\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b'),
          '[CPF_REDACTED]',
        );
  }

  /// Sanitiza valor baseado na chave
  String _sanitizeValue(String key, dynamic value) {
    final keyLower = key.toLowerCase();

    // Campos sensíveis devem ser redacted
    if (_isSensitiveKey(keyLower)) {
      return '[REDACTED]';
    }

    // User IDs devem ser parcialmente mascarados
    if (keyLower.contains('user') && keyLower.contains('id')) {
      final valueStr = value.toString();
      if (valueStr.length > 8) {
        return '${valueStr.substring(0, 4)}...${valueStr.substring(valueStr.length - 4)}';
      }
    }

    return value.toString();
  }

  /// Verifica se a chave contém informação sensível
  bool _isSensitiveKey(String key) {
    const sensitivePatterns = [
      'password',
      'secret',
      'token',
      'api_key',
      'credential',
      'auth',
      'session',
      'private',
      'cpf',
      'card',
      'credit',
    ];

    return sensitivePatterns.any((pattern) => key.contains(pattern));
  }

  /// Retorna ícone baseado no nível de log
  String _getLogIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  // ========== Convenience Methods ==========

  /// Log de debug (apenas em modo debug)
  void debug(String message, [Map<String, dynamic>? metadata]) {
    log(level: LogLevel.debug, message: message, metadata: metadata);
  }

  /// Log de informação
  void info(String message, [Map<String, dynamic>? metadata]) {
    log(level: LogLevel.info, message: message, metadata: metadata);
  }

  /// Log de warning
  void warning(
    String message, {
    Map<String, dynamic>? metadata,
    dynamic error,
  }) {
    log(
      level: LogLevel.warning,
      message: message,
      metadata: metadata,
      error: error,
    );
  }

  /// Log de error
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    log(
      level: LogLevel.error,
      message: message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// Log de error crítico
  void critical(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    log(
      level: LogLevel.critical,
      message: message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  // ========== Financial Operations Logging ==========

  /// Log específico para operações financeiras (CREATE, UPDATE, DELETE)
  /// Registra operações em dados financeiros com contexto completo
  void logFinancialOperation({
    required String operation, // CREATE, UPDATE, DELETE, SYNC
    required String entityType, // fuel_supply, maintenance, expense
    required String entityId,
    double? amount,
    String? vehicleId,
    Map<String, dynamic>? additionalData,
  }) {
    log(
      level: LogLevel.info,
      message: '[Financial] $operation: $entityType',
      metadata: {
        'operation': operation,
        'entity_type': entityType,
        'entity_id': entityId,
        if (amount != null) 'amount': amount,
        if (vehicleId != null) 'vehicle_id': vehicleId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  /// Log para conflitos de sincronização financeira
  void logFinancialConflict({
    required String entityType,
    required String entityId,
    required dynamic localData,
    required dynamic remoteData,
    String? resolution,
  }) {
    log(
      level: LogLevel.warning,
      message: '[Financial Conflict] $entityType conflict detected',
      metadata: {
        'entity_type': entityType,
        'entity_id': entityId,
        'local_version': localData?.toString() ?? 'null',
        'remote_version': remoteData?.toString() ?? 'null',
        if (resolution != null) 'resolution': resolution,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log para erros de validação financeira
  void logFinancialValidationError({
    required String entityType,
    required String fieldName,
    required dynamic invalidValue,
    required String constraint,
    Map<String, dynamic>? additionalContext,
  }) {
    log(
      level: LogLevel.error,
      message: '[Financial Validation] Invalid $fieldName for $entityType',
      metadata: {
        'entity_type': entityType,
        'field_name': fieldName,
        'invalid_value': invalidValue.toString(),
        'constraint': constraint,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalContext,
      },
    );
  }

  /// Log para falhas de sincronização
  void logSyncFailure({
    required String entityType,
    required String entityId,
    required Failure failure,
    int? retryAttempt,
  }) {
    log(
      level: LogLevel.error,
      message: '[Sync Failure] Failed to sync $entityType',
      error: failure,
      metadata: {
        'entity_type': entityType,
        'entity_id': entityId,
        'failure_type': failure.runtimeType.toString(),
        'failure_code': failure.code,
        if (retryAttempt != null) 'retry_attempt': retryAttempt,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log para operações de imagem (upload/download)
  void logImageOperation({
    required String operation, // upload, download, compress
    required String imagePath,
    bool success = true,
    String? errorMessage,
    int? fileSizeBytes,
  }) {
    log(
      level: success ? LogLevel.info : LogLevel.error,
      message:
          '[Image] $operation ${success ? 'succeeded' : 'failed'}: $imagePath',
      metadata: {
        'operation': operation,
        'image_path': imagePath,
        'success': success,
        if (errorMessage != null) 'error_message': errorMessage,
        if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log para operações de reconciliação de IDs
  void logIdReconciliation({
    required String entityType,
    required String localId,
    String? remoteId,
    bool success = true,
    String? errorMessage,
  }) {
    log(
      level: success ? LogLevel.info : LogLevel.error,
      message:
          '[ID Reconciliation] ${success ? 'Success' : 'Failed'}: $entityType',
      metadata: {
        'entity_type': entityType,
        'local_id': localId,
        if (remoteId != null) 'remote_id': remoteId,
        'success': success,
        if (errorMessage != null) 'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Define custom key para Crashlytics (útil para contexto do usuário)
  void setCustomKey(String key, dynamic value) {
    if (!_enableCrashlytics || _crashlytics == null) return;

    try {
      // Sanitiza valor antes de enviar
      final sanitizedValue = _sanitizeValue(key, value);
      _crashlytics.setCustomKey(key, sanitizedValue);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to set custom key in Crashlytics: $e');
      }
    }
  }

  /// Define user ID para Crashlytics
  void setUserId(String? userId) {
    if (!_enableCrashlytics || _crashlytics == null || userId == null) return;

    try {
      // Mascara parcialmente o user ID para privacidade
      final maskedUserId = userId.length > 8
          ? '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}'
          : userId;
      _crashlytics.setUserIdentifier(maskedUserId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to set user ID in Crashlytics: $e');
      }
    }
  }
}
