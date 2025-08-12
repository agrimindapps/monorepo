// Project imports:
import '../errors/gasometer_exceptions.dart';
import '../services/error_handler.dart';

/// Result type para operações que podem falhar
/// 
/// Oferece controle explícito de fluxo de erro sem usar exceptions
/// em casos onde o erro é esperado e deve ser tratado explicitamente
sealed class Result<T, E extends Exception> {
  const Result();
  
  /// Cria um resultado de sucesso
  const factory Result.success(T data) = Success<T, E>;
  
  /// Cria um resultado de erro
  const factory Result.failure(E error) = Failure<T, E>;

  /// Executa callback apenas se for sucesso
  Result<R, E> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success(value: final data) => Result.success(mapper(data)),
      Failure(exception: final error) => Result.failure(error),
    };
  }

  /// Executa callback apenas se for erro
  Result<T, R> mapError<R extends Exception>(R Function(E error) mapper) {
    return switch (this) {
      Success(value: final data) => Result.success(data),
      Failure(exception: final error) => Result.failure(mapper(error)),
    };
  }

  /// Chain de operações que podem falhar
  Result<R, E> flatMap<R>(Result<R, E> Function(T data) mapper) {
    return switch (this) {
      Success(value: final data) => mapper(data),
      Failure(exception: final error) => Result.failure(error),
    };
  }

  /// Retorna valor se sucesso, ou executa callback de erro
  T fold<R>(
    T Function(E error) onError,
    T Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(value: final data) => onSuccess(data),
      Failure(exception: final error) => onError(error),
    };
  }

  /// Executa side effects baseados no resultado
  void when({
    required void Function(T data) onSuccess,
    required void Function(E error) onError,
  }) {
    switch (this) {
      case Success(value: final data):
        onSuccess(data);
        break;
      case Failure(exception: final error):
        onError(error);
        break;
    }
  }

  /// Verifica se é sucesso
  bool get isSuccess => this is Success<T, E>;

  /// Verifica se é erro
  bool get isFailure => this is Failure<T, E>;

  /// Obtém dados (throws se for erro)
  T get data {
    return switch (this) {
      Success(value: final data) => data,
      Failure(exception: final error) => throw error,
    };
  }

  /// Obtém dados ou null se erro
  T? get dataOrNull {
    return switch (this) {
      Success(value: final data) => data,
      Failure() => null,
    };
  }

  /// Obtém erro (throws se for sucesso)
  E get error {
    return switch (this) {
      Success() => throw StateError('Result is success, not failure'),
      Failure(exception: final error) => error,
    };
  }

  /// Obtém erro ou null se sucesso
  E? get errorOrNull {
    return switch (this) {
      Success() => null,
      Failure(exception: final error) => error,
    };
  }

  /// Converte para Future (útil para async operations)
  Future<T> toFuture() async {
    return switch (this) {
      Success(value: final data) => data,
      Failure(exception: final error) => throw error,
    };
  }

  /// Cria Result a partir de função que pode lançar exception
  static Result<T, Exception> fromTry<T>(T Function() operation) {
    try {
      return Result.success(operation());
    } catch (error) {
      return Result.failure(error is Exception ? error : Exception(error.toString()));
    }
  }

  /// Cria Result a partir de Future que pode falhar
  static Future<Result<T, Exception>> fromFuture<T>(Future<T> future) async {
    try {
      final data = await future;
      return Result.success(data);
    } catch (error) {
      return Result.failure(error is Exception ? error : Exception(error.toString()));
    }
  }
}

/// Resultado de sucesso
final class Success<T, E extends Exception> extends Result<T, E> {
  final T value;
  
  const Success(this.value);

  @override
  bool operator ==(Object other) {
    return other is Success<T, E> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Resultado de erro
final class Failure<T, E extends Exception> extends Result<T, E> {
  final E exception;
  
  const Failure(this.exception);

  @override
  bool operator ==(Object other) {
    return other is Failure<T, E> && other.exception == exception;
  }

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure($exception)';
}

// MARK: - Specialized Result Types for Gasometer

/// Result específico para operações do módulo Gasometer
typedef GasometerResult<T> = Result<T, GasometerException>;

/// Result específico para operações de Veículos
typedef VeiculoResult<T> = Result<T, VeiculoException>;

/// Result específico para operações de Abastecimentos
typedef AbastecimentoResult<T> = Result<T, AbastecimentoException>;

/// Result específico para operações de Odômetro
typedef OdometroResult<T> = Result<T, OdometroException>;

/// Result específico para operações de Despesas
typedef DespesaResult<T> = Result<T, DespesaException>;

/// Result específico para operações de Manutenções
typedef ManutencaoResult<T> = Result<T, ManutencaoException>;

/// Result específico para operações de Storage
typedef StorageResult<T> = Result<T, StorageException>;

/// Result específico para operações de Rede
typedef NetworkResult<T> = Result<T, NetworkException>;

// MARK: - Extension Methods

/// Extensions para facilitar trabalho com Results
extension ResultExtensions<T> on Result<T, Exception> {
  /// Converte para GasometerResult
  GasometerResult<T> toGasometerResult() {
    return switch (this) {
      Success(value: final data) => Result.success(data),
      Failure(exception: final error) => Result.failure(
        error is GasometerException ? error : wrapException(error)
      ),
    };
  }
}

/// Extensions específicas para GasometerResult
extension GasometerResultExtensions<T> on GasometerResult<T> {
  /// Log automático do erro se falhar
  GasometerResult<T> logOnError({
    String? operation,
    Map<String, dynamic>? context,
  }) {
    when(
      onSuccess: (_) {},
      onError: (error) => GasometerErrorHandler.instance.logGasometerException(error),
    );
    return this;
  }

  /// Retry automático com backoff exponencial
  Future<GasometerResult<T>> retryOnError({
    required Future<GasometerResult<T>> Function() operation,
    int maxRetries = 3,
    Duration baseDelay = const Duration(milliseconds: 500),
  }) async {
    if (isSuccess) return this;
    
    var currentResult = this;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      await Future.delayed(baseDelay * attempt);
      currentResult = await operation();
      if (currentResult.isSuccess) break;
    }
    
    return currentResult;
  }

  /// Fallback para valor padrão em caso de erro
  T getOrElse(T defaultValue) {
    return fold(
      (error) => defaultValue,
      (data) => data,
    );
  }

  /// Fallback para função que calcula valor padrão
  T getOrCompute(T Function(GasometerException error) compute) {
    return fold(
      (error) => compute(error),
      (data) => data,
    );
  }
}

// MARK: - Utility Functions

/// Cria Result de sucesso (helper function)
GasometerResult<T> success<T>(T data) => Result.success(data);

/// Cria Result de erro (helper function)  
GasometerResult<T> failure<T>(GasometerException error) => Result.failure(error);

/// Combina múltiplos Results (falha se qualquer um falhar)
GasometerResult<List<T>> combineResults<T>(List<GasometerResult<T>> results) {
  final data = <T>[];
  
  for (final result in results) {
    switch (result) {
      case Success(value: final value):
        data.add(value);
        break;
      case Failure(exception: final error):
        return Result.failure(error);
    }
  }
  
  return Result.success(data);
}

/// Executa operações em paralelo e combina resultados
Future<GasometerResult<List<T>>> parallelResults<T>(
  List<Future<GasometerResult<T>>> futures,
) async {
  final results = await Future.wait(futures);
  return combineResults(results);
}