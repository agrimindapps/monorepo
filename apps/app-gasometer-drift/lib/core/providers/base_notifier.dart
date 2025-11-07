import 'package:core/core.dart';
import '../error/app_error.dart' as local_error;
import '../error/error_handler.dart' as local_handler;
import '../error/error_logger.dart' as local_logger;

/// Base state para todos os Riverpod notifiers
/// Encapsula data, loading e error state de forma consistente
class BaseNotifierState<T> {

  const BaseNotifierState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  const BaseNotifierState.initial() : this();

  const BaseNotifierState.loading({T? data})
      : this(data: data, isLoading: true, error: null);

  const BaseNotifierState.success(T data)
      : this(data: data, isLoading: false, error: null);

  const BaseNotifierState.failure(local_error.AppError error)
      : this(data: null, isLoading: false, error: error);
  final T? data;
  final bool isLoading;
  final local_error.AppError? error;

  BaseNotifierState<T> copyWith({
    T? data,
    bool? isLoading,
    local_error.AppError? error,
    bool clearError = false,
  }) {
    return BaseNotifierState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasError => error != null;
  bool get hasData => data != null;
  bool get isEmpty => !hasData && !isLoading && !hasError;
  bool get isRefreshing => isLoading && hasData;

  String get errorMessage => error?.displayMessage ?? 'Erro inesperado';
  bool get canRetry => error?.isRecoverable ?? false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseNotifierState<T> &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => data.hashCode ^ isLoading.hashCode ^ error.hashCode;

  @override
  String toString() => 'BaseNotifierState(data: $data, isLoading: $isLoading, error: $error)';
}

/// Extension para AsyncValue com helpers úteis
extension AsyncValueX<T> on AsyncValue<T> {
  /// Verifica se está carregando mas já tem valor (refreshing)
  bool get isRefreshing => isLoading && hasValue;

  /// Retorna valor ou null
  T? get valueOrNull => when(
        data: (value) => value,
        loading: () => null,
        error: (_, __) => null,
      );

  /// Retorna valor ou um fallback
  T valueOr(T fallback) => valueOrNull ?? fallback;

  /// Verifica se tem erro
  bool get hasError => when(
        data: (_) => false,
        loading: () => false,
        error: (_, __) => true,
      );

  /// Pega o erro se existir
  Object? get errorOrNull => when(
        data: (_) => null,
        loading: () => null,
        error: (e, _) => e,
      );

  /// Verifica se está carregando pela primeira vez (sem valor)
  bool get isLoadingFirstTime => isLoading && !hasValue;

