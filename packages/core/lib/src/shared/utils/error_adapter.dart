import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import 'failure.dart';
import 'result.dart';

/// An adapter to convert between the legacy error handling system (`Either<Failure, T>`)
/// and the new system (`Result<T>`), facilitating a gradual migration.
class ErrorAdapter {
  /// Converts a [Failure] object to its corresponding [AppError].
  static AppError failureToAppError(Failure failure) {
    return AppErrorFactory.fromFailure(failure);
  }

  /// Converts an [AppError] object back to a [Failure] for backward compatibility.
  static Failure appErrorToFailure(AppError error) {
    return error.toFailure();
  }

  /// Converts an [Either<Failure, T>] to a [Result<T>].
  static Result<T> eitherToResult<T>(Either<Failure, T> either) {
    return either.fold(
      (failure) => Result.error(failureToAppError(failure)),
      (success) => Result.success(success),
    );
  }

  /// Converts a [Result<T>] to an [Either<Failure, T>].
  static Either<Failure, T> resultToEither<T>(Result<T> result) {
    return result.fold(
      (error) => Left(appErrorToFailure(error)),
      (success) => Right(success),
    );
  }

  /// Converts a [Future<Either<Failure, T>>] to a [Future<Result<T>>].
  static Future<Result<T>> futureEitherToResult<T>(
    Future<Either<Failure, T>> futureEither,
  ) async {
    final either = await futureEither;
    return eitherToResult(either);
  }

  /// Converts a [Future<Result<T>>] to a [Future<Either<Failure, T>>].
  static Future<Either<Failure, T>> futureResultToEither<T>(
    Future<Result<T>> futureResult,
  ) async {
    final result = await futureResult;
    return resultToEither(result);
  }
}

/// A wrapper for legacy repository methods that still return [Either].
///
/// This class helps standardize operations by converting their output to a [Result].
class RepositoryWrapper<T> {
  final Future<Either<Failure, T>> Function() _operation;

  RepositoryWrapper(this._operation);

  /// Executes the wrapped operation and returns its outcome as a [Result].
  ///
  /// It catches and converts any unexpected exceptions into an [AppError].
  Future<Result<T>> execute() async {
    try {
      final either = await _operation();
      return ErrorAdapter.eitherToResult(either);
    } catch (error, stackTrace) {
      return Result.error(AppErrorFactory.fromException(error, stackTrace));
    }
  }
}

/// An abstract class to facilitate the migration of UseCases to the new [Result] system
/// while maintaining backward compatibility with the old [Either] system.
abstract class MigratedUseCase<T, P> {
  /// The new method to be implemented by the subclass, using [Result].
  Future<Result<T>> executeNew(P params);

  /// The legacy `call` method, which ensures backward compatibility.
  Future<Either<Failure, T>> call(P params) async {
    final result = await executeNew(params);
    return ErrorAdapter.resultToEither(result);
  }
}

/// A mixin for `ChangeNotifier` providers that simplifies error handling.
mixin ErrorHandlingMixin on ChangeNotifier {
  AppError? _lastError;
  bool _hasError = false;

  /// The last error that occurred. `null` if there is no error.
  AppError? get lastError => _lastError;

  /// Returns `true` if an error is currently set.
  bool get hasError => _hasError;

  /// Clears the current error state and notifies listeners.
  void clearError() {
    if (_hasError) {
      _lastError = null;
      _hasError = false;
      notifyListeners();
    }
  }

  /// Sets the current error state and notifies listeners.
  void setError(AppError error) {
    _lastError = error;
    _hasError = true;
    notifyListeners();
  }

  /// Executes an operation that returns a [Result] and handles any errors automatically.
  Future<T?> handleOperation<T>(Future<Result<T>> Function() operation) async {
    clearError();
    final result = await operation();
    return result.fold((error) {
      setError(error);
      return null;
    }, (data) => data);
  }

  /// Executes an operation that returns an [Either] and handles errors automatically.
  Future<T?> handleEitherOperation<T>(
    Future<Either<Failure, T>> Function() operation,
  ) {
    return handleOperation(() async => ErrorAdapter.eitherToResult(await operation()));
  }

  /// Executes an operation and invokes callbacks for success or error.
  Future<T?> handleOperationWithCallback<T>(
    Future<Result<T>> Function() operation, {
    void Function(T data)? onSuccess,
    void Function(AppError error)? onError,
  }) async {
    final data = await handleOperation(operation);
    if (hasError) {
      onError?.call(lastError!);
    } else if (data != null) {
      onSuccess?.call(data);
    }
    return data;
  }
}

