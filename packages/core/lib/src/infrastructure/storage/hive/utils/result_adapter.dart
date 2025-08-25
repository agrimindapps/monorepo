import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/result.dart';
import '../exceptions/storage_exceptions.dart';

/// Utilitários para conversão entre exceções de storage e AppError
class ResultAdapter {
  /// Converte StorageException em AppError
  static AppError fromStorageException(StorageException exception) {
    return AppError.custom(
      message: exception.message,
      code: exception.code ?? 'storage_error',
      details: {
        'originalError': exception.originalError?.toString(),
        'stackTrace': exception.stackTrace?.toString(),
      },
    );
  }

  /// Converte Exception genérica em AppError
  static AppError fromException(Exception exception) {
    if (exception is StorageException) {
      return fromStorageException(exception);
    }
    return AppError.unknown(exception.toString());
  }

  /// Cria Result de sucesso
  static Result<T> success<T>(T data) => Result.success(data);

  /// Cria Result de erro a partir de StorageException
  static Result<T> failure<T>(StorageException exception) {
    return Result.error(fromStorageException(exception));
  }

  /// Cria Result de erro a partir de Exception genérica
  static Result<T> error<T>(Exception exception) {
    return Result.error(fromException(exception));
  }

  /// Wrapper para executar código com tratamento de erro automático
  static Future<Result<T>> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Result.success(result);
    } on StorageException catch (e) {
      return failure<T>(e);
    } catch (e) {
      return error<T>(Exception(e.toString()));
    }
  }

  /// Wrapper síncrono para executar código com tratamento de erro automático
  static Result<T> executeSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Result.success(result);
    } on StorageException catch (e) {
      return failure<T>(e);
    } catch (e) {
      return error<T>(Exception(e.toString()));
    }
  }
}