  /// Mapeia os dados se existirem
  AsyncValue<R> mapData<R>(R Function(T data) mapper) {
    return when(
      data: (value) => AsyncValue.data(mapper(value)),
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  }

  /// Executa uma ação quando há dados
  void whenData(void Function(T data) action) {
    when(
      data: action,
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Converte AsyncValue para BaseNotifierState
  BaseNotifierState<T> toBaseState() {
    return when(
      data: (value) => BaseNotifierState.success(value),
      loading: () => BaseNotifierState.loading(data: valueOrNull),
      error: (error, _) {
        final appError = error is local_error.AppError
            ? error
            : local_error.UnexpectedError(
                message: error.toString(),
                technicalDetails: error.toString(),
              );
        return BaseNotifierState.failure(appError);
      },
    );
  }
}

/// Base Notifier abstrato para compartilhar lógica comum
/// Usa AsyncValue do Riverpod para gerenciar estado
abstract class BaseAsyncNotifier<T> extends AsyncNotifier<T> {
  final local_handler.ErrorHandler _errorHandler = local_handler.ErrorHandler(local_logger.ErrorLogger());
  final local_logger.ErrorLogger _logger = local_logger.ErrorLogger();

  /// Nome do notifier para logging
  String get notifierName => runtimeType.toString();

  /// Executa operação com tratamento de erro consistente
  Future<T> executeOperation(
    Future<T> Function() operation, {
    required String operationName,
    Map<String, dynamic>? parameters,
    local_handler.RetryPolicy? retryPolicy,
  }) async {
    _logger.logInfo(
      'Executing operation: $operationName',
      metadata: {
        'notifier': notifierName,
        ...?parameters,
      },
      context: notifierName,
    );

    final result = await _errorHandler.handleProviderOperation(
      operation,
      providerName: notifierName,
      methodName: operationName,
      parameters: parameters,
      policy: retryPolicy ?? local_handler.RetryPolicy.userAction,
    );

    return result.fold(
      (error) {
        _logger.logError(
          error,
          additionalContext: {
            'notifier': notifierName,
            'operation': operationName,
            'parameters': parameters,
          },
        );
        throw error;
      },
      (data) {
        _logger.logInfo(
          'Operation completed: $operationName',
          metadata: {
            'notifier': notifierName,
            'hasData': data != null,
          },
          context: notifierName,
        );
        return data;
      },
    );
  }

  /// Executa operação e atualiza estado
  Future<void> executeAndUpdate(
    Future<T> Function() operation, {
    required String operationName,
    Map<String, dynamic>? parameters,
    local_handler.RetryPolicy? retryPolicy,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await executeOperation(
        operation,
        operationName: operationName,
        parameters: parameters,
        retryPolicy: retryPolicy,
      );
    });
  }

  /// Atualiza dados mantendo estado de loading se necessário
  void updateData(T Function(T current) updater) {
    state.when(
      data: (current) {
        state = AsyncValue.data(updater(current));
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Log info
  void logInfo(String message, {Map<String, dynamic>? metadata}) {
    _logger.logInfo(
      message,
      metadata: {
        'notifier': notifierName,
        ...?metadata,
      },
      context: notifierName,
    );
  }

  /// Log warning
  void logWarning(String message, {Map<String, dynamic>? metadata}) {
    _logger.logWarning(
      message,
      metadata: {
        'notifier': notifierName,
        ...?metadata,
      },
      context: notifierName,
    );
  }

  /// Log error
  void logError(local_error.AppError error, {StackTrace? stackTrace}) {
    _logger.logError(
      error,
      stackTrace: stackTrace,
      additionalContext: {
        'notifier': notifierName,
      },
    );
  }
}

/// Base Notifier para Stream-based data
abstract class BaseStreamNotifier<T> extends StreamNotifier<T> {
  final local_handler.ErrorHandler _errorHandler = local_handler.ErrorHandler(local_logger.ErrorLogger());
  final local_logger.ErrorLogger _logger = local_logger.ErrorLogger();

  /// Nome do notifier para logging
  String get notifierName => runtimeType.toString();

  /// Transforma stream com tratamento de erro
  Stream<T> handleStream(
    Stream<T> stream, {
    required String operationName,
  }) {
    final handledStream = _errorHandler.handleStream(
      stream,
      operationName: '$notifierName.$operationName',
    );

    return handledStream.asyncMap((result) {
      return result.fold(
        (error) {
          _logger.logError(
            error,
            additionalContext: {
              'notifier': notifierName,
              'operation': operationName,
            },
          );
          throw error;
        },
        (data) => data,
      );
    });
  }

  /// Log helpers
  void logInfo(String message, {Map<String, dynamic>? metadata}) {
    _logger.logInfo(
      message,
      metadata: {
        'notifier': notifierName,
        ...?metadata,
      },
      context: notifierName,
    );
  }

  void logWarning(String message, {Map<String, dynamic>? metadata}) {
    _logger.logWarning(
      message,
      metadata: {
        'notifier': notifierName,
        ...?metadata,
      },
      context: notifierName,
    );
  }

  void logError(local_error.AppError error, {StackTrace? stackTrace}) {
    _logger.logError(
      error,
      stackTrace: stackTrace,
      additionalContext: {
        'notifier': notifierName,
      },
    );
  }
}
