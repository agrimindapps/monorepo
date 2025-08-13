// Error recovery service for handling common error scenarios
// Provides automatic retry strategies and fallback mechanisms

// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Project imports:
import '../../../core/services/logging_service.dart';
import 'result.dart';

/// Recovery strategy enumeration
enum RecoveryStrategy {
  none,           // No automatic recovery
  retry,          // Simple retry with backoff
  fallback,       // Use fallback value
  cache,          // Use cached value if available
  hybrid,         // Combination of strategies
}

/// Retry configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool jitter;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.jitter = true,
  });

  Duration calculateDelay(int attemptNumber) {
    final baseDelay = initialDelay.inMilliseconds * 
                      math.pow(backoffMultiplier, attemptNumber - 1);
    
    final clampedDelay = math.min(baseDelay.toInt(), maxDelay.inMilliseconds);
    
    if (jitter) {
      final jitterMs = math.Random().nextInt((clampedDelay * 0.1).round());
      return Duration(milliseconds: clampedDelay + jitterMs);
    }
    
    return Duration(milliseconds: clampedDelay);
  }
}

/// Error recovery context
class RecoveryContext {
  final String operationName;
  final Map<String, dynamic> parameters;
  final DateTime startTime;
  final List<AppError> previousErrors;

  RecoveryContext({
    required this.operationName,
    this.parameters = const {},
    DateTime? startTime,
    this.previousErrors = const [],
  }) : startTime = startTime ?? DateTime.now();

  RecoveryContext copyWith({
    String? operationName,
    Map<String, dynamic>? parameters,
    DateTime? startTime,
    List<AppError>? previousErrors,
  }) {
    return RecoveryContext(
      operationName: operationName ?? this.operationName,
      parameters: parameters ?? this.parameters,
      startTime: startTime ?? this.startTime,
      previousErrors: previousErrors ?? this.previousErrors,
    );
  }

  Duration get elapsed => DateTime.now().difference(startTime);
}

/// Error recovery service
class ErrorRecoveryService {
  static final ErrorRecoveryService _instance = ErrorRecoveryService._();
  static ErrorRecoveryService get instance => _instance;

  ErrorRecoveryService._();

  final Map<Type, RecoveryStrategy> _strategies = {};
  final Map<String, dynamic> _fallbackCache = {};
  final Map<String, RetryConfig> _retryConfigs = {};

  /// Register recovery strategy for error type
  void registerStrategy<T extends AppError>(RecoveryStrategy strategy) {
    _strategies[T] = strategy;
  }

  /// Register retry configuration for operation
  void registerRetryConfig(String operationName, RetryConfig config) {
    _retryConfigs[operationName] = config;
  }

  /// Set fallback value for operation
  void setFallback<T>(String operationName, T fallbackValue) {
    _fallbackCache[operationName] = fallbackValue;
  }

