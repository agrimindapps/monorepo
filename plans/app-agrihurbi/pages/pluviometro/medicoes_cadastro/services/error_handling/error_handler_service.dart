// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'medicoes_exceptions.dart';

/// Resultado de uma operação com tratamento de erro
class OperationResult<T> {
  final T? data;
  final MedicoesException? error;
  final bool isSuccess;

  const OperationResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory OperationResult.success(T data) {
    return OperationResult._(data: data, isSuccess: true);
  }

  factory OperationResult.failure(MedicoesException error) {
    return OperationResult._(error: error, isSuccess: false);
  }
}

/// Service para tratamento centralizado de erros
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  /// Executa uma operação com tratamento robusto de erros
  Future<OperationResult<T>> executeOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    Map<String, dynamic>? context,
  }) async {
    try {
      final result = await operation();
      return OperationResult.success(result);
    } on MedicoesException catch (e) {
      _logError(e, operationName: operationName, context: context);
      return OperationResult.failure(e);
    } catch (e, stackTrace) {
      final wrappedException = _wrapGenericError(e, stackTrace, operationName);
      _logError(wrappedException,
          operationName: operationName, context: context);
      return OperationResult.failure(wrappedException);
    }
  }

  /// Converte erro genérico em exceção específica
  MedicoesException _wrapGenericError(
    dynamic error,
    StackTrace stackTrace,
    String? operationName,
  ) {
    final errorMessage = error.toString();

    // Detecta tipos específicos de erro
    if (errorMessage.contains('timeout') ||
        errorMessage.contains('TimeoutException')) {
      return TimeoutException(
        message: 'Operação expirou: $errorMessage',
        timeout: const Duration(seconds: 30),
        details: operationName,
        stackTrace: stackTrace.toString(),
      );
    }

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return NetworkException(
        message: 'Erro de conexão: $errorMessage',
        details: operationName,
        stackTrace: stackTrace.toString(),
      );
    }

    if (errorMessage.contains('validation') ||
        errorMessage.contains('invalid')) {
      return ValidationException(
        message: 'Erro de validação: $errorMessage',
        details: operationName,
        stackTrace: stackTrace.toString(),
      );
    }

    if (errorMessage.contains('database') || errorMessage.contains('storage')) {
      return PersistenceException(
        message: 'Erro de persistência: $errorMessage',
        operation: operationName ?? 'unknown',
        details: operationName,
        stackTrace: stackTrace.toString(),
      );
    }

    // Erro genérico
    return BusinessLogicException(
      message: 'Erro inesperado: $errorMessage',
      rule: 'generic_error',
      details: operationName,
      stackTrace: stackTrace.toString(),
    );
  }

  /// Registra erro no log
  void _logError(
    MedicoesException error, {
    String? operationName,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      debugPrint('🚨 ERRO [${error.runtimeType}]');
      debugPrint('   Operação: ${operationName ?? 'N/A'}');
      debugPrint('   Mensagem: ${error.message}');
      debugPrint('   Detalhes: ${error.details ?? 'N/A'}');
      debugPrint('   Timestamp: ${error.timestamp}');
      if (context != null) {
        debugPrint('   Contexto: $context');
      }
      if (error.stackTrace != null) {
        debugPrint('   Stack: ${error.stackTrace}');
      }
      debugPrint('');
    }
  }

  /// Obtém mensagem user-friendly para o erro
  String getUserFriendlyMessage(MedicoesException error) {
    if (error is ValidationException) {
      return 'Dados inválidos. Verifique os campos e tente novamente.';
    } else if (error is PersistenceException) {
      return 'Erro ao salvar dados. Tente novamente em alguns instantes.';
    } else if (error is NetworkException) {
      return 'Problema de conexão. Verifique sua internet e tente novamente.';
    } else if (error is TimeoutException) {
      return 'Operação demorou muito. Tente novamente.';
    } else if (error is BusinessLogicException) {
      return error.message; // Mensagens de negócio são user-friendly
    } else if (error is ConfigurationException) {
      return 'Problema de configuração. Contacte o suporte.';
    } else {
      return 'Erro inesperado. Tente novamente ou contacte o suporte.';
    }
  }

  /// Determina se o erro permite retry
  bool shouldRetry(MedicoesException error) {
    if (error is NetworkException || error is TimeoutException) {
      return true;
    } else if (error is PersistenceException) {
      return true; // Alguns erros de persistência podem ser temporários
    } else if (error is ValidationException ||
        error is BusinessLogicException ||
        error is ConfigurationException) {
      return false;
    } else {
      return false;
    }
  }

  /// Executa operação com retry automático
  Future<OperationResult<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    Map<String, dynamic>? context,
  }) async {
    OperationResult<T> result;
    int attempts = 0;

    do {
      attempts++;
      result = await executeOperation(
        operation,
        operationName: operationName,
        context: {...?context, 'attempt': attempts},
      );

      if (result.isSuccess) {
        return result;
      }

      final shouldRetryError =
          result.error != null && shouldRetry(result.error!);
      final hasRetriesLeft = attempts < maxRetries;

      if (shouldRetryError && hasRetriesLeft) {
        await Future.delayed(retryDelay * attempts); // Backoff exponencial
        continue;
      }

      break;
    } while (true);

    return result;
  }
}
