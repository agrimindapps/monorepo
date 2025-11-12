import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Adaptador para sistema de erros do app-plantis
/// App-plantis usa exclusivamente Either<Failure, T>
class ErrorAdapter {
  /// Converte Failure para AppError
  static AppError failureToAppError(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return NetworkError(
          message: failure.message,
          code: 'NETWORK_ERROR',
          details: failure.toString(),
        );

      case ServerFailure:
        return ExternalServiceError(
          message: failure.message,
          code: 'SERVER_ERROR',
          details: failure.toString(),
          serviceName: 'API',
        );

      case CacheFailure:
        return StorageError(
          message: failure.message,
          code: 'CACHE_ERROR',
          details: failure.toString(),
        );

      case NotFoundFailure:
        return BusinessError(
          message: failure.message,
          code: 'NOT_FOUND',
          details: failure.toString(),
          businessRule: 'RESOURCE_NOT_FOUND',
        );

      case AuthFailure:
        return AuthenticationError(
          message: failure.message,
          code: 'UNAUTHORIZED',
          details: failure.toString(),
        );

      case ValidationFailure:
        return ValidationError(
          message: failure.message,
          code: 'VALIDATION_ERROR',
          details: failure.toString(),
        );

      case UnknownFailure:
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
}

/// Mixin para providers que facilita o uso do sistema de erros
mixin ErrorHandlingMixin on ChangeNotifier {
  AppError? _lastError;
  bool _hasError = false;

  AppError? get lastError => _lastError;
  bool get hasError => _hasError;

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

  /// Executa uma operação Either e trata erros automaticamente
  Future<T?> handleEitherOperation<T>(
    Future<Either<Failure, T>> Function() operation,
  ) async {
    clearError();

    final either = await operation();

    return either.fold((failure) {
      setError(ErrorAdapter.failureToAppError(failure));
      return null;
    }, (data) => data);
  }
}
