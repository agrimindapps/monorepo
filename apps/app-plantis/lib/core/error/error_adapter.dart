import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

/// Adaptador para converter entre o sistema antigo (`Either<Failure, T>`) e o novo (`Result<T>`)
/// Facilita a migração gradual do sistema de erros
class ErrorAdapter {
  /// Converte Failure para AppError
  static AppError failureToAppError(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure _:
        return NetworkError(
          message: failure.message,
          code: 'NETWORK_ERROR',
          details: failure.toString(),
        );

      case ServerFailure _:
        return ExternalServiceError(
          message: failure.message,
          code: 'SERVER_ERROR',
          details: failure.toString(),
          serviceName: 'API',
        );

      case CacheFailure _:
        return StorageError(
          message: failure.message,
          code: 'CACHE_ERROR',
          details: failure.toString(),
        );

      case NotFoundFailure _:
        return BusinessError(
          message: failure.message,
          code: 'NOT_FOUND',
          details: failure.toString(),
          businessRule: 'RESOURCE_NOT_FOUND',
        );

      case AuthFailure _:
        return AuthenticationError(
          message: failure.message,
          code: 'UNAUTHORIZED',
          details: failure.toString(),
        );

      case ValidationFailure _:
        return ValidationError(
          message: failure.message,
          code: 'VALIDATION_ERROR',
          details: failure.toString(),
        );

      case UnknownFailure _:
      default:
        return UnknownError(
          message: failure.message,
          code: 'UNKNOWN_ERROR',
          details: failure.toString(),
          originalError: failure,
        );
    }
  }

  /// Converte AppError para Failure
  static Failure appErrorToFailure(AppError error) {
    switch (error.category) {
      case ErrorCategory.network:
        return NetworkFailure(error.message);

      case ErrorCategory.external:
        return ServerFailure(error.message);

      case ErrorCategory.storage:
        return CacheFailure(error.message);

      case ErrorCategory.authentication:
        return AuthFailure(error.message);

      case ErrorCategory.validation:
        return ValidationFailure(error.message);

      case ErrorCategory.business:
        if (error is BusinessError &&
            error.businessRule == 'RESOURCE_NOT_FOUND') {
          return NotFoundFailure(error.message);
        }
        return UnknownFailure(error.message);

      case ErrorCategory.permission:
      case ErrorCategory.general:
        return UnknownFailure(error.message);
    }
  }

  /// Converte `Either<Failure, T>` para `Result<T>`
  static Result<T> eitherToResult<T>(Either<Failure, T> either) {
    return either.fold(
      (failure) => Result.error(failureToAppError(failure)),
      (success) => Result.success(success),
    );
  }

  /// Converte `Result<T>` para `Either<Failure, T>`
  static Either<Failure, T> resultToEither<T>(Result<T> result) {
    return result.fold(
      (error) => Left(appErrorToFailure(error)),
      (success) => Right(success),
    );
  }

  /// Converte `Future<Either<Failure, T>>` para `Future<Result<T>>`
  static Future<Result<T>> futureEitherToResult<T>(
    Future<Either<Failure, T>> futureEither,
  ) async {
    final either = await futureEither;
    return eitherToResult(either);
  }

  /// Converte `Future<Result<T>>` para `Future<Either<Failure, T>>`
  static Future<Either<Failure, T>> futureResultToEither<T>(
    Future<Result<T>> futureResult,
  ) async {
    final result = await futureResult;
    return resultToEither(result);
  }
}

/// Extensões para facilitar a conversão
extension ResultToEitherExtension<T> on Result<T> {
  /// Converte Result para Either
  Either<Failure, T> toEither() => ErrorAdapter.resultToEither(this);
}

extension FutureResultToEitherExtension<T> on Future<Result<T>> {
  /// Converte `Future<Result>` para `Future<Either>`
  Future<Either<Failure, T>> toEither() =>
      ErrorAdapter.futureResultToEither(this);
}

/// Wrapper para repositórios antigos que ainda usam Either
class RepositoryWrapper<T> {
  final Future<Either<Failure, T>> Function() _operation;

  RepositoryWrapper(this._operation);

  /// Executa a operação e retorna Result
  Future<Result<T>> execute() async {
    try {
      final either = await _operation();
      return ErrorAdapter.eitherToResult(either);
    } catch (error, stackTrace) {
      return Result.error(
        UnknownError(
          message: 'Erro na operação do repositório: ${error.toString()}',
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Helper para migração gradual de UseCases
abstract class MigratedUseCase<T, P> {
  /// Novo método que retorna Result
  Future<Result<T>> executeNew(P params);

  /// Método antigo que retorna Either (para compatibilidade)
  Future<Either<Failure, T>> call(P params) async {
    final result = await executeNew(params);
    return result.toEither();
  }
}

/// Mixin para providers que facilita o uso do novo sistema de erros
mixin ErrorHandlingMixin on ChangeNotifier {
  AppError? _lastError;
  bool _hasError = false;

  AppError? get lastError => _lastError;
  bool get hasError => _hasError;

  /// Limpa o erro atual
  void clearError() {
    if (_hasError) {
      _lastError = null;
      _hasError = false;
      notifyListeners();
    }
  }

  /// Define um erro
  void setError(AppError error) {
    _lastError = error;
    _hasError = true;
    notifyListeners();
  }

  /// Executa uma operação e trata erros automaticamente
  Future<T?> handleOperation<T>(Future<Result<T>> Function() operation) async {
    clearError();

    final result = await operation();

    return result.fold((error) {
      setError(error);
      return null;
    }, (data) => data);
  }

  /// Executa uma operação Either e converte para Result
  Future<T?> handleEitherOperation<T>(
    Future<Either<Failure, T>> Function() operation,
  ) async {
    return handleOperation(() async {
      final either = await operation();
      return ErrorAdapter.eitherToResult(either);
    });
  }
}
