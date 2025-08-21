import 'dart:async';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'app_error.dart';
import 'error_logger.dart';

/// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  /// Create a successful result
  const Result.success(T data) : this._(data: data, isSuccess: true);

  /// Create a failed result
  const Result.failure(AppError error) : this._(error: error, isSuccess: false);

  /// Execute callback if successful
  Result<U> map<U>(U Function(T data) callback) {
    if (isSuccess && data != null) {
      try {
        return Result.success(callback(data!));
      } catch (e, stackTrace) {
        final error = UnexpectedError(
          message: 'Error in map operation: $e',
          technicalDetails: stackTrace.toString(),
        );
        return Result.failure(error);
      }
    }
    return Result.failure(error!);
  }

  /// Execute callback if failed
  Result<T> mapError(AppError Function(AppError error) callback) {
    if (!isSuccess && error != null) {
      return Result.failure(callback(error!));
    }
    return this;
  }

  /// Execute callback and return new result
  Result<U> flatMap<U>(Result<U> Function(T data) callback) {
    if (isSuccess && data != null) {
      return callback(data!);
    }
    return Result.failure(error!);
  }

  /// Get data or throw error
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error!;
  }

  /// Get data or return default
  T getOrElse(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }

  /// Execute success or error callback
  U fold<U>(
    U Function(AppError error) onError,
    U Function(T data) onSuccess,
  ) {
    return isSuccess && data != null 
        ? onSuccess(data!) 
        : onError(error!);
  }

  @override
  String toString() {
    return isSuccess 
        ? 'Result.success($data)' 
        : 'Result.failure($error)';
  }
}

/// Configuration for retry policies
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool Function(AppError error)? retryCondition;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.retryCondition,
  });

  /// Policy for network operations
  static const network = RetryPolicy(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 1000),
    maxDelay: Duration(seconds: 10),
    backoffMultiplier: 2.0,
  );

  /// Policy for critical operations
  static const critical = RetryPolicy(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 15),
    backoffMultiplier: 1.5,
  );

  /// Policy for user-initiated operations
  static const userAction = RetryPolicy(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 300),
    maxDelay: Duration(seconds: 5),
    backoffMultiplier: 2.0,
  );

  /// Policy that doesn't retry
  static const noRetry = RetryPolicy(maxAttempts: 1);

  /// Check if error should be retried
  bool shouldRetry(AppError error) {
    if (retryCondition != null) {
      return retryCondition!(error);
    }

    // Default retry conditions
    return error is NetworkError || 
           error is TimeoutError || 
           error is ServerError && 
           error.statusCode != null && 
           error.statusCode! >= 500;
  }

  /// Calculate delay for attempt
  Duration getDelay(int attemptNumber) {
    if (attemptNumber <= 1) return initialDelay;

    final delay = initialDelay.inMilliseconds * 
                 pow(backoffMultiplier, attemptNumber - 1);
    
    return Duration(
      milliseconds: min(delay.round(), maxDelay.inMilliseconds),
    );
  }
}

/// Main error handler service
@injectable
class ErrorHandler {
  final ErrorLogger _logger;

  const ErrorHandler(this._logger);

  /// Execute operation with error handling and retry
  Future<Result<T>> execute<T>(
    Future<T> Function() operation, {
    RetryPolicy policy = RetryPolicy.network,
    String? operationName,
    Map<String, dynamic>? context,
  }) async {
    AppError? lastError;
    
    for (int attempt = 1; attempt <= policy.maxAttempts; attempt++) {
      try {
        // Log retry attempts (except first)
        if (attempt > 1) {
          _logger.logRetryAttempt(
            operationName ?? 'unknown_operation',
            attempt,
            policy.maxAttempts,
            lastError,
          );
        }

        final result = await operation();
        return Result.success(result);
        
      } catch (e, stackTrace) {
        lastError = _convertToAppError(e, stackTrace);

        _logger.logError(
          lastError!,
          stackTrace: stackTrace,
          additionalContext: {
            'operation': operationName,
            'attempt': attempt,
            'maxAttempts': policy.maxAttempts,
            ...?context,
          },
        );

        // Don't retry if it's the last attempt or if error shouldn't be retried
        if (attempt >= policy.maxAttempts || !policy.shouldRetry(lastError!)) {
          break;
        }

        // Wait before retrying
        await Future.delayed(policy.getDelay(attempt));
      }
    }

    return Result.failure(lastError!);
  }

