// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'validation_utils.dart';

/// Tipos de erro padronizados
enum ErrorType {
  network,
  validation,
  authentication,
  authorization,
  notFound,
  serverError,
  timeout,
  unknown,
}

/// Severidade do erro
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Classe representando um erro estruturado
class StructuredError {
  final String code;
  final String message;
  final String userMessage;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final Object? originalError;
  final StackTrace? stackTrace;
  final bool canRetry;
  final Duration? retryDelay;

  StructuredError({
    required this.code,
    required this.message,
    required this.userMessage,
    required this.type,
    required this.severity,
    this.context,
    this.originalError,
    this.stackTrace,
    this.canRetry = false,
    this.retryDelay,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'userMessage': userMessage,
      'type': type.name,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'canRetry': canRetry,
      'retryDelay': retryDelay?.inMilliseconds,
    };
  }

  @override
  String toString() => 'StructuredError($code: $message)';
}

/// Estratégias de tratamento de erro
abstract class ErrorHandlingStrategy {
  StructuredError handleError(Object error, StackTrace? stackTrace);
}

/// Estratégia para erros de rede
class NetworkErrorStrategy implements ErrorHandlingStrategy {
  @override
  StructuredError handleError(Object error, StackTrace? stackTrace) {
    String message = error.toString();
    String userMessage = 'Erro de conexão. Verifique sua internet.';
    String code = 'NETWORK_ERROR';
    bool canRetry = true;
    Duration retryDelay = const Duration(seconds: 5);

    if (message.contains('timeout')) {
      code = 'NETWORK_TIMEOUT';
      userMessage = 'Tempo limite de conexão excedido.';
      retryDelay = const Duration(seconds: 3);
    } else if (message.contains('404')) {
      code = 'NETWORK_NOT_FOUND';
      userMessage = 'Recurso não encontrado.';
      canRetry = false;
    } else if (message.contains('500')) {
      code = 'NETWORK_SERVER_ERROR';
      userMessage = 'Erro interno do servidor.';
      retryDelay = const Duration(seconds: 10);
    }

    return StructuredError(
      code: code,
      message: message,
      userMessage: userMessage,
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      originalError: error,
      stackTrace: stackTrace,
      canRetry: canRetry,
      retryDelay: retryDelay,
    );
  }
}

/// Estratégia para erros de validação
class ValidationErrorStrategy implements ErrorHandlingStrategy {
  @override
  StructuredError handleError(Object error, StackTrace? stackTrace) {
    String message = error.toString();
    String userMessage = 'Dados inválidos fornecidos.';
    String code = 'VALIDATION_ERROR';

    if (message.contains('timestamp')) {
      code = 'VALIDATION_TIMESTAMP';
      userMessage = 'Data/hora inválida.';
    } else if (message.contains('medição')) {
      code = 'VALIDATION_MEASUREMENT';
      userMessage = 'Valor de medição inválido.';
    } else if (message.contains('entrada')) {
      code = 'VALIDATION_INPUT';
      userMessage = 'Entrada de dados inválida.';
    }

    return StructuredError(
      code: code,
      message: message,
      userMessage: userMessage,
      type: ErrorType.validation,
      severity: ErrorSeverity.medium,
      originalError: error,
      stackTrace: stackTrace,
      canRetry: false,
    );
  }
}

/// Estratégia para erros desconhecidos
class UnknownErrorStrategy implements ErrorHandlingStrategy {
  @override
  StructuredError handleError(Object error, StackTrace? stackTrace) {
    return StructuredError(
      code: 'UNKNOWN_ERROR',
      message: error.toString(),
      userMessage: 'Erro inesperado. Tente novamente.',
      type: ErrorType.unknown,
      severity: ErrorSeverity.high,
      originalError: error,
      stackTrace: stackTrace,
      canRetry: true,
      retryDelay: const Duration(seconds: 2),
    );
  }
}

/// Centralizador de tratamento de erros
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  static ErrorHandlerService get instance => _instance;

  ErrorHandlerService._internal();

  final Map<Type, ErrorHandlingStrategy> _strategies = {
    NetworkException: NetworkErrorStrategy(),
    ValidationException: ValidationErrorStrategy(),
    InvalidTimestampException: ValidationErrorStrategy(),
    InvalidMeasurementException: ValidationErrorStrategy(),
    InvalidInputException: ValidationErrorStrategy(),
  };

  final List<StructuredError> _errorHistory = [];
  final int _maxHistorySize = 100;

  /// Registra uma nova estratégia de tratamento
  void registerStrategy<T>(ErrorHandlingStrategy strategy) {
    _strategies[T] = strategy;
  }

  /// Trata um erro de forma estruturada
  StructuredError handleError(Object error, [StackTrace? stackTrace]) {
    final strategy = _strategies[error.runtimeType] ?? UnknownErrorStrategy();
    final structuredError = strategy.handleError(error, stackTrace);

    // Adicionar ao histórico
    _addToHistory(structuredError);

    // Log estruturado
    _logError(structuredError);

    return structuredError;
  }

  /// Adiciona erro ao histórico
  void _addToHistory(StructuredError error) {
    _errorHistory.insert(0, error);

    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeRange(_maxHistorySize, _errorHistory.length);
    }
  }

  /// Faz log estruturado do erro
  void _logError(StructuredError error) {
    final logMessage =
        '[${error.severity.name.toUpperCase()}] ${error.code}: ${error.message}';

    switch (error.severity) {
      case ErrorSeverity.low:
        debugPrint('🔵 $logMessage');
        break;
      case ErrorSeverity.medium:
        debugPrint('🟡 $logMessage');
        break;
      case ErrorSeverity.high:
        debugPrint('🟠 $logMessage');
        break;
      case ErrorSeverity.critical:
        debugPrint('🔴 $logMessage');
        if (error.stackTrace != null) {
          debugPrint('Stack trace: ${error.stackTrace}');
        }
        break;
    }
  }

  /// Obtém histórico de erros
  List<StructuredError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Obtém estatísticas de erro
  Map<String, dynamic> getErrorStats() {
    final stats = <String, dynamic>{
      'total_errors': _errorHistory.length,
      'by_type': <String, int>{},
      'by_severity': <String, int>{},
      'recent_errors': _errorHistory.take(10).map((e) => e.toJson()).toList(),
    };

    for (final error in _errorHistory) {
      final type = error.type.name;
      final severity = error.severity.name;

      stats['by_type'][type] = (stats['by_type'][type] ?? 0) + 1;
      stats['by_severity'][severity] =
          (stats['by_severity'][severity] ?? 0) + 1;
    }

    return stats;
  }

  /// Limpa histórico de erros
  void clearHistory() {
    _errorHistory.clear();
  }

  /// Verifica se um erro pode ser recuperado automaticamente
  bool canAutoRecover(StructuredError error) {
    return error.canRetry &&
        error.severity != ErrorSeverity.critical &&
        error.type != ErrorType.validation;
  }

  /// Obtém atraso sugerido para retry
  Duration getRetryDelay(StructuredError error) {
    return error.retryDelay ?? const Duration(seconds: 2);
  }
}

/// Exceções personalizadas
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class AuthorizationException implements Exception {
  final String message;
  const AuthorizationException(this.message);

  @override
  String toString() => 'AuthorizationException: $message';
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
