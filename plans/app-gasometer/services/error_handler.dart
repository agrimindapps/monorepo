// Dart imports:
import 'dart:developer' as developer;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../errors/gasometer_exceptions.dart';

/// ErrorHandler centralizado para o módulo Gasometer
/// 
/// Responsável por:
/// - Logging estruturado de erros com context preservado
/// - Formatação consistente de mensagens
/// - Categorização de severidade de erros
/// - Integration points para telemetria futura
class GasometerErrorHandler {
  static final GasometerErrorHandler _instance = GasometerErrorHandler._();
  static GasometerErrorHandler get instance => _instance;
  
  GasometerErrorHandler._();

  // MARK: - Error Logging

  /// Registra erro com logging estruturado completo
  void logError(
    Exception exception, {
    String? operation,
    Map<String, dynamic>? additionalContext,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final wrappedException = wrapException(
      exception,
      operation: operation,
      context: additionalContext,
      stackTrace: stackTrace,
    );

    final logData = _createLogData(
      wrappedException,
      operation: operation,
      additionalContext: additionalContext,
      severity: severity,
    );

    // Log baseado na severidade
    switch (severity) {
      case ErrorSeverity.debug:
        _logDebug(logData);
        break;
      case ErrorSeverity.info:
        _logInfo(logData);
        break;
      case ErrorSeverity.warning:
        _logWarning(logData);
        break;
      case ErrorSeverity.error:
        _logError(logData, stackTrace);
        break;
      case ErrorSeverity.fatal:
        _logFatal(logData, stackTrace);
        break;
    }

    // Integração futura com telemetria
    _sendToTelemetry(wrappedException, severity);
  }

  /// Log rápido para exceptions do domínio Gasometer
  void logGasometerException(
    GasometerException exception, {
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    logError(
      exception,
      operation: _extractOperationFromCode(exception.code),
      additionalContext: exception.context,
      stackTrace: exception.stackTrace,
      severity: severity,
    );
  }

  // MARK: - Error Formatting

  /// Formata erro para exibição ao usuário
  String formatUserMessage(Exception exception) {
    if (exception is GasometerException) {
      return _formatGasometerExceptionForUser(exception);
    }
    
    // Fallback para exceptions genéricas
    return _formatGenericExceptionForUser(exception);
  }

  /// Formata erro para logging técnico
  String formatTechnicalMessage(
    Exception exception, {
    String? operation,
    Map<String, dynamic>? context,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== GASOMETER ERROR ===');
    buffer.writeln('Exception: ${exception.runtimeType}');
    buffer.writeln('Message: ${exception.toString()}');
    
    if (operation != null) {
      buffer.writeln('Operation: $operation');
    }
    
    if (exception is GasometerException) {
      buffer.writeln('Code: ${exception.code}');
      if (exception.context != null) {
        buffer.writeln('Context: ${exception.context}');
      }
      if (exception.cause != null) {
        buffer.writeln('Caused by: ${exception.cause}');
      }
    }
    
    if (context != null) {
      buffer.writeln('Additional Context: $context');
    }
    
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    buffer.writeln('========================');
    
    return buffer.toString();
  }

  // MARK: - Error Analysis

  /// Determina se um erro é recuperável
  bool isRecoverable(Exception exception) {
    if (exception is NetworkException) {
      return exception is! NetworkConnectionException;
    }
    
    if (exception is StorageException) {
      return exception is! HiveStorageException;
    }
    
    if (exception is VeiculoException) {
      return exception is VeiculoValidationException;
    }
    
    if (exception is AbastecimentoException) {
      return exception is! AbastecimentoCalculationException;
    }
    
    // Por padrão, assumir que erros são recuperáveis
    return true;
  }

  /// Determina se um erro deve ser mostrado ao usuário
  bool shouldShowToUser(Exception exception) {
    if (exception is GasometerException) {
      // Erros de validação e not found são mostrados ao usuário
      return exception is VeiculoValidationException ||
          exception is AbastecimentoValidationException ||
          exception is OdometroValidationException ||
          exception is DespesaValidationException ||
          exception is ManutencaoValidationException ||
          exception is VeiculoNotFoundException ||
          exception is AbastecimentoNotFoundException ||
          exception is NetworkConnectionException;
    }
    
    return true; // Por padrão, mostrar ao usuário
  }

  /// Categoriza severidade baseada no tipo de exception
  ErrorSeverity categorizeSeverity(Exception exception) {
    if (exception is NetworkConnectionException) {
      return ErrorSeverity.warning;
    }
    
    if (exception is StorageException && exception is HiveStorageException) {
      return ErrorSeverity.fatal;
    }
    
    if (exception is VeiculoValidationException ||
        exception is AbastecimentoValidationException) {
      return ErrorSeverity.info;
    }
    
    if (exception is VeiculoNotFoundException ||
        exception is AbastecimentoNotFoundException) {
      return ErrorSeverity.warning;
    }
    
    return ErrorSeverity.error;
  }

  // MARK: - Private Methods

  Map<String, dynamic> _createLogData(
    GasometerException exception, {
    String? operation,
    Map<String, dynamic>? additionalContext,
    required ErrorSeverity severity,
  }) {
    final logData = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'severity': severity.name,
      'exception_type': exception.runtimeType.toString(),
      'message': exception.message,
      'code': exception.code,
    };

    if (operation != null) {
      logData['operation'] = operation;
    }

    if (exception.context != null) {
      logData['context'] = exception.context;
    }

    if (exception.cause != null) {
      logData['cause'] = exception.cause.toString();
    }

    if (additionalContext != null) {
      logData['additional_context'] = additionalContext;
    }

    return logData;
  }

  void _logDebug(Map<String, dynamic> logData) {
    if (kDebugMode) {
      developer.log(
        'DEBUG: ${logData['message']}',
        name: 'GasometerErrorHandler',
        level: 500,
      );
    }
  }

  void _logInfo(Map<String, dynamic> logData) {
    if (kDebugMode) {
      developer.log(
        'INFO: ${logData['message']}',
        name: 'GasometerErrorHandler',
        level: 800,
      );
    }
  }

  void _logWarning(Map<String, dynamic> logData) {
    developer.log(
      'WARNING: ${logData['message']} | Context: ${logData['context']}',
      name: 'GasometerErrorHandler',
      level: 900,
    );
  }

  void _logError(Map<String, dynamic> logData, StackTrace? stackTrace) {
    developer.log(
      'ERROR: ${logData['message']} | Code: ${logData['code']} | Context: ${logData['context']}',
      name: 'GasometerErrorHandler',
      level: 1000,
      error: logData['exception_type'],
      stackTrace: stackTrace,
    );
  }

  void _logFatal(Map<String, dynamic> logData, StackTrace? stackTrace) {
    developer.log(
      'FATAL: ${logData['message']} | Code: ${logData['code']} | Context: ${logData['context']}',
      name: 'GasometerErrorHandler',
      level: 1200,
      error: logData['exception_type'],
      stackTrace: stackTrace,
    );
  }

  String _formatGasometerExceptionForUser(GasometerException exception) {
    if (exception is VeiculoNotFoundException) {
      return 'Veículo não encontrado. Verifique se foi selecionado corretamente.';
    } else if (exception is VeiculoValidationException) {
      final context = exception.context;
      if (context != null && context.containsKey('field')) {
        return 'Erro no campo ${context['field']}: ${context['reason']}';
      }
      return 'Dados do veículo são inválidos. Verifique as informações.';
    } else if (exception is AbastecimentoValidationException) {
      return 'Dados do abastecimento são inválidos. Verifique as informações.';
    } else if (exception is NetworkConnectionException) {
      return 'Sem conexão com a internet. Verifique sua conexão.';
    } else if (exception is HiveStorageException) {
      return 'Erro ao acessar dados locais. Reinicie o aplicativo.';
    } else {
      return exception.message;
    }
  }

  String _formatGenericExceptionForUser(Exception exception) {
    if (exception.toString().contains('network')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
    
    if (exception.toString().contains('timeout')) {
      return 'Operação demorou muito. Tente novamente.';
    }
    
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  String? _extractOperationFromCode(String code) {
    if (code.contains('_')) {
      final parts = code.split('_');
      return parts.length > 1 ? parts.first.toLowerCase() : null;
    }
    return null;
  }

  void _sendToTelemetry(GasometerException exception, ErrorSeverity severity) {
    // Placeholder para integração futura com Firebase Crashlytics ou similares
    // FirebaseCrashlytics.instance.recordError(
    //   exception,
    //   exception.stackTrace,
    //   information: [
    //     DiagnosticsProperty('severity', severity.name),
    //     DiagnosticsProperty('code', exception.code),
    //     DiagnosticsProperty('context', exception.context),
    //   ],
    // );
  }
}

/// Níveis de severidade de erro
enum ErrorSeverity {
  debug,    // Informações de debug
  info,     // Informações gerais
  warning,  // Avisos que não impedem funcionamento
  error,    // Erros que afetam funcionalidade
  fatal,    // Erros críticos que podem crashar a app
}

/// Extension para facilitar logging de exceptions
extension ExceptionLogging on Exception {
  /// Log rápido da exception
  void log({
    String? operation,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    GasometerErrorHandler.instance.logError(
      this,
      operation: operation,
      additionalContext: context,
      severity: severity,
      stackTrace: StackTrace.current,
    );
  }

  /// Formatar para exibição ao usuário
  String toUserMessage() {
    return GasometerErrorHandler.instance.formatUserMessage(this);
  }

  /// Verificar se é recuperável
  bool get isRecoverable {
    return GasometerErrorHandler.instance.isRecoverable(this);
  }

  /// Verificar se deve ser mostrado ao usuário
  bool get shouldShowToUser {
    return GasometerErrorHandler.instance.shouldShowToUser(this);
  }
}