/// **OCP - Open/Closed Principle**
/// Base interface for async operation states
/// Open for extension: different features can extend with their own async state
abstract class AsyncState<T> {
  bool get isLoading;
  bool get hasError;
  String? get errorMessage;
  T? get data;

  /// Whether the state is in initial state (no load attempted)
  bool get isInitial => !isLoading && !hasError && data == null;

  /// Whether data is available
  bool get hasData => data != null;
}

/// **OCP - Open/Closed Principle**
/// Base abstract class for async state implementation
/// Open for extension through copyWith pattern
abstract class AsyncStateBase<T> implements AsyncState<T> {
  @override
  final bool isLoading;

  @override
  final bool hasError;

  @override
  final String? errorMessage;

  @override
  final T? data;

  const AsyncStateBase({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.data,
  });

  /// Common copyWith pattern for all async states
  AsyncStateBase<T> copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    T? data,
    bool clearError = false,
  });
}

/// **Factory pattern for common async state transitions**
/// Provides static methods to create common async state instances
final class AsyncStateFactory {
  AsyncStateFactory._(); // Prevent instantiation

  /// Initial state - no load attempted
  static AsyncStateBase<T> initial<T>() {
    return _InitialAsyncState<T>();
  }

  /// Loading state
  static AsyncStateBase<T> loading<T>({T? previousData}) {
    return _LoadingAsyncState<T>(previousData: previousData);
  }

  /// Success state with data
  static AsyncStateBase<T> success<T>(T data) {
    return _SuccessAsyncState<T>(data: data);
  }

  /// Error state
  static AsyncStateBase<T> error<T>(
    String errorMessage, {
    T? previousData,
  }) {
    return _ErrorAsyncState<T>(
      errorMessage: errorMessage,
      previousData: previousData,
    );
  }
}

// Internal implementations
class _InitialAsyncState<T> extends AsyncStateBase<T> {
  const _InitialAsyncState()
      : super(
          isLoading: false,
          hasError: false,
          errorMessage: null,
          data: null,
        );

  @override
  bool get isInitial => true;

  @override
  bool get hasData => false;

  @override
  AsyncStateBase<T> copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    T? data,
    bool clearError = false,
  }) {
    return _InitialAsyncState<T>();
  }
}

class _LoadingAsyncState<T> extends AsyncStateBase<T> {
  final T? previousData;

  const _LoadingAsyncState({this.previousData})
      : super(
          isLoading: true,
          hasError: false,
          errorMessage: null,
          data: null,
        );

  @override
  bool get isInitial => false;

  @override
  bool get hasData => previousData != null;

  @override
  AsyncStateBase<T> copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    T? data,
    bool clearError = false,
  }) {
    return _LoadingAsyncState<T>(previousData: previousData ?? data);
  }
}

class _SuccessAsyncState<T> extends AsyncStateBase<T> {
  const _SuccessAsyncState({required T data})
      : super(
          isLoading: false,
          hasError: false,
          errorMessage: null,
          data: data,
        );

  @override
  bool get isInitial => false;

  @override
  bool get hasData => true;

  @override
  AsyncStateBase<T> copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    T? data,
    bool clearError = false,
  }) {
    return _SuccessAsyncState<T>(data: data ?? this.data!);
  }
}

class _ErrorAsyncState<T> extends AsyncStateBase<T> {
  final T? previousData;

  const _ErrorAsyncState({
    required String errorMessage,
    this.previousData,
  })  : super(
          isLoading: false,
          hasError: true,
          errorMessage: errorMessage,
          data: null,
        );

  @override
  bool get isInitial => false;

  @override
  bool get hasData => previousData != null;

  @override
  AsyncStateBase<T> copyWithAsync({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    T? data,
    bool clearError = false,
  }) {
    if (clearError) {
      return _SuccessAsyncState<T>(data: previousData ?? data as T);
    }
    return _ErrorAsyncState<T>(
      errorMessage: errorMessage ?? this.errorMessage!,
      previousData: previousData ?? data,
    );
  }
}