/// A mixin for UI components that simplifies displaying [AppError]s.
mixin ErrorDisplayMixin {
  /// Displays a [SnackBar] with a user-friendly error message.
  void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userMessage),
        backgroundColor: _getErrorColor(error.severity),
        duration: Duration(seconds: error.isCritical ? 10 : 4),
        action: error.isCritical
            ? SnackBarAction(
                label: 'Detalhes',
                onPressed: () => _showErrorDetails(context, error),
              )
            : null,
      ),
    );
  }

  /// Shows a dialog with detailed information about a critical error.
  void _showErrorDetails(BuildContext context, AppError error) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Erro'),
        content: SingleChildScrollView(
          child: ListBody(
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

  /// Returns a color based on the error's severity.
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

/// A utility class for logging errors with context and data sanitization.
class ErrorLogger {
  /// Logs an [AppError] to the console in debug mode.
  static void logError(AppError error) {
    if (kDebugMode) {
      debugPrint('🚨 AppError: ${_sanitizeMessage(error.message)}');
      debugPrint('   Category: ${error.category.name}');
      debugPrint('   Severity: ${error.severity.name}');
      if (error.code != null) debugPrint('   Code: ${error.code}');
      if (error.stackTrace != null && error.isCritical) {
        debugPrint('   Stack: [Stack trace available for critical errors]');
      }
    }
  }

  /// Logs an [AppError] with additional context, such as a user ID.
  static void logErrorWithContext(
    AppError error, {
    String? userId,
    Map<String, dynamic>? additionalContext,
  }) {
    // In a real app, this would send data to a logging service like Sentry or Firebase.
    if (kDebugMode) {
      final sanitizedContext = <String, dynamic>{
        'user_id': userId != null ? _sanitizeUserId(userId) : 'N/A',
        ...error.toMap(),
      };

      if (additionalContext != null) {
        additionalContext.forEach((key, value) {
          if (!_isSensitiveKey(key)) {
            sanitizedContext[key] = value;
          }
        });
      }

      debugPrint(
        '🚨 AppError with context: ${_sanitizeMessage(error.message)}',
      );
      debugPrint('   Context: $sanitizedContext');
    }
  }

  /// Sanitizes a message to remove potentially sensitive information.
  static String _sanitizeMessage(String message) {
    return message
        // Redact passwords
        .replaceAll(RegExp(r'password[\s:=][\w]+', caseSensitive: false), 'password=[REDACTED]')
        // Redact tokens
        .replaceAll(RegExp(r'token[\s:=][\w\-._]+', caseSensitive: false), 'token=[REDACTED]')
        // Redact API keys
        .replaceAll(RegExp(r'key[\s:=][\w\-._]+', caseSensitive: false), 'key=[REDACTED]')
        // Redact secrets
        .replaceAll(RegExp(r'secret[\s:=][\w\-._]+', caseSensitive: false), 'secret=[REDACTED]')
        // Redact email addresses
        .replaceAll(RegExp(r'[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}'), '[EMAIL_REDACTED]')
        // Redact credit card numbers
        .replaceAll(RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), '[CARD_REDACTED]');
  }

  /// Partially sanitizes a user ID for logging.
  static String _sanitizeUserId(String userId) {
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  /// Checks if a map key is likely to contain sensitive information.
  static bool _isSensitiveKey(String key) {
    final sensitivePatterns = ['password', 'secret', 'token', 'key', 'credential', 'auth', 'session'];
    final keyLower = key.toLowerCase();
    return sensitivePatterns.any(keyLower.contains);
  }
}

/// Extension methods for converting between [Result] and [Either].
extension ResultEitherConversion<T> on Result<T> {
  /// Converts this [Result] to an [Either].
  Either<Failure, T> toEither() => ErrorAdapter.resultToEither(this);
}

extension EitherResultConversion<L extends Failure, R> on Either<L, R> {
  /// Converts this [Either] to a [Result].
  Result<R> toResult() => ErrorAdapter.eitherToResult(this as Either<Failure, R>);
}

extension FutureResultEitherConversion<T> on Future<Result<T>> {
  /// Converts this [Future<Result>] to a [Future<Either>].
  Future<Either<Failure, T>> toEither() => ErrorAdapter.futureResultToEither(this);
}

extension FutureEitherResultConversion<L extends Failure, R> on Future<Either<L, R>> {
  /// Converts this [Future<Either>] to a [Future<Result>].
  Future<Result<R>> toResult() => ErrorAdapter.futureEitherToResult(this as Future<Either<Failure, R>>);
}