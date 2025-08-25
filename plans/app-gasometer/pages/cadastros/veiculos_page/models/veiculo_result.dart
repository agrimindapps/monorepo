library;

/// Result pattern implementation for vehicle operations
///
/// This provides a consistent way to handle success and failure cases
/// across all repository and service operations, eliminating the need
/// for mixed return types and exception handling patterns.

/// Base result class that encapsulates success or failure
abstract class VeiculoResult<T> {
  const VeiculoResult();

  /// Check if the operation was successful
  bool get isSuccess;

  /// Check if the operation failed
  bool get isFailure => !isSuccess;

  /// Get the success value (only available for Success results)
  T get value;

  /// Get the failure details (only available for Failure results)
  VeiculoFailure get failure;

  /// Transform the success value while preserving failure
  VeiculoResult<U> map<U>(U Function(T) transform);

  /// Flat map for chaining operations
  VeiculoResult<U> flatMap<U>(VeiculoResult<U> Function(T) transform);

  /// Handle both success and failure cases
  U fold<U>(U Function(VeiculoFailure) onFailure, U Function(T) onSuccess);

  /// Execute action only on success
  VeiculoResult<T> onSuccess(void Function(T) action);

  /// Execute action only on failure
  VeiculoResult<T> onFailure(void Function(VeiculoFailure) action);

  /// Convert to nullable value (null on failure)
  T? get valueOrNull;
}

/// Success result containing the operation value
class VeiculoSuccess<T> extends VeiculoResult<T> {
  final T _value;

  const VeiculoSuccess(this._value);

  @override
  bool get isSuccess => true;

  @override
  T get value => _value;

  @override
  VeiculoFailure get failure =>
      throw StateError('Cannot get failure from success result');

  @override
  VeiculoResult<U> map<U>(U Function(T) transform) {
    try {
      return VeiculoSuccess(transform(_value));
    } catch (e) {
      return VeiculoFailure.fromException(e, 'Error in map transformation');
    }
  }

  @override
  VeiculoResult<U> flatMap<U>(VeiculoResult<U> Function(T) transform) {
    try {
      return transform(_value);
    } catch (e) {
      return VeiculoFailure.fromException(e, 'Error in flatMap transformation');
    }
  }

  @override
  U fold<U>(U Function(VeiculoFailure) onFailure, U Function(T) onSuccess) {
    return onSuccess(_value);
  }

  @override
  VeiculoResult<T> onSuccess(void Function(T) action) {
    action(_value);
    return this;
  }

  @override
  VeiculoResult<T> onFailure(void Function(VeiculoFailure) action) {
    return this; // No-op for success
  }

  @override
  T? get valueOrNull => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VeiculoSuccess &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'VeiculoSuccess($_value)';
}

/// Failure result containing error information
class VeiculoFailure<T> extends VeiculoResult<T> {
  final String message;
  final VeiculoErrorType type;
  final Exception? exception;
  final String? context;
  final Map<String, dynamic>? details;

  const VeiculoFailure({
    required this.message,
    required this.type,
    this.exception,
    this.context,
    this.details,
  });

  /// Create failure from exception
  factory VeiculoFailure.fromException(
    dynamic exception,
    String context, {
    VeiculoErrorType? type,
    Map<String, dynamic>? details,
  }) {
    return VeiculoFailure(
      message: exception.toString(),
      type: type ?? _inferErrorType(exception),
      exception:
          exception is Exception ? exception : Exception(exception.toString()),
      context: context,
      details: details,
    );
  }