  /// Execute operation with error recovery
  Future<Result<T>> executeWithRecovery<T>(
    String operationName,
    Future<Result<T>> Function() operation, {
    RecoveryStrategy? strategy,
    RetryConfig? retryConfig,
    T? fallbackValue,
  }) async {
    final context = RecoveryContext(operationName: operationName);
    final config = retryConfig ?? _retryConfigs[operationName] ?? const RetryConfig();
    
    LoggingService.debug(
      'Starting operation with recovery: $operationName',
      tag: 'ErrorRecovery',
    );

    for (int attempt = 1; attempt <= config.maxAttempts; attempt++) {
      try {
        final result = await operation();
        
        if (result.isSuccess) {
          if (attempt > 1) {
            LoggingService.info(
              'Operation succeeded after $attempt attempts: $operationName',
              tag: 'ErrorRecovery',
            );
          }
          return result;
        }

        // Handle failure
        final error = result.errorOrNull!;
        LoggingService.warning(
          'Operation attempt $attempt failed: $operationName - ${error.message}',
          tag: 'ErrorRecovery',
        );

        // Determine recovery strategy
        final recoveryStrategy = strategy ?? 
                                _getStrategyForError(error) ?? 
                                RecoveryStrategy.retry;

        // Apply recovery strategy
        final recoveredResult = await _applyRecoveryStrategy<T>(
          recoveryStrategy,
          error,
          context,
          fallbackValue,
        );

        if (recoveredResult != null) {
          return recoveredResult;
        }

        // If this is the last attempt, return the error
        if (attempt == config.maxAttempts) {
          LoggingService.error(
            'Operation failed after $attempt attempts: $operationName',
            tag: 'ErrorRecovery',
            error: error.originalError,
            stackTrace: error.stackTrace,
          );
          return result;
        }

        // Wait before retry
        if (attempt < config.maxAttempts) {
          final delay = config.calculateDelay(attempt);
          LoggingService.debug(
            'Retrying in ${delay.inMilliseconds}ms...',
            tag: 'ErrorRecovery',
          );
          await Future.delayed(delay);
        }

      } catch (e, stackTrace) {
        LoggingService.error(
          'Unexpected error during operation: $operationName',
          tag: 'ErrorRecovery',
          error: e,
          stackTrace: stackTrace,
        );
        
        final appError = AppError(
          message: 'Unexpected error: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        );
        
        return Result.failure(appError);
      }
    }

    // This should never be reached due to the return in the loop
    return Result.failure(AppError(message: 'Operation failed after all attempts'));
  }

  /// Execute operation with simple retry
  Future<Result<T>> executeWithRetry<T>(
    String operationName,
    Future<Result<T>> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    final config = RetryConfig(
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
    );

    return executeWithRecovery(
      operationName,
      operation,
      strategy: RecoveryStrategy.retry,
      retryConfig: config,
    );
  }

  /// Execute operation with fallback
  Future<Result<T>> executeWithFallback<T>(
    String operationName,
    Future<Result<T>> Function() operation,
    T fallbackValue,
  ) async {
    return executeWithRecovery(
      operationName,
      operation,
      strategy: RecoveryStrategy.fallback,
      fallbackValue: fallbackValue,
    );
  }

  /// Circuit breaker pattern implementation
  Future<Result<T>> executeWithCircuitBreaker<T>(
    String operationName,
    Future<Result<T>> Function() operation, {
    int failureThreshold = 5,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    // Simple circuit breaker implementation
    final circuitKey = 'circuit_$operationName';
    final now = DateTime.now();
    
    // Check if circuit is open
    final lastFailure = _circuitState[circuitKey];
    if (lastFailure != null) {
      final failures = _failureCounts[circuitKey] ?? 0;
      if (failures >= failureThreshold) {
        if (now.difference(lastFailure).compareTo(timeout) < 0) {
          LoggingService.warning(
            'Circuit breaker is OPEN for $operationName',
            tag: 'ErrorRecovery',
          );
          return Result.failure(AppError(
            message: 'Circuit breaker is open for $operationName',
            code: 'CIRCUIT_OPEN',
          ));
        } else {
          // Reset circuit breaker
          _resetCircuit(circuitKey);
          LoggingService.info(
            'Circuit breaker reset for $operationName',
            tag: 'ErrorRecovery',
          );
        }
      }
    }

    final result = await operation();
    
    if (result.isSuccess) {
      _resetCircuit(circuitKey);
    } else {
      _recordFailure(circuitKey);
    }

    return result;
  }

  // Circuit breaker state
  final Map<String, DateTime> _circuitState = {};
  final Map<String, int> _failureCounts = {};

  void _recordFailure(String circuitKey) {
    _circuitState[circuitKey] = DateTime.now();
    _failureCounts[circuitKey] = (_failureCounts[circuitKey] ?? 0) + 1;
  }

  void _resetCircuit(String circuitKey) {
    _circuitState.remove(circuitKey);
    _failureCounts.remove(circuitKey);
  }

  /// Get recovery strategy for specific error type
  RecoveryStrategy? _getStrategyForError(AppError error) {
    return _strategies[error.runtimeType];
  }

  /// Apply recovery strategy
  Future<Result<T>?> _applyRecoveryStrategy<T>(
    RecoveryStrategy strategy,
    AppError error,
    RecoveryContext context,
    T? fallbackValue,
  ) async {
    switch (strategy) {
      case RecoveryStrategy.none:
        return null;
        
      case RecoveryStrategy.retry:
        return null; // Will retry in main loop
        
      case RecoveryStrategy.fallback:
        if (fallbackValue != null) {
          LoggingService.info(
            'Using fallback value for ${context.operationName}',
            tag: 'ErrorRecovery',
          );
          return Result.success(fallbackValue);
        }
        
        final cachedFallback = _fallbackCache[context.operationName] as T?;
        if (cachedFallback != null) {
          LoggingService.info(
            'Using cached fallback value for ${context.operationName}',
            tag: 'ErrorRecovery',
          );
          return Result.success(cachedFallback);
        }
        return null;
        
      case RecoveryStrategy.cache:
        // Implementation would depend on cache service
        LoggingService.debug(
          'Cache recovery not implemented for ${context.operationName}',
          tag: 'ErrorRecovery',
        );
        return null;
        
      case RecoveryStrategy.hybrid:
        // Try fallback first, then cache
        final fallbackResult = await _applyRecoveryStrategy<T>(
          RecoveryStrategy.fallback,
          error,
          context,
          fallbackValue,
        );
        if (fallbackResult != null) return fallbackResult;
        
        return await _applyRecoveryStrategy<T>(
          RecoveryStrategy.cache,
          error,
          context,
          fallbackValue,
        );
    }
  }

  /// Initialize default configurations
  void initializeDefaults() {
    // Register default strategies for common errors
    registerStrategy<DatabaseError>(RecoveryStrategy.retry);
    registerStrategy<NetworkError>(RecoveryStrategy.hybrid);
    registerStrategy<CacheError>(RecoveryStrategy.fallback);
    registerStrategy<ValidationError>(RecoveryStrategy.none);
    
    // Register default retry configs
    registerRetryConfig('database_operation', const RetryConfig(
      maxAttempts: 3,
      initialDelay: Duration(milliseconds: 100),
      backoffMultiplier: 1.5,
    ));
    
    registerRetryConfig('network_operation', const RetryConfig(
      maxAttempts: 5,
      initialDelay: Duration(milliseconds: 1000),
      backoffMultiplier: 2.0,
      maxDelay: Duration(seconds: 10),
    ));
    
    LoggingService.info('Error recovery service initialized with defaults', tag: 'ErrorRecovery');
  }

  /// Get service statistics
  Map<String, dynamic> getStats() {
    return {
      'registeredStrategies': _strategies.length,
      'retryConfigs': _retryConfigs.length,
      'fallbackValues': _fallbackCache.length,
      'circuitStates': _circuitState.length,
      'activeCircuits': _circuitState.keys.toList(),
      'failureCounts': Map<String, int>.from(_failureCounts),
    };
  }

  /// Reset all circuit breakers
  void resetAllCircuits() {
    _circuitState.clear();
    _failureCounts.clear();
    LoggingService.info('All circuit breakers reset', tag: 'ErrorRecovery');
  }
}