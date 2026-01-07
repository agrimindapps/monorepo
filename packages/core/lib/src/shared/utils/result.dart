import 'package:dartz/dartz.dart';
import 'app_error.dart';
import 'failure.dart';

/// Pattern Result para encapsular sucesso e erro de forma type-safe
/// Substitui o Either<Failure, Success> por uma implementação mais simples e específica
///
/// {@category Deprecated}
/// **DEPRECATED**: Use Either<Failure, T> instead (from dartz package).
///
/// Motivo: Either<Failure, T> é o padrão estabelecido no monorepo (66+ arquivos).
/// Result<T> foi criado antes da padronização e causa inconsistência.
///
/// Migração:
/// ```dart
/// // Antes:
/// Future<Result<User>> getUser() async {
///   try {
///     final user = await api.getUser();
///     return Result.success(user);
///   } catch (e) {
///     return Result.error(AppError.unknown(e.toString()));
///   }
/// }
///
/// // Depois:
/// Future<Either<Failure, User>> getUser() async {
///   try {
///     final user = await api.getUser();
///     return Right(user);
///   } catch (e) {
///     return Left(ServerFailure(e.toString()));
///   }
/// }
/// ```
///
/// Conversão temporária (para migração gradual):
/// ```dart
/// final result = await oldService.getData(); // Returns Result<T>
/// final either = result.toEither(); // Convert to Either<Failure, T>
/// ```
@Deprecated(
  'Use Either<Failure, T> from dartz package instead. '
  'Result<T> will be removed in v2.0.0. '
  'See migration guide in class documentation.',
)
sealed class Result<T> {
  const Result();

  /// Cria um resultado de sucesso
  factory Result.success(T data) = Success<T>;

  /// Cria um resultado de erro
  factory Result.error(AppError error) = Error<T>;

  /// Cria um resultado de erro (alias para error - compatibilidade)
  factory Result.failure(AppError error) = Error<T>;

  /// Verifica se o resultado é um sucesso
  bool get isSuccess => this is Success<T>;

  /// Verifica se o resultado é um erro
  bool get isError => this is Error<T>;

  /// Verifica se o resultado é um erro (alias para isError - compatibilidade)
  bool get isFailure => this is Error<T>;

  /// Obtém os dados se for sucesso, null caso contrário
  T? get data => switch (this) {
    Success<T> success => success.data,
    Error<T> _ => null,
  };

  /// Obtém o erro se for erro, null caso contrário
  AppError? get error => switch (this) {
    Success<T> _ => null,
    Error<T> error => error.error,
  };

  /// Executa uma função dependendo do resultado
  R fold<R>(R Function(AppError error) onError, R Function(T data) onSuccess) {
    return switch (this) {
      Success<T> success => onSuccess(success.data),
      Error<T> error => onError(error.error),
    };
  }

  /// Mapeia o valor de sucesso para outro tipo
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T> success => Result.success(mapper(success.data)),
      Error<T> error => Result.error(error.error),
    };
  }

  /// Mapeia o erro para outro erro
  Result<T> mapError(AppError Function(AppError error) mapper) {
    return switch (this) {
      Success<T> success => success,
      Error<T> error => Result.error(mapper(error.error)),
    };
  }

  /// Executa uma operação assíncrona se for sucesso
  Future<Result<R>> then<R>(
    Future<Result<R>> Function(T data) operation,
  ) async {
    return switch (this) {
      Success<T> success => await operation(success.data),
      Error<T> error => Result.error(error.error),
    };
  }

  /// Executa uma ação apenas se for sucesso
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Executa uma ação apenas se for erro
  Result<T> onError(void Function(AppError error) action) {
    if (this is Error<T>) {
      action((this as Error<T>).error);
    }
    return this;
  }

  /// Tenta recuperar de um erro transformando-o em sucesso
  Result<T> recover(T Function(AppError error) recovery) {
    return switch (this) {
      Success<T> success => success,
      Error<T> error => Result.success(recovery(error.error)),
    };
  }

  /// Adiciona um fallback para caso de erro
  T getOrElse(T fallback) {
    return switch (this) {
      Success<T> success => success.data,
      Error<T> _ => fallback,
    };
  }

  /// Lança uma exceção se for erro, retorna dados se for sucesso
  T getOrThrow() {
    return switch (this) {
      Success<T> success => success.data,
      Error<T> error => throw Exception(error.error.toString()),
    };
  }

  /// Converte Result<T> para Either<Failure, T> (compatibilidade)
  Either<Failure, T> toEither() {
    return fold((error) => Left(error.toFailure()), (data) => Right(data));
  }
}

/// Representa um resultado de sucesso
final class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Representa um resultado de erro
final class Error<T> extends Result<T> {
  @override
  final AppError error;

  const Error(this.error);

