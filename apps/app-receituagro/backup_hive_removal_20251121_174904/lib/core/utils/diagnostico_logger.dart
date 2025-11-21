import 'package:flutter/foundation.dart';

/// Logger centralizado para o sistema de diagnóstico
class DiagnosticoLogger {
  /// Log de informação
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log de warning
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log de erro
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log de erro crítico (sempre logado, mesmo em produção)
  static void critical(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    debugPrint('[CRITICAL] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    // TODO: Integrar com sistema de analytics/crash reporting
    // Exemplo: FirebaseCrashlytics.recordError(error, stackTrace);
  }

  /// Log específico para falhas de resolução de dados dinâmicos
  static void dataResolutionFailure(
    String entityType,
    String id,
    dynamic error,
  ) {
    warning('Falha ao resolver $entityType com ID $id', error);
  }

  /// Log específico para dados incompletos
  static void incompleteData(String context, List<String> missingFields) {
    warning('Dados incompletos em $context: ${missingFields.join(', ')}');
  }

  /// Log condicional para debug (sempre usa debugPrint)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[DEBUG] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }

  /// Log de inicialização de serviços (sempre em debug)
  static void serviceInit(String serviceName, [String? details]) {
    if (kDebugMode) {
      debugPrint(
        '🔧 $serviceName initialized${details != null ? ': $details' : ''}',
      );
    }
  }

  /// Log de operações de dados (sempre em debug)
  static void dataOperation(String operation, String details) {
    if (kDebugMode) {
      debugPrint('📊 $operation: $details');
    }
  }
}
