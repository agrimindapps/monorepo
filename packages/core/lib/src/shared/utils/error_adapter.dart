import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import 'failure.dart';
import 'result.dart';

/// Adaptador para converter entre o sistema antigo (Either<Failure, T>) e o novo (Result<T>)
/// Facilita a migração gradual do sistema de erros
class ErrorAdapter {
  /// Converte Failure para AppError
  static AppError failureToAppError(Failure failure) {
    return AppErrorFactory.fromFailure(failure);
  }

  /// Converte AppError para Failure
  static Failure appErrorToFailure(AppError error) {
    return error.toFailure();
  }

  /// Converte Either<Failure, T> para Result<T>
  static Result<T> eitherToResult<T>(Either<Failure, T> either) {
    return either.fold(
      (failure) => Result.error(failureToAppError(failure)),
      (success) => Result.success(success),
    );
  }

  /// Converte Result<T> para Either<Failure, T>
  static Either<Failure, T> resultToEither<T>(Result<T> result) {
    return result.fold(
      (error) => Left(appErrorToFailure(error)),
      (success) => Right(success),
    );
  }

  /// Converte Future<Either<Failure, T>> para Future<Result<T>>
  static Future<Result<T>> futureEitherToResult<T>(
    Future<Either<Failure, T>> futureEither,
  ) async {
    final either = await futureEither;
    return eitherToResult(either);
  }

  /// Converte Future<Result<T>> para Future<Either<Failure, T>>
  static Future<Either<Failure, T>> futureResultToEither<T>(
    Future<Result<T>> futureResult,
  ) async {
    final result = await futureResult;
    return resultToEither(result);
  }
}

/// Wrapper para repositórios antigos que ainda usam Either
class RepositoryWrapper<T> {
  final Future<Either<Failure, T>> Function() _operation;

  RepositoryWrapper(this._operation);

  /// Executa a operação e retorna Result
  Future<Result<T>> execute() async {
    try {
      final either = await _operation();
      return either.toResult();
    } catch (error, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(error, stackTrace),
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
      return either.toResult();
    });
  }

  /// Executa operação com callback de sucesso
  Future<T?> handleOperationWithCallback<T>(
    Future<Result<T>> Function() operation, {
    void Function(T data)? onSuccess,
    void Function(AppError error)? onError,
  }) async {
    final result = await handleOperation(operation);
    
    if (result != null) {
      onSuccess?.call(result);
    } else if (_lastError != null) {
      onError?.call(_lastError!);
    }
    
    return result;
  }
}

/// Mixin para widgets que facilita o tratamento de erros
mixin ErrorDisplayMixin {
  /// Mostra erro para o usuário
  void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userMessage),
        backgroundColor: _getErrorColor(error.severity),
        duration: Duration(seconds: error.severity == ErrorSeverity.critical ? 10 : 4),
        action: error.severity == ErrorSeverity.critical
            ? SnackBarAction(
                label: 'Detalhes',
                onPressed: () => _showErrorDetails(context, error),
              )
            : null,
      ),
    );
  }

  /// Mostra detalhes do erro em dialog
  void _showErrorDetails(BuildContext context, AppError error) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Erro'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mensagem: ${error.message}'),
              if (error.code != null) Text('Código: ${error.code}'),
              if (error.details != null) Text('Detalhes: ${error.details}'),
              Text('Categoria: ${error.category.name}'),
              Text('Severidade: ${error.severity.name}'),
              Text('Timestamp: ${error.timestamp}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Retorna cor baseada na severidade
  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.red;
      case ErrorSeverity.high:
        return Colors.red.shade700;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }
}

/// Utilitários para logging de erros
class ErrorLogger {
  /// Registra erro no sistema de logging
  static void logError(AppError error) {
    if (kDebugMode) {
      debugPrint('🚨 AppError: ${_sanitizeMessage(error.message)}');
      debugPrint('   Category: ${error.category.name}');
      debugPrint('   Severity: ${error.severity.name}');
      if (error.code != null) debugPrint('   Code: ${error.code}');
      // Don't log full stack traces in production builds or when they might contain sensitive data
      if (error.stackTrace != null && error.severity == ErrorSeverity.critical) {
        debugPrint('   Stack: [Stack trace available for critical errors]');
      }
    }

    // Integrate with logging services like Firebase Crashlytics in production
    // Only send sanitized error information to external services
    // FirebaseCrashlytics.instance.recordError(
    //   _sanitizeMessage(error.message),
    //   null, // Don't send stack traces unless necessary
    //   information: _sanitizeErrorData(error),
    // );
  }

  /// Registra erro com contexto adicional
  static void logErrorWithContext(
    AppError error, {
    String? userId,
    Map<String, dynamic>? additionalContext,
  }) {
    final sanitizedContext = <String, dynamic>{
      'user_id': userId != null ? _sanitizeUserId(userId) : null,
      'error_category': error.category.name,
      'error_severity': error.severity.name,
      'error_code': error.code,
    };
    
    // Add non-sensitive additional context separately
    if (additionalContext != null) {
      for (final entry in additionalContext.entries) {
        if (!_isSensitiveKey(entry.key)) {
          sanitizedContext[entry.key] = entry.value;
        }
      }
    }

    if (kDebugMode) {
      debugPrint('🚨 AppError with context: ${_sanitizeMessage(error.message)}');
      debugPrint('   Context: $sanitizedContext');
    }

    // Integration with analytics/logging - send only sanitized data
  }

  /// Sanitizes error messages to remove sensitive information
  static String _sanitizeMessage(String message) {
    // Remove common sensitive patterns
    return message
        .replaceAll(RegExp(r'password[\s:=][\w]+', caseSensitive: false), 'password=[REDACTED]')
        .replaceAll(RegExp(r'token[\s:=][\w\-._]+', caseSensitive: false), 'token=[REDACTED]')
        .replaceAll(RegExp(r'key[\s:=][\w\-._]+', caseSensitive: false), 'key=[REDACTED]')
        .replaceAll(RegExp(r'secret[\s:=][\w\-._]+', caseSensitive: false), 'secret=[REDACTED]')
        .replaceAll(RegExp(r'[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}'), '[EMAIL_REDACTED]')
        .replaceAll(RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), '[CARD_REDACTED]');
  }

  /// Sanitizes user ID to remove sensitive information while keeping it useful for debugging
  static String _sanitizeUserId(String userId) {
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  /// Checks if a key contains sensitive information
  static bool _isSensitiveKey(String key) {
    final sensitivePatterns = ['password', 'secret', 'token', 'key', 'credential', 'auth', 'session'];
    final keyLower = key.toLowerCase();
    return sensitivePatterns.any((pattern) => keyLower.contains(pattern));
  }
}

/// Extensões de compatibilidade retroativa
extension ResultCompatExtensions<T> on Result<T> {
  /// Converte para Either (compatibilidade)
  Either<Failure, T> asEither() => toEither();
}

extension EitherCompatExtensions<L extends Failure, R> on Either<L, R> {
  /// Converte para Result (migração)
  Result<R> asResult() => toResult();
}

extension FutureEitherCompatExtensions<L extends Failure, R>
    on Future<Either<L, R>> {
  /// Converte para Future<Result> (migração)
  Future<Result<R>> asResult() => toResult();
}

extension FutureResultCompatExtensions<T> on Future<Result<T>> {
  /// Converte para Future<Either> (compatibilidade)
  Future<Either<Failure, T>> asEither() => toEither();
}