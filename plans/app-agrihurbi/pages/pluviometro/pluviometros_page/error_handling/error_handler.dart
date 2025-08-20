// Dart imports:
import 'dart:developer' as developer;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'pluviometro_exceptions.dart';

/// Handler centralizado para tratamento de erros do módulo pluviômetros
class PluviometroErrorHandler {
  static PluviometroErrorHandler? _instance;
  static PluviometroErrorHandler get instance =>
      _instance ??= PluviometroErrorHandler._internal();

  PluviometroErrorHandler._internal();

  final List<ErrorListener> _listeners = [];
  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastErrorTimes = {};

  /// Adiciona um listener para notificações de erro
  void addListener(ErrorListener listener) {
    _listeners.add(listener);
  }

  /// Remove um listener
  void removeListener(ErrorListener listener) {
    _listeners.remove(listener);
  }

  /// Processa e trata um erro
  ErrorResponse handleError(dynamic error, [StackTrace? stackTrace]) {
    final processedError = _processError(error, stackTrace);

    // Registrar erro para analytics/logging
    _logError(processedError);

    // Verificar se precisa de retry
    final retryInfo = _shouldRetry(processedError);

    // Notificar listeners
    _notifyListeners(processedError);

    return ErrorResponse(
      exception: processedError,
      userMessage: _generateUserMessage(processedError),
      canRetry: retryInfo.canRetry,
      retryDelay: retryInfo.delay,
      shouldShowDialog: _shouldShowDialog(processedError),
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
        'error_count': _getErrorCount(processedError.code),
        'user_action_required': _requiresUserAction(processedError),
      },
    );
  }

  /// Processa erro raw em PluviometroException estruturada
  PluviometroException _processError(dynamic error, StackTrace? stackTrace) {
    if (error is PluviometroException) {
      return error;
    }

    // Converter erros comuns em exceções específicas
    if (error is FormatException) {
      return ValidationException(
        validationErrors: [
          ValidationError(
            field: 'format',
            code: 'invalid_format',
            message: 'Formato de dados inválido: ${error.message}',
            severity: ValidationSeverity.error,
          ),
        ],
        stackTrace: stackTrace,
      );
    }

    // Erros de rede simulados (em um cenário real, seria baseado em http exceptions)
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return NetworkException(
        message: 'Falha na conexão de rede',
        statusCode: null,
        stackTrace: stackTrace,
      );
    }

    // Timeout
    if (error.toString().contains('timeout')) {
      return NetworkException(
        message: 'Operação excedeu tempo limite',
        statusCode: 408,
        stackTrace: stackTrace,
      );
    }

    // Erro genérico
    return OperationException(
      operation: 'unknown',
      reason: error.toString(),
      message: 'Erro inesperado ocorreu',
      stackTrace: stackTrace,
    );
  }

  /// Gera mensagem amigável para o usuário
  String _generateUserMessage(PluviometroException error) {
    switch (error.runtimeType) {
      case ValidationException:
        final validationError = error as ValidationException;
        if (validationError.validationErrors.length == 1) {
          return validationError.validationErrors.first.message;
        }
        return 'Verifique os dados informados e tente novamente';

      case NetworkException:
        final networkError = error as NetworkException;
        if (networkError.isTimeout) {
          return 'A operação demorou mais que o esperado. Verifique sua conexão e tente novamente';
        }
        if (networkError.isConnectivityIssue) {
          return 'Problema de conectividade. Verifique sua conexão com a internet';
        }
        if (networkError.isServerError) {
          return 'Problema no servidor. Tente novamente em alguns minutos';
        }
        return 'Erro de comunicação. Tente novamente';

      case AuthorizationException:
        return 'Você não tem permissão para realizar esta operação';

      case DataNotFoundException:
        final notFoundError = error as DataNotFoundException;
        return notFoundError.detailedMessage;

      case DataConflictException:
        return 'Já existe um registro com essas informações';

      case RateLimitException:
        final rateLimitError = error as RateLimitException;
        return 'Muitas tentativas. Aguarde ${rateLimitError.retryAfter.inSeconds} segundos';

      case ConfigurationException:
        return 'Erro de configuração do sistema. Contate o suporte';

      default:
        return 'Ocorreu um erro inesperado. Tente novamente';
    }
  }

  /// Verifica se operação deve ser tentada novamente
  RetryInfo _shouldRetry(PluviometroException error) {
    switch (error.runtimeType) {
      case NetworkException:
        final networkError = error as NetworkException;
        if (networkError.isTimeout || networkError.isConnectivityIssue) {
          return const RetryInfo(canRetry: true, delay: Duration(seconds: 2));
        }
        if (networkError.isServerError) {
          return const RetryInfo(canRetry: true, delay: Duration(seconds: 5));
        }
        return const RetryInfo(canRetry: false);

      case RateLimitException:
        final rateLimitError = error as RateLimitException;
        return RetryInfo(canRetry: true, delay: rateLimitError.retryAfter);

      case OperationException:
        // Retry apenas se não foi erro de validação
        return const RetryInfo(canRetry: true, delay: Duration(seconds: 1));

      default:
        return const RetryInfo(canRetry: false);
    }
  }

  /// Verifica se deve mostrar dialog de erro
  bool _shouldShowDialog(PluviometroException error) {
    switch (error.runtimeType) {
      case AuthorizationException:
      case ConfigurationException:
        return true;
      case NetworkException:
        final networkError = error as NetworkException;
        return networkError.isServerError;
      default:
        return false;
    }
  }

  /// Verifica se requer ação do usuário
  bool _requiresUserAction(PluviometroException error) {
    return error is ValidationException ||
        error is AuthorizationException ||
        error is DataConflictException;
  }

  /// Registra erro para logging
  void _logError(PluviometroException error) {
    final errorKey = '${error.runtimeType}_${error.code}';
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    _lastErrorTimes[errorKey] = DateTime.now();

    // Log estruturado
    final logData = {
      'error_type': error.runtimeType.toString(),
      'error_code': error.code,
      'message': error.message,
      'timestamp': error.timestamp.toIso8601String(),
      'count': _errorCounts[errorKey],
      'metadata': error.metadata,
    };

    if (kDebugMode) {
      developer.log(
        'PluviometroError: ${error.code}',
        name: 'PluviometroErrorHandler',
        error: error,
        stackTrace: error.stackTrace,
      );
    }

    // Em produção, enviar para serviço de analytics
    _sendToAnalytics(logData);
  }

  /// Obtém contagem de erros para um código específico
  int _getErrorCount(String errorCode) {
    return _errorCounts.entries
        .where((entry) => entry.key.contains(errorCode))
        .fold(0, (sum, entry) => sum + entry.value);
  }

  /// Notifica todos os listeners
  void _notifyListeners(PluviometroException error) {
    for (final listener in _listeners) {
      try {
        listener.onError(error);
      } catch (e) {
        developer.log(
          'Erro no listener de erro: $e',
          name: 'PluviometroErrorHandler',
        );
      }
    }
  }

  /// Envia dados para analytics (mock)
  void _sendToAnalytics(Map<String, dynamic> logData) {
    // Em produção, implementar envio real para serviço de analytics
    if (kDebugMode) {
      developer.log(
        'Analytics: ${logData['error_code']}',
        name: 'Analytics',
      );
    }
  }

  /// Limpa dados antigos de erro
  void cleanup() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 24));

    _lastErrorTimes.removeWhere((key, time) => time.isBefore(cutoff));
    _errorCounts.removeWhere((key, count) => !_lastErrorTimes.containsKey(key));
  }

  /// Obtém estatísticas de erro
  ErrorStats getErrorStats() {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));
    final last24Hours = now.subtract(const Duration(hours: 24));

    final recentErrors =
        _lastErrorTimes.values.where((time) => time.isAfter(lastHour)).length;

    final dailyErrors = _lastErrorTimes.values
        .where((time) => time.isAfter(last24Hours))
        .length;

    return ErrorStats(
      totalErrors: _errorCounts.values.fold(0, (sum, count) => sum + count),
      recentErrors: recentErrors,
      dailyErrors: dailyErrors,
      topErrorCodes: _getTopErrorCodes(),
    );
  }

  List<String> _getTopErrorCodes() {
    final entries = _errorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).map((e) => e.key).toList();
  }
}