  @override
  bool operator ==(Object other) {
    return other is Error<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Error($error)';
}

/// Extensões para facilitar o uso com Futures
extension FutureResultExtensions<T> on Future<Result<T>> {
  /// Mapeia o resultado futuro
  Future<Result<R>> mapResult<R>(R Function(T data) mapper) async {
    final result = await this;
    return result.map(mapper);
  }

  /// Mapeia o erro futuro
  Future<Result<T>> mapErrorResult(
    AppError Function(AppError error) mapper,
  ) async {
    final result = await this;
    return result.mapError(mapper);
  }

  /// Executa uma operação em cadeia
  Future<Result<R>> thenResult<R>(
    Future<Result<R>> Function(T data) operation,
  ) async {
    final result = await this;
    return await result.then(operation);
  }

  /// Adiciona tratamento de erro
  Future<Result<T>> catchError(
    AppError Function(dynamic error, StackTrace stackTrace) errorHandler,
  ) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      return Result.error(errorHandler(error, stackTrace));
    }
  }

  /// Converte para Either (compatibilidade)
  Future<Either<Failure, T>> toEither() async {
    final result = await this;
    return result.toEither();
  }
}

/// Extensões para Either (compatibilidade retroativa)
extension EitherToResultExtension<L extends Failure, R> on Either<L, R> {
  /// Converte Either para Result
  Result<R> toResult() {
    return fold(
      (failure) => Result.error(AppErrorFactory.fromFailure(failure)),
      (success) => Result.success(success),
    );
  }
}

extension FutureEitherToResultExtension<L extends Failure, R>
    on Future<Either<L, R>> {
  /// Converte Future<Either> para Future<Result>
  Future<Result<R>> toResult() async {
    final either = await this;
    return either.toResult();
  }
}

/// Utilitários para criar Results a partir de operações comuns
class ResultUtils {
  /// Executa uma operação que pode lançar exceção
  static Result<T> tryExecute<T>(T Function() operation) {
    try {
      return Result.success(operation());
    } catch (error, stackTrace) {
      if (error is AppError) {
        return Result.error(error);
      }
      return Result.error(AppErrorFactory.fromException(error, stackTrace));
    }
  }

  /// Executa uma operação assíncrona que pode lançar exceção
  static Future<Result<T>> tryExecuteAsync<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (error, stackTrace) {
      if (error is AppError) {
        return Result.error(error);
      }
      return Result.error(AppErrorFactory.fromException(error, stackTrace));
    }
  }

  /// Combina múltiplos Results em um só
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> data = [];

    for (final result in results) {
      switch (result) {
        case Success<T> success:
          data.add(success.data);
        case Error<T> error:
          return Result.error(error.error);
      }
    }

    return Result.success(data);
  }

  /// Executa uma operação apenas se todas as condições forem atendidas
  static Result<T> when<T>(
    bool condition,
    T Function() onTrue,
    AppError Function() onFalse,
  ) {
    if (condition) {
      return tryExecute(onTrue);
    } else {
      return Result.error(onFalse());
    }
  }

  /// Cria Result a partir de valor nullable
  static Result<T> fromNullable<T>(T? value, AppError Function() onNull) {
    if (value != null) {
      return Result.success(value);
    } else {
      return Result.error(onNull());
    }
  }

  /// Converte Either para Result (factory method)
  static Result<T> fromEither<T>(Either<Failure, T> either) {
    return either.toResult();
  }

  /// Converte Future<Either> para Future<Result> (factory method)
  static Future<Result<T>> fromFutureEither<T>(
    Future<Either<Failure, T>> futureEither,
  ) {
    return futureEither.toResult();
  }
}

/// Utility class for working with Either<Failure, T>
/// Modern replacement for ResultUtils that works with dartz Either
class EitherUtils {
  /// Executes a synchronous operation that may throw exceptions
  /// Returns Either<Failure, T> instead of Result<T>
  static Either<Failure, T> tryExecute<T>(T Function() operation) {
    try {
      return Right(operation());
    } catch (error) {
      if (error is Failure) {
        return Left(error);
      }
      return Left(UnexpectedFailure('Erro inesperado: ${error.toString()}'));
    }
  }

  /// Executes an async operation that may throw exceptions
  /// Returns Future<Either<Failure, T>> instead of Future<Result<T>>
  static Future<Either<Failure, T>> tryExecuteAsync<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (error) {
      if (error is Failure) {
        return Left(error);
      }
      return Left(UnexpectedFailure('Erro inesperado: ${error.toString()}'));
    }
  }

  /// Combines multiple Either results into one
  static Either<Failure, List<T>> combine<T>(List<Either<Failure, T>> results) {
    final List<T> data = [];

    for (final result in results) {
      final value = result.fold((failure) => null, (success) => success);

      if (value == null) {
        return result.fold(
          (failure) => Left(failure),
          (_) => const Left(UnexpectedFailure('Unexpected null value')),
        );
      }

      data.add(value);
    }

    return Right(data);
  }
}
