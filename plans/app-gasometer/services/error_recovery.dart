// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../errors/gasometer_exceptions.dart';
import '../types/result.dart';
import 'error_handler.dart';

/// Service responsável por implementar estratégias de recovery de erros
/// 
/// Oferece mecanismos automáticos de recuperação para diferentes tipos
/// de erro, incluindo retry com backoff, fallback e graceful degradation
class ErrorRecoveryService {
  static final ErrorRecoveryService _instance = ErrorRecoveryService._();
  static ErrorRecoveryService get instance => _instance;
  
  ErrorRecoveryService._();

  // MARK: - Retry Mechanisms

  /// Executa operação com retry automático e backoff exponencial
  Future<GasometerResult<T>> retryWithBackoff<T>({
    required Future<GasometerResult<T>> Function() operation,
    String? operationName,
    int maxRetries = 3,
    Duration baseDelay = const Duration(milliseconds: 500),
    double backoffMultiplier = 2.0,
    bool Function(GasometerException)? shouldRetry,
  }) async {
    var lastResult = await operation();
    
    if (lastResult.isSuccess) {
      return lastResult;
    }

    final error = lastResult.error;
    
    // Verifica se deve tentar retry
    if (shouldRetry != null && !shouldRetry(error)) {
      return lastResult;
    }

    // Retry automático baseado no tipo de erro
    if (!_shouldRetryAutomatically(error)) {
      return lastResult;
    }

    debugPrint('Starting retry mechanism for ${operationName ?? 'operation'}, max retries: $maxRetries');
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final delay = Duration(
        milliseconds: (baseDelay.inMilliseconds * 
          (backoffMultiplier * attempt)).round(),
      );
      
      debugPrint('Retry attempt $attempt/$maxRetries after ${delay.inMilliseconds}ms delay');
      await Future.delayed(delay);
      
      lastResult = await operation();
      
      if (lastResult.isSuccess) {
        debugPrint('Retry successful on attempt $attempt');
        return lastResult;
      }
      
      debugPrint('Retry attempt $attempt failed: ${lastResult.error}');
    }
    
    debugPrint('All retry attempts failed for ${operationName ?? 'operation'}');
    
    // Log do erro final após todos os retries
    GasometerErrorHandler.instance.logGasometerException(
      lastResult.error,
      severity: ErrorSeverity.error,
    );
    
    return lastResult;
  }

  /// Implementa circuit breaker pattern
  Future<GasometerResult<T>> withCircuitBreaker<T>({
    required Future<GasometerResult<T>> Function() operation,
    required String operationKey,
    int failureThreshold = 5,
    Duration timeout = const Duration(minutes: 1),
    GasometerResult<T>? fallbackResult,
  }) async {
    final state = _circuitBreakerStates[operationKey];
    
    // Se circuit breaker está aberto, retorna fallback ou erro
    if (state != null && state.isOpen && DateTime.now().isBefore(state.nextAttempt)) {
      debugPrint('Circuit breaker is OPEN for $operationKey');
      
      if (fallbackResult != null) {
        return fallbackResult;
      }
      
      return GasometerResult.failure(
        GenericGasometerException(
          'Circuit breaker aberto para $operationKey',
          operation: 'circuit_breaker',
          context: {'operationKey': operationKey},
        ),
      );
    }

    try {
      final result = await operation().timeout(timeout);
      
      if (result.isSuccess) {
        // Reseta circuit breaker em caso de sucesso
        _circuitBreakerStates.remove(operationKey);
        return result;
      } else {
        // Incrementa contador de falhas
        _updateCircuitBreakerState(operationKey, failureThreshold);
        return result;
      }
    } catch (e) {
      _updateCircuitBreakerState(operationKey, failureThreshold);
      
      return GasometerResult.failure(
        wrapException(
          e is Exception ? e : Exception(e.toString()),
          operation: operationKey,
        ),
      );
    }
  }

  // MARK: - Fallback Mechanisms

  /// Executa operação com fallback automático
  Future<GasometerResult<T>> withFallback<T>({
    required Future<GasometerResult<T>> Function() primaryOperation,
    required Future<GasometerResult<T>> Function() fallbackOperation,
    String? operationName,
    bool Function(GasometerException)? shouldUseFallback,
  }) async {
    debugPrint('Executing primary operation: ${operationName ?? 'unknown'}');
    
    final primaryResult = await primaryOperation();
    
    if (primaryResult.isSuccess) {
      return primaryResult;
    }

    final error = primaryResult.error;
    
    // Verifica se deve usar fallback
    if (shouldUseFallback != null && !shouldUseFallback(error)) {
      return primaryResult;
    }

    // Uso automático de fallback baseado no tipo de erro
    if (!_shouldUseFallbackAutomatically(error)) {
      return primaryResult;
    }

    debugPrint('Primary operation failed, trying fallback: $error');
    
    try {
      final fallbackResult = await fallbackOperation();
      
      if (fallbackResult.isSuccess) {
        debugPrint('Fallback operation succeeded');
        
        // Log warning sobre uso de fallback
        GasometerErrorHandler.instance.logError(
          error,
          operation: '${operationName ?? 'operation'}_fallback_used',
          severity: ErrorSeverity.warning,
        );
      }
      
      return fallbackResult;
    } catch (e) {
      debugPrint('Fallback operation also failed: $e');
      
      // Retorna erro original se fallback também falhar
      return primaryResult;
    }
  }

  /// Implementa graceful degradation
  GasometerResult<T> withGracefulDegradation<T>({
    required GasometerResult<T> result,
    required T Function(GasometerException error) degradedValueProvider,
    String? operationName,
  }) {
    if (result.isSuccess) {
      return result;
    }

    final error = result.error;
    
    // Apenas aplica graceful degradation para certos tipos de erro
    if (!_shouldUseDegradation(error)) {
      return result;
    }

    debugPrint('Applying graceful degradation for ${operationName ?? 'operation'}: $error');
    
    try {
      final degradedValue = degradedValueProvider(error);
      
      // Log warning sobre uso de valor degradado
      GasometerErrorHandler.instance.logError(
        error,
        operation: '${operationName ?? 'operation'}_degraded',
        severity: ErrorSeverity.warning,
      );
      
      return GasometerResult.success(degradedValue);
    } catch (e) {
      debugPrint('Failed to provide degraded value: $e');
      return result;
    }
  }

  // MARK: - Private Methods

  final Map<String, _CircuitBreakerState> _circuitBreakerStates = {};

  bool _shouldRetryAutomatically(GasometerException error) {
    // Retry para erros de rede temporários
    if (error is NetworkTimeoutException || error is SyncException) {
      return true;
    }
    
    // Retry para alguns erros de storage
    if (error is HiveStorageException) {
      return false; // Erros de Hive são geralmente permanentes
    }
    
    // Não retry para erros de validação
    if (error is VeiculoValidationException || 
        error is AbastecimentoValidationException) {
      return false;
    }
    
    return false;
  }

  bool _shouldUseFallbackAutomatically(GasometerException error) {
    // Fallback para erros de rede
    if (error is NetworkException) {
      return true;
    }
    
    // Fallback para erros de storage
    if (error is StorageException && error is! HiveStorageException) {
      return true;
    }
    
    return false;
  }

  bool _shouldUseDegradation(GasometerException error) {
    // Degradation para erros não críticos
    if (error is NetworkException || 
        error is FirestoreStorageException ||
        error is SyncException) {
      return true;
    }
    
    return false;
  }

  void _updateCircuitBreakerState(String operationKey, int failureThreshold) {
    final state = _circuitBreakerStates[operationKey] ?? 
      _CircuitBreakerState();
    
    state.failureCount++;
    
    if (state.failureCount >= failureThreshold) {
      state.isOpen = true;
      state.nextAttempt = DateTime.now().add(const Duration(minutes: 1));
      debugPrint('Circuit breaker OPENED for $operationKey after ${state.failureCount} failures');
    }
    
    _circuitBreakerStates[operationKey] = state;
  }
}

