import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import 'failure.dart';

/// Adaptador para converter entre o sistema antigo (Either<Failure, T>) e o novo (Either<Failure, T>)
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

  /// Retorna Either sem conversão (método legacy, mantido para compatibilidade)
  static Either<Failure, T> eitherToResult<T>(Either<Failure, T> either) {
    return either;
  }

  /// Retorna Either sem conversão (método legacy, mantido para compatibilidade)
  static Either<Failure, T> resultToEither<T>(Either<Failure, T> result) {
    return result;
  }

  /// Retorna Future<Either> sem conversão (método legacy, mantido para compatibilidade)
  static Future<Either<Failure, T>> futureEitherToResult<T>(
    Future<Either<Failure, T>> futureEither,
  ) async {
    return futureEither;
  }

  /// Retorna Future<Either> sem conversão (método legacy, mantido para compatibilidade)
  static Future<Either<Failure, T>> futureResultToEither<T>(
    Future<Either<Failure, T>> futureResult,
  ) async {
    return futureResult;
  }
}

/// Wrapper para repositórios antigos que ainda usam Either
class RepositoryWrapper<T> {
  final Future<Either<Failure, T>> Function() _operation;

  RepositoryWrapper(this._operation);

  /// Executa a operação e retorna Either
  Future<Either<Failure, T>> execute() async {
    try {
      return await _operation();
    } catch (error, stackTrace) {
      final appError = AppErrorFactory.fromException(error, stackTrace);
      final failure = appError.toFailure();
      return Left(failure);
    }
  }
}

/// Helper para migração gradual de UseCases
abstract class MigratedUseCase<T, P> {
  Future<Either<Failure, T>> executeNew(P params);

  /// Chamado para manter a compatibilidade com o sistema antigo
  Future<Either<Failure, T>> call(P params) async {
    final result = await executeNew(params);
    return result;
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

  /// Define um erro a partir de uma Failure ou AppError
  void setError(dynamic error) {
    if (error is AppError) {
      _lastError = error;
    } else if (error is Failure) {
      _lastError = AppErrorFactory.fromFailure(error);
    }
    _hasError = true;
    notifyListeners();
  }

  /// Executa uma operação e trata erros automaticamente
  Future<T?> handleOperation<T>(Future<Either<Failure, T>> Function() operation) async {
    clearError();

    final result = await operation();

    return result.fold((error) {
      setError(error);
      return null;
    }, (data) => data);
  }

  /// Executa uma operação Either e trata erros
  Future<T?> handleEitherOperation<T>(
    Future<Either<Failure, T>> Function() operation,
  ) async {
    return handleOperation(operation);
  }

  /// Executa operação com callback de sucesso
  Future<T?> handleOperationWithCallback<T>(
    Future<Either<Failure, T>> Function() operation, {
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
        duration: Duration(
          seconds: error.severity == ErrorSeverity.critical ? 10 : 4,
        ),
        action:
            error.severity == ErrorSeverity.critical
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
      builder:
          (context) => AlertDialog(
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
      if (error.stackTrace != null &&
          error.severity == ErrorSeverity.critical) {
        debugPrint('   Stack: [Stack trace available for critical errors]');
      }
    }
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
    if (additionalContext != null) {
      for (final entry in additionalContext.entries) {
        if (!_isSensitiveKey(entry.key)) {
          sanitizedContext[entry.key] = entry.value;
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        '🚨 AppError with context: ${_sanitizeMessage(error.message)}',
      );
      debugPrint('   Context: $sanitizedContext');
    }
  }

  /// Sanitizes error messages to remove sensitive information
  static String _sanitizeMessage(String message) {
    return message
        .replaceAll(
          RegExp(r'password[\s:=][\w]+', caseSensitive: false),
          'password=[REDACTED]',
        )
        .replaceAll(
          RegExp(r'token[\s:=][\w\-._]+', caseSensitive: false),
          'token=[REDACTED]',
        )
        .replaceAll(
          RegExp(r'key[\s:=][\w\-._]+', caseSensitive: false),
          'key=[REDACTED]',
        )
        .replaceAll(
          RegExp(r'secret[\s:=][\w\-._]+', caseSensitive: false),
          'secret=[REDACTED]',
        )
        .replaceAll(
          RegExp(r'[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}'),
          '[EMAIL_REDACTED]',
        )
        .replaceAll(
          RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
          '[CARD_REDACTED]',
        );
  }

  /// Sanitizes user ID to remove sensitive information while keeping it useful for debugging
  static String _sanitizeUserId(String userId) {
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  /// Checks if a key contains sensitive information
  static bool _isSensitiveKey(String key) {
    final sensitivePatterns = [
      'password',
      'secret',
      'token',
      'key',
      'credential',
      'auth',
      'session',
    ];
    final keyLower = key.toLowerCase();
    return sensitivePatterns.any((pattern) => keyLower.contains(pattern));
  }
}

/// Extensões de compatibilidade retroativa
extension ResultCompatExtensions<T> on Either<Failure, T> {
  /// Retorna Either sem conversão (compatibilidade)
  Either<Failure, T> asEither() => this;
}

extension EitherCompatExtensions<L extends Failure, R> on Either<L, R> {
  /// Retorna Either sem conversão (migração)
  Either<Failure, R> asResult() => fold(
    (failure) => Left(failure),
    (right) => Right(right),
  );
}
