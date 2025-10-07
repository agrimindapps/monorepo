import 'package:dartz/dartz.dart';
import 'app_error.dart';
import 'failure.dart';

/// A sealed class representing the result of an operation that can either
/// succeed with a value of type [T] or fail with an [AppError].
///
/// This is a type-safe alternative to throwing exceptions and is intended to
/// replace the legacy `Either<Failure, Success>` pattern.
sealed class Result<T> {
  const Result();

  /// Creates a [Result] representing a successful operation.
  factory Result.success(T data) = Success<T>;

  /// Creates a [Result] representing a failed operation.
  factory Result.error(AppError error) = Error<T>;

  /// An alias for [Result.error], provided for backward compatibility.
  factory Result.failure(AppError error) = Error<T>;

  /// Returns `true` if the result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if the result is an [Error].
  bool get isError => this is Error<T>;

  /// An alias for [isError], provided for backward compatibility.
  bool get isFailure => this is Error<T>;

  /// Returns the success data, or `null` if the result is an error.
  T? get data => switch (this) {
        Success<T>(data: final d) => d,
        Error<T>() => null,
      };

  /// Returns the error, or `null` if the result is a success.
  AppError? get error => switch (this) {
        Success<T>() => null,
        Error<T>(error: final e) => e,
      };

  /// Transforms the [Result] by applying [onError] if it's an error,
  /// or [onSuccess] if it's a success.
  R fold<R>(R Function(AppError error) onError, R Function(T data) onSuccess) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Error<T>(error: final e) => onError(e),
    };
  }

  /// Maps a [Success] value to a new `Result` of type [R].
  /// If this is an [Error], it is returned unchanged.
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final d) => Result.success(mapper(d)),
      Error<T>(error: final e) => Result.error(e),
    };
  }

  /// Maps an [Error]'s value to another [AppError].
  /// If this is a [Success], it is returned unchanged.
  Result<T> mapError(AppError Function(AppError error) mapper) {
    return switch (this) {
      Success<T>() => this,
      Error<T>(error: final e) => Result.error(mapper(e)),
    };
  }

  /// Chains an asynchronous operation that returns a [Result].
  /// The [operation] is only executed if this result is a [Success].
  Future<Result<R>> then<R>(Future<Result<R>> Function(T data) operation) async {
    return switch (this) {
      Success<T>(data: final d) => await operation(d),
      Error<T>(error: final e) => Result.error(e),
    };
  }

  /// Performs an action if the result is a [Success].
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Performs an action if the result is an [Error].
  Result<T> onError(void Function(AppError error) action) {
    if (this is Error<T>) {
      action((this as Error<T>).error);
    }
    return this;
  }

  /// Recovers from an error by transforming it into a [Success].
  Result<T> recover(T Function(AppError error) recovery) {
    return switch (this) {
      Success<T>() => this,
      Error<T>(error: final e) => Result.success(recovery(e)),
    };
  }

  /// Returns the success data, or a [fallback] value if this is an [Error].
  T getOrElse(T fallback) {
    return fold((_) => fallback, (data) => data);
  }

  /// Returns the success data, or throws the [AppError] if this is an [Error].
  T getOrThrow() {
    return fold(
      (error) => throw error,
      (data) => data,
    );
  }

  /// Converts this [Result] to a legacy [Either] for backward compatibility.
  Either<Failure, T> toEither() {
    return fold(
      (error) => Left(error.toFailure()),
      (data) => Right(data),
    );
  }
}

/// Represents a successful result containing [data].
final class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) => other is Success<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents an error result containing an [AppError].
final class Error<T> extends Result<T> {
  @override
  final AppError error;

  const Error(this.error);

  @override
  bool operator ==(Object other) => other is Error<T> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Error($error)';
}

/// Utility extensions for working with `Future<Result<T>>`.
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Maps the success value of a future [Result].
  Future<Result<R>> map<R>(R Function(T data) mapper) async {
    return (await this).map(mapper);
  }

  /// Maps the error value of a future [Result].
  Future<Result<T>> mapError(AppError Function(AppError error) mapper) async {
    return (await this).mapError(mapper);
  }

  /// Chains an asynchronous operation to a future [Result].
  Future<Result<R>> then<R>(Future<Result<R>> Function(T data) operation) async {
    return (await this).then(operation);
  }

  /// Catches exceptions from the future and converts them to an [Error] result.
  Future<Result<T>> catchError(
    AppError Function(dynamic error, StackTrace stackTrace) errorHandler,
  ) async {
    try {
      return await this;
    } catch (e, s) {
      return Result.error(errorHandler(e, s));
    }
  }

  /// Converts a `Future<Result<T>>` to a `Future<Either<Failure, T>>`.
  Future<Either<Failure, T>> toEither() async {
    return (await this).toEither();
  }
}

/// Backward compatibility extensions for [Either].
extension EitherToResultExtension<L extends Failure, R> on Either<L, R> {
  /// Converts an [Either] to a [Result].
  Result<R> toResult() {
    return fold(
      (failure) => Result.error(AppErrorFactory.fromFailure(failure)),
      (success) => Result.success(success),
    );
  }
}

/// Backward compatibility extensions for `Future<Either>`.
extension FutureEitherToResultExtension<L extends Failure, R> on Future<Either<L, R>> {
  /// Converts a `Future<Either>` to a `Future<Result>`.
  Future<Result<R>> toResult() async {
    final either = await this;
    return either.toResult();
  }
}

/// A utility class for creating [Result] instances from common operations.
class ResultUtils {
  /// Creates a [Result] by executing a synchronous [operation] that may throw.
  static Result<T> tryExecute<T>(T Function() operation) {
    try {
      return Result.success(operation());
    } catch (e, s) {
      return Result.error(AppErrorFactory.fromException(e, s));
    }
  }

  /// Creates a [Result] by executing an asynchronous [operation] that may throw.
  static Future<Result<T>> tryExecuteAsync<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Result.success(await operation());
    } catch (e, s) {
      return Result.error(AppErrorFactory.fromException(e, s));
    }
  }

  /// Combines a list of [Result]s into a single `Result<List<T>>`.
  /// If any result in the list is an [Error], this returns the first error found.
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final data = <T>[];
    for (final result in results) {
      if (result.isError) {
        return Result.error(result.error!);
      }
      data.add(result.data!);
    }
    return Result.success(data);
  }

  /// Creates a [Result] conditionally.
  static Result<T> when<T>(
    bool condition,
    T Function() onTrue,
    AppError Function() onFalse,
  ) {
    return condition ? tryExecute(onTrue) : Result.error(onFalse());
  }

  /// Creates a [Result] from a nullable value.
  static Result<T> fromNullable<T>(T? value, AppError Function() onNull) {
    return value != null ? Result.success(value) : Result.error(onNull());
  }
}