/// Estado interno do circuit breaker
class _CircuitBreakerState {
  int failureCount = 0;
  bool isOpen = false;
  DateTime nextAttempt = DateTime.now();
}

// MARK: - Extension Methods

/// Extensions para facilitar uso do ErrorRecoveryService
extension GasometerResultRecovery<T> on GasometerResult<T> {
  /// Aplica graceful degradation automaticamente
  GasometerResult<T> withDegradation({
    required T Function(GasometerException error) degradedValueProvider,
    String? operationName,
  }) {
    return ErrorRecoveryService.instance.withGracefulDegradation(
      result: this,
      degradedValueProvider: degradedValueProvider,
      operationName: operationName,
    );
  }
}

/// Extensions para Future<GasometerResult<T>>
extension FutureGasometerResultRecovery<T> on Future<GasometerResult<T>> {
  /// Aplica retry com backoff
  Future<GasometerResult<T>> withRetry({
    String? operationName,
    int maxRetries = 3,
    Duration baseDelay = const Duration(milliseconds: 500),
    double backoffMultiplier = 2.0,
    bool Function(GasometerException)? shouldRetry,
  }) {
    return ErrorRecoveryService.instance.retryWithBackoff(
      operation: () => this,
      operationName: operationName,
      maxRetries: maxRetries,
      baseDelay: baseDelay,
      backoffMultiplier: backoffMultiplier,
      shouldRetry: shouldRetry,
    );
  }

  /// Aplica circuit breaker
  Future<GasometerResult<T>> withCircuitBreaker({
    required String operationKey,
    int failureThreshold = 5,
    Duration timeout = const Duration(minutes: 1),
    GasometerResult<T>? fallbackResult,
  }) {
    return ErrorRecoveryService.instance.withCircuitBreaker(
      operation: () => this,
      operationKey: operationKey,
      failureThreshold: failureThreshold,
      timeout: timeout,
      fallbackResult: fallbackResult,
    );
  }

  /// Aplica fallback
  Future<GasometerResult<T>> withFallback({
    required Future<GasometerResult<T>> Function() fallbackOperation,
    String? operationName,
    bool Function(GasometerException)? shouldUseFallback,
  }) {
    return ErrorRecoveryService.instance.withFallback(
      primaryOperation: () => this,
      fallbackOperation: fallbackOperation,
      operationName: operationName,
      shouldUseFallback: shouldUseFallback,
    );
  }
}