  /// Execute operation with timeout
  Future<Result<T>> executeWithTimeout<T>(
    Future<T> Function() operation,
    Duration timeout, {
    RetryPolicy policy = RetryPolicy.network,
    String? operationName,
    Map<String, dynamic>? context,
  }) async {
    return execute(
      () => Future.any([
        operation(),
        Future.delayed(timeout).then((_) => 
          throw TimeoutException('Operation timed out after ${timeout.inSeconds}s')),
      ]),
      policy: policy,
      operationName: operationName,
      context: context,
    );
  }

  /// Handle errors in streams
  Stream<Result<T>> handleStream<T>(
    Stream<T> source, {
    String? operationName,
    Map<String, dynamic>? context,
  }) {
    return source
        .map<Result<T>>((data) => Result.success(data))
        .handleError((error, stackTrace) {
          final appError = _convertToAppError(error, stackTrace);
          
          _logger.logError(
            appError,
            stackTrace: stackTrace,
            additionalContext: {
              'operation': operationName,
              'type': 'stream_error',
              ...?context,
            },
          );

          return Result<T>.failure(appError);
        });
  }

  /// Convert exception to AppError
  AppError _convertToAppError(dynamic error, StackTrace? stackTrace) {
    if (error is AppError) {
      return error;
    }

    if (error is TimeoutException) {
      return TimeoutError(
        message: error.message ?? 'Operation timed out',
        technicalDetails: stackTrace?.toString(),
      );
    }

    // Handle common Flutter/Dart exceptions
    if (error is ArgumentError) {
      return ValidationError(
        message: 'Invalid argument: ${error.message}',
        technicalDetails: stackTrace?.toString(),
      );
    }

    if (error is StateError) {
      return UnexpectedError(
        message: 'Invalid state: ${error.message}',
        technicalDetails: stackTrace?.toString(),
      );
    }

    if (error is FormatException) {
      return ValidationError(
        message: 'Format error: ${error.message}',
        technicalDetails: stackTrace?.toString(),
      );
    }

    // Generic error fallback
    return UnexpectedError(
      message: error.toString(),
      technicalDetails: stackTrace?.toString(),
    );
  }

  /// Handle errors in provider methods
  Future<Result<T>> handleProviderOperation<T>(
    Future<T> Function() operation, {
    required String providerName,
    required String methodName,
    Map<String, dynamic>? parameters,
    RetryPolicy policy = RetryPolicy.userAction,
  }) async {
    return execute(
      operation,
      policy: policy,
      operationName: '${providerName}.${methodName}',
      context: {
        'provider': providerName,
        'method': methodName,
        'parameters': parameters,
      },
    );
  }

  /// Handle errors in repository methods
  Future<Result<T>> handleRepositoryOperation<T>(
    Future<T> Function() operation, {
    required String repositoryName,
    required String methodName,
    Map<String, dynamic>? parameters,
    RetryPolicy policy = RetryPolicy.network,
  }) async {
    return execute(
      operation,
      policy: policy,
      operationName: '${repositoryName}.${methodName}',
      context: {
        'repository': repositoryName,
        'method': methodName,
        'parameters': parameters,
      },
    );
  }

  /// Handle UI operation errors
  Future<Result<T>> handleUIOperation<T>(
    Future<T> Function() operation, {
    required String screenName,
    required String actionName,
    Map<String, dynamic>? context,
    RetryPolicy policy = RetryPolicy.noRetry,
  }) async {
    return execute(
      operation,
      policy: policy,
      operationName: '${screenName}.${actionName}',
      context: {
        'screen': screenName,
        'action': actionName,
        'uiContext': context,
      },
    );
  }
}

/// Extension methods for easier error handling
extension FutureErrorHandling<T> on Future<T> {
  /// Convert to Result
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (error, stackTrace) {
      final errorHandler = ErrorHandler(ErrorLogger());
      final appError = errorHandler._convertToAppError(error, stackTrace);
      return Result.failure(appError);
    }
  }

  /// Handle with retry
  Future<Result<T>> withRetry({
    RetryPolicy policy = RetryPolicy.network,
    String? operationName,
    Map<String, dynamic>? context,
  }) async {
    final errorHandler = ErrorHandler(ErrorLogger());
    return errorHandler.execute(
      () => this,
      policy: policy,
      operationName: operationName,
      context: context,
    );
  }

  /// Handle with timeout and retry
  Future<Result<T>> withTimeoutAndRetry(
    Duration timeout, {
    RetryPolicy policy = RetryPolicy.network,
    String? operationName,
    Map<String, dynamic>? context,
  }) async {
    final errorHandler = ErrorHandler(ErrorLogger());
    return errorHandler.executeWithTimeout(
      () => this,
      timeout,
      policy: policy,
      operationName: operationName,
      context: context,
    );
  }
}