// Result pattern implementation for proper error handling
// Replaces try-catch with print() pattern throughout repositories

/// Base class for application errors
class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(message, code, runtimeType);

  @override
  String toString() => 'AppError(code: $code, message: $message)';
}

/// Repository-specific errors
class RepositoryError extends AppError {
  final String repositoryName;
  final String operation;

  RepositoryError({
    required this.repositoryName,
    required this.operation,
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'RepositoryError($repositoryName.$operation): $message';
}

/// Database-specific errors
class DatabaseError extends RepositoryError {
  DatabaseError({
    required super.repositoryName,
    required super.operation,
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Cache-specific errors
class CacheError extends AppError {
  final String cacheKey;

  CacheError({
    required this.cacheKey,
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'CacheError(key: $cacheKey): $message';
}

/// Network-specific errors
class NetworkError extends AppError {
  final String? url;
  final int? statusCode;

  NetworkError({
    this.url,
    this.statusCode,
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkError(${statusCode ?? 'N/A'}): $message';
}

/// Validation-specific errors
class ValidationError extends AppError {
  final String field;
  final dynamic value;

  ValidationError({
    required this.field,
    this.value,
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ValidationError($field): $message';
}

/// Result type for safe error handling
sealed class Result<T> {
  const Result();

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get success value or null
  T? get valueOrNull => switch (this) {
    Success<T> success => success.value,
    Failure<T> _ => null,
  };

  /// Get error or null
  AppError? get errorOrNull => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.error,
  };

  /// Transform success value
  Result<U> map<U>(U Function(T) mapper) {
    return switch (this) {
      Success<T> success => Result.success(mapper(success.value)),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Transform success value with async function
  Future<Result<U>> mapAsync<U>(Future<U> Function(T) mapper) async {
    return switch (this) {
      Success<T> success => Result.success(await mapper(success.value)),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Chain operations
  Result<U> flatMap<U>(Result<U> Function(T) mapper) {
    return switch (this) {
      Success<T> success => mapper(success.value),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Chain async operations
  Future<Result<U>> flatMapAsync<U>(Future<Result<U>> Function(T) mapper) async {
    return switch (this) {
      Success<T> success => await mapper(success.value),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Fold result into single value
  U fold<U>(U Function(T) onSuccess, U Function(AppError) onFailure) {
    return switch (this) {
      Success<T> success => onSuccess(success.value),
      Failure<T> failure => onFailure(failure.error),
    };
  }

  /// Get value or default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T> success => success.value,
      Failure<T> _ => defaultValue,
    };
  }

  /// Get value or compute default
  T getOrElseCompute(T Function() defaultComputer) {
    return switch (this) {
      Success<T> success => success.value,
      Failure<T> _ => defaultComputer(),
    };
  }

  /// Recover from error
  Result<T> recover(T Function(AppError) recovery) {
    return switch (this) {
      Success<T> success => success,
      Failure<T> failure => Result.success(recovery(failure.error)),
    };
  }

  /// Async recovery
  Future<Result<T>> recoverAsync(Future<T> Function(AppError) recovery) async {
    return switch (this) {
      Success<T> success => success,
      Failure<T> failure => Result.success(await recovery(failure.error)),
    };
  }

  /// Convert to nullable
  T? toNullable() => valueOrNull;

  // Factory constructors
  static Result<T> success<T>(T value) => Success._(value);
  static Result<T> failure<T>(AppError error) => Failure._(error);

  /// Wrap potentially throwing operation
  static Result<T> trySync<T>(T Function() operation, [AppError Function(dynamic)? errorMapper]) {
    try {
      return Result.success(operation());
    } catch (error, stackTrace) {
      final appError = errorMapper?.call(error) ?? 
        AppError(
          message: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
        );
      return Result.failure(appError);
    }
  }

  /// Wrap potentially throwing async operation
  static Future<Result<T>> tryAsync<T>(
    Future<T> Function() operation, 
    [AppError Function(dynamic)? errorMapper]
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (error, stackTrace) {
      final appError = errorMapper?.call(error) ??
        AppError(
          message: error.toString(),
          originalError: error,
          stackTrace: stackTrace,
        );
      return Result.failure(appError);
    }
  }
}

/// Success result
final class Success<T> extends Result<T> {
  final T value;
  
  const Success._(this.value);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> && other.value == value);
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failure result
final class Failure<T> extends Result<T> {
  final AppError error;
  
  const Failure._(this.error);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Failure<T> && other.error == error);
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

/// Extensions for working with nullable values
extension ResultNullable<T> on T? {
  Result<T> toResult([AppError Function()? errorProvider]) {
    if (this != null) {
      return Result.success(this as T);
    } else {
      final error = errorProvider?.call() ?? AppError(message: 'Value is null');
      return Result.failure(error);
    }
  }
}

/// Extensions for lists of results
extension ResultList<T> on List<Result<T>> {
  /// Collect all successful values
  List<T> collectSuccess() {
    return whereType<Success<T>>().map((s) => s.value).toList();
  }

  /// Collect all errors
  List<AppError> collectErrors() {
    return whereType<Failure<T>>().map((f) => f.error).toList();
  }

  /// Check if all are successful
  bool get allSuccess => every((r) => r.isSuccess);

  /// Check if any are successful
  bool get anySuccess => any((r) => r.isSuccess);

  /// Convert to single result with list of values
  Result<List<T>> sequence() {
    final successes = <T>[];
    for (final result in this) {
      switch (result) {
        case Success<T> success:
          successes.add(success.value);
        case Failure<T> failure:
          return Result.failure(failure.error);
      }
    }
    return Result.success(successes);
  }
}