/// Resposta do tratamento de erro
class ErrorResponse {
  final PluviometroException exception;
  final String userMessage;
  final bool canRetry;
  final Duration? retryDelay;
  final bool shouldShowDialog;
  final Map<String, dynamic> metadata;

  const ErrorResponse({
    required this.exception,
    required this.userMessage,
    required this.canRetry,
    this.retryDelay,
    required this.shouldShowDialog,
    required this.metadata,
  });

  bool get isNetworkError => exception is NetworkException;
  bool get isValidationError => exception is ValidationException;
  bool get isAuthError => exception is AuthorizationException;
  bool get isRecoverable => canRetry || isValidationError;
}

/// Informações sobre retry
class RetryInfo {
  final bool canRetry;
  final Duration? delay;

  const RetryInfo({required this.canRetry, this.delay});
}

/// Interface para listeners de erro
abstract class ErrorListener {
  void onError(PluviometroException error);
}

/// Estatísticas de erro
class ErrorStats {
  final int totalErrors;
  final int recentErrors;
  final int dailyErrors;
  final List<String> topErrorCodes;

  const ErrorStats({
    required this.totalErrors,
    required this.recentErrors,
    required this.dailyErrors,
    required this.topErrorCodes,
  });

  @override
  String toString() {
    return 'ErrorStats(total: $totalErrors, recent: $recentErrors, daily: $dailyErrors)';
  }
}