  /// Create network failure
  factory VeiculoFailure.network(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.network,
      context: context,
    );
  }

  /// Create validation failure
  factory VeiculoFailure.validation(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.validation,
      context: context,
    );
  }

  /// Create business logic failure
  factory VeiculoFailure.business(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.business,
      context: context,
    );
  }

  /// Create repository failure
  factory VeiculoFailure.repository(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.repository,
      context: context,
    );
  }

  /// Create not found failure
  factory VeiculoFailure.notFound(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.notFound,
      context: context,
    );
  }

  /// Create unauthorized failure
  factory VeiculoFailure.unauthorized(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.unauthorized,
      context: context,
    );
  }

  /// Create system failure
  factory VeiculoFailure.system(String message, {String? context}) {
    return VeiculoFailure(
      message: message,
      type: VeiculoErrorType.system,
      context: context,
    );
  }

  @override
  bool get isSuccess => false;

  @override
  T get value =>
      throw StateError('Cannot get value from failure result: $message');

  @override
  VeiculoFailure get failure => this;

  @override
  VeiculoResult<U> map<U>(U Function(T) transform) {
    return VeiculoFailure<U>(
      message: message,
      type: type,
      exception: exception,
      context: context,
      details: details,
    );
  }

  @override
  VeiculoResult<U> flatMap<U>(VeiculoResult<U> Function(T) transform) {
    return VeiculoFailure<U>(
      message: message,
      type: type,
      exception: exception,
      context: context,
      details: details,
    );
  }

  @override
  U fold<U>(U Function(VeiculoFailure) onFailure, U Function(T) onSuccess) {
    return onFailure(this);
  }

  @override
  VeiculoResult<T> onSuccess(void Function(T) action) {
    return this; // No-op for failure
  }

  @override
  VeiculoResult<T> onFailure(void Function(VeiculoFailure) action) {
    action(this);
    return this;
  }

  @override
  T? get valueOrNull => null;

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case VeiculoErrorType.network:
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      case VeiculoErrorType.validation:
        return 'Dados inválidos. Verifique as informações inseridas.';
      case VeiculoErrorType.business:
        return 'Operação não permitida pelas regras de negócio.';
      case VeiculoErrorType.repository:
        return 'Erro ao acessar dados. Tente novamente em alguns instantes.';
      case VeiculoErrorType.notFound:
        return 'Item não encontrado.';
      case VeiculoErrorType.unauthorized:
        return 'Operação não autorizada.';
      case VeiculoErrorType.system:
        return 'Erro interno do sistema. Entre em contato com o suporte.';
      case VeiculoErrorType.unknown:
        return 'Erro inesperado. Tente novamente.';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VeiculoFailure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          type == other.type &&
          context == other.context;

  @override
  int get hashCode => message.hashCode ^ type.hashCode ^ context.hashCode;

  @override
  String toString() =>
      'VeiculoFailure($type: $message${context != null ? ' [$context]' : ''})';

  /// Infer error type from exception
  static VeiculoErrorType _inferErrorType(dynamic exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return VeiculoErrorType.network;
    }

    if (message.contains('validation') ||
        message.contains('invalid') ||
        message.contains('format')) {
      return VeiculoErrorType.validation;
    }

    if (message.contains('not found') || message.contains('404')) {
      return VeiculoErrorType.notFound;
    }

    if (message.contains('unauthorized') ||
        message.contains('403') ||
        message.contains('401')) {
      return VeiculoErrorType.unauthorized;
    }

    if (message.contains('hive') ||
        message.contains('database') ||
        message.contains('storage')) {
      return VeiculoErrorType.repository;
    }

    return VeiculoErrorType.unknown;
  }
}

/// Types of errors that can occur in vehicle operations
enum VeiculoErrorType {
  network,
  validation,
  business,
  repository,
  notFound,
  unauthorized,
  system,
  unknown,
}

/// Extension methods for easier result creation
extension VeiculoResultExtensions<T> on T {
  /// Wrap value in a success result
  VeiculoResult<T> toSuccess() => VeiculoSuccess(this);
}

extension FutureVeiculoResultExtensions<T> on Future<T> {
  /// Convert Future<T> to Future<VeiculoResult<T>>
  Future<VeiculoResult<T>> toResult({String? context}) async {
    try {
      final value = await this;
      return VeiculoSuccess(value);
    } catch (e) {
      return VeiculoFailure.fromException(e, context ?? 'Operation failed');
    }
  }
}

extension NullableVeiculoResultExtensions<T> on T? {
  /// Convert nullable value to result
  VeiculoResult<T> toResultOrNotFound(String notFoundMessage) {
    final value = this;
    if (value != null) {
      return VeiculoSuccess(value);
    } else {
      return VeiculoFailure.notFound(notFoundMessage);
    }
  }
}

/// Helper functions for creating results
class VeiculoResults {
  VeiculoResults._();

  /// Create success result
  static VeiculoResult<T> success<T>(T value) => VeiculoSuccess(value);

  /// Create failure result
  static VeiculoResult<T> failure<T>(String message, VeiculoErrorType type) =>
      VeiculoFailure(message: message, type: type);

  /// Create result from nullable value
  static VeiculoResult<T> fromNullable<T>(T? value, String notFoundMessage) =>
      value.toResultOrNotFound(notFoundMessage);

  /// Combine multiple results into one
  static VeiculoResult<List<T>> combine<T>(List<VeiculoResult<T>> results) {
    final values = <T>[];

    for (final result in results) {
      if (result.isFailure) {
        return VeiculoFailure<List<T>>(
          message: result.failure.message,
          type: result.failure.type,
          exception: result.failure.exception,
          context: result.failure.context,
          details: result.failure.details,
        );
      }
      values.add(result.value);
    }

    return VeiculoSuccess(values);
  }

  /// Execute async operation and wrap in result
  static Future<VeiculoResult<T>> tryAsync<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    try {
      final value = await operation();
      return VeiculoSuccess(value);
    } catch (e) {
      return VeiculoFailure.fromException(
          e, context ?? 'Async operation failed');
    }
  }

  /// Execute sync operation and wrap in result
  static VeiculoResult<T> trySync<T>(
    T Function() operation, {
    String? context,
  }) {
    try {
      final value = operation();
      return VeiculoSuccess(value);
    } catch (e) {
      return VeiculoFailure.fromException(
          e, context ?? 'Sync operation failed');
    }
  }
}
