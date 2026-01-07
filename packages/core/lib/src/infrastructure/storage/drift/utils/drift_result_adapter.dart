import 'package:dartz/dartz.dart';
import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/failure.dart';
import '../exceptions/drift_exceptions.dart';

/// Utilitários para conversão entre exceções Drift e AppError
/// Equivalente Drift do ResultAdapter (Hive)
class DriftResultAdapter {
  /// Converte DriftException em AppError
  static AppError fromDriftException(DriftException exception) {
    return AppError.custom(
      message: exception.message,
      code: _getErrorCode(exception),
      details: {
        'originalError': exception.originalError?.toString(),
        'stackTrace': exception.stackTrace?.toString(),
        if (exception is DriftDatabaseException) 'databaseName': exception.databaseName,
        if (exception is DriftTableException) 'tableName': exception.tableName,
        if (exception is DriftQueryException && exception.query != null) 'query': exception.query,
        if (exception is DriftMigrationException) ...{
          'fromVersion': exception.fromVersion,
          'toVersion': exception.toVersion,
        },
      },
    );
  }

  /// Gera código de erro apropriado baseado no tipo de exceção
  static String _getErrorCode(DriftException exception) {
    if (exception is DriftInitializationException) return 'drift_initialization_error';
    if (exception is DriftDatabaseException) return 'drift_database_error';
    if (exception is DriftTableException) return 'drift_table_error';
    if (exception is DriftQueryException) return 'drift_query_error';
    if (exception is DriftMigrationException) return 'drift_migration_error';
    if (exception is DriftValidationException) return 'drift_validation_error';
    if (exception is DriftConstraintException) return 'drift_constraint_error';
    if (exception is DriftTransactionException) return 'drift_transaction_error';
    return 'drift_error';
  }

  /// Converte Exception genérica em AppError
  static AppError fromException(Exception exception) {
    if (exception is DriftException) {
      return fromDriftException(exception);
    }
    return AppError.unknown(exception.toString());
  }

  /// Cria Result de sucesso
  static Either<Failure, T> success<T>(T data) => Right(data);

  /// Cria Result de erro a partir de DriftException
  static Either<Failure, T> failure<T>(DriftException exception) {
    final appError = fromDriftException(exception);
    return Left(appError.toFailure());
  }

  /// Cria Result de erro a partir de Exception genérica
  static Either<Failure, T> error<T>(Exception exception) {
    final appError = fromException(exception);
    return Left(appError.toFailure());
  }

  /// Wrapper para executar código com tratamento de erro automático
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await DriftResultAdapter.execute(() async {
  ///   return await database.select(table).get();
  /// });
  /// ```
  static Future<Either<Failure, T>> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Right(result);
    } on DriftException catch (e) {
      return failure<T>(e);
    } catch (e) {
      return error<T>(Exception(e.toString()));
    }
  }

  /// Wrapper síncrono para executar código com tratamento de erro automático
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = DriftResultAdapter.executeSync(() {
  ///   return database.isInitialized;
  /// });
  /// ```
  static Either<Failure, T> executeSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Right(result);
    } on DriftException catch (e) {
      return failure<T>(e);
    } catch (e) {
      return error<T>(Exception(e.toString()));
    }
  }

  /// Converte lista de Results em Result de lista
  /// Útil para batch operations
  ///
  /// Se qualquer Result falhar, retorna o primeiro erro
  static Either<Failure, List<T>> combineResults<T>(List<Either<Failure, T>> results) {
    final data = <T>[];

    for (final result in results) {
      final hasError = result.fold(
        (_) => true,
        (_) => false,
      );

      if (hasError) {
        return result.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Unreachable'),
        );
      }

      result.fold(
        (_) => null,
        (value) => data.add(value),
      );
    }

    return Right(data);
  }

  /// Converte Result em Future para uso com async/await
  static Future<T> toFuture<T>(Either<Failure, T> result) async {
    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data,
    );
  }

  /// Executa operação com retry automático em caso de falha
  ///
  /// [maxAttempts] número máximo de tentativas (padrão: 3)
  /// [delay] delay entre tentativas em milissegundos (padrão: 100ms)
  static Future<Either<Failure, T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    int delayMs = 100,
  }) async {
    assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await execute(operation);

      final isSuccess = result.fold(
        (_) => false,
        (_) => true,
      );

      if (isSuccess) {
        return result;
      }

      if (attempt < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      } else {
        return result;
      }
    }

    return const Left(UnexpectedFailure('Unexpected error in retry logic'));
  }
}
