import 'package:flutter/material.dart';

import 'enhanced_error_states.dart';
import 'enhanced_loading_states.dart';

/// Centralized async state management widget
/// Handles loading, error, and success states in a unified way
class AsyncStateBuilder<T> extends StatelessWidget {
  final AsyncState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final String? emptyMessage;
  final bool showDefaultLoading;
  final bool showDefaultError;

  const AsyncStateBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.onRetry,
    this.loadingMessage,
    this.emptyMessage,
    this.showDefaultLoading = true,
    this.showDefaultError = true,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => _buildLoading(context),
      error: (error) => _buildError(context, error),
      success: (data) => _buildSuccess(context, data),
      empty: () => _buildEmpty(context),
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (loadingBuilder != null) {
      return loadingBuilder!(context);
    }
    
    if (showDefaultLoading) {
      return Center(
        child: EnhancedLoadingStates.adaptiveLoading(
          message: loadingMessage,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildError(BuildContext context, String error) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error);
    }
    
    if (showDefaultError) {
      return EnhancedErrorStates.adaptiveError(
        title: 'Ops, algo deu errado',
        message: error,
        onRetry: onRetry,
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildSuccess(BuildContext context, T data) {
    return builder(context, data);
  }

  Widget _buildEmpty(BuildContext context) {
    if (emptyBuilder != null) {
      return emptyBuilder!(context);
    }
    
    return EnhancedErrorStates.emptyState(
      title: 'Nenhum item encontrado',
      message: emptyMessage,
    );
  }
}

/// Immutable async state representation
abstract class AsyncState<T> {
  const AsyncState();

  /// Create loading state
  const factory AsyncState.loading() = AsyncLoadingState<T>;

  /// Create error state
  const factory AsyncState.error(String message) = AsyncErrorState<T>;

  /// Create success state with data
  const factory AsyncState.success(T data) = AsyncSuccessState<T>;

  /// Create empty state
  const factory AsyncState.empty() = AsyncEmptyState<T>;

  /// Pattern matching for state handling
  R when<R>({
    required R Function() loading,
    required R Function(String error) error,
    required R Function(T data) success,
    required R Function() empty,
  }) {
    if (this is AsyncLoadingState<T>) {
      return loading();
    } else if (this is AsyncErrorState<T>) {
      return error((this as AsyncErrorState<T>).message);
    } else if (this is AsyncSuccessState<T>) {
      return success((this as AsyncSuccessState<T>).data);
    } else if (this is AsyncEmptyState<T>) {
      return empty();
    } else {
      throw StateError('Unknown async state: $this');
    }
  }

  /// Check if state is loading
  bool get isLoading => this is AsyncLoadingState<T>;

  /// Check if state has error
  bool get hasError => this is AsyncErrorState<T>;

  /// Check if state has data
  bool get hasData => this is AsyncSuccessState<T>;

  /// Check if state is empty
  bool get isEmpty => this is AsyncEmptyState<T>;

  /// Get data if available
  T? get data {
    if (this is AsyncSuccessState<T>) {
      return (this as AsyncSuccessState<T>).data;
    }
    return null;
  }

  /// Get error message if available
  String? get errorMessage {
    if (this is AsyncErrorState<T>) {
      return (this as AsyncErrorState<T>).message;
    }
    return null;
  }
}

class AsyncLoadingState<T> extends AsyncState<T> {
  const AsyncLoadingState();
  
  @override
  String toString() => 'AsyncLoadingState<$T>()';
}

class AsyncErrorState<T> extends AsyncState<T> {
  final String message;
  
  const AsyncErrorState(this.message);
  
  @override
  String toString() => 'AsyncErrorState<$T>(message: $message)';
}

class AsyncSuccessState<T> extends AsyncState<T> {
  final T data;
  
  const AsyncSuccessState(this.data);
  
  @override
  String toString() => 'AsyncSuccessState<$T>(data: $data)';
}

class AsyncEmptyState<T> extends AsyncState<T> {
  const AsyncEmptyState();
  
  @override
  String toString() => 'AsyncEmptyState<$T>()';
}

/// Provider-like class for managing async states
class AsyncStateNotifier<T> extends ValueNotifier<AsyncState<T>> {
  AsyncStateNotifier() : super(const AsyncState.loading());

  /// Set loading state
  void setLoading() {
    value = const AsyncState.loading();
  }

  /// Set error state
  void setError(String message) {
    value = AsyncState.error(message);
  }

  /// Set success state with data
  void setSuccess(T data) {
    value = AsyncState.success(data);
  }

  /// Set empty state
  void setEmpty() {
    value = const AsyncState.empty();
  }

  /// Execute async operation and update state accordingly
  Future<void> execute(Future<T> Function() operation) async {
    setLoading();
    try {
      final result = await operation();
      setSuccess(result);
    } catch (error) {
      setError(error.toString());
    }
  }

  /// Execute operation with empty check
  Future<void> executeWithEmptyCheck(
    Future<List<dynamic>> Function() operation,
    T Function(List<dynamic>) transform,
  ) async {
    setLoading();
    try {
      final result = await operation();
      if (result.isEmpty) {
        setEmpty();
      } else {
        setSuccess(transform(result));
      }
    } catch (error) {
      setError(error.toString());
    }
  }
}

/// Builder widget for AsyncStateNotifier
class AsyncStateNotifierBuilder<T> extends StatelessWidget {
  final AsyncStateNotifier<T> notifier;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final VoidCallback? onRetry;

  const AsyncStateNotifierBuilder({
    super.key,
    required this.notifier,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AsyncState<T>>(
      valueListenable: notifier,
      builder: (context, state, _) {
        return AsyncStateBuilder<T>(
          state: state,
          builder: builder,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          onRetry: onRetry,
        );
      },
    );
  }
}

/// Extension for common async state operations
extension AsyncStateExtensions<T> on AsyncState<T> {
  /// Transform success data
  AsyncState<R> map<R>(R Function(T data) transform) {
    return when(
      loading: () => const AsyncState.loading(),
      error: (error) => AsyncState.error(error),
      success: (data) => AsyncState.success(transform(data)),
      empty: () => const AsyncState.empty(),
    );
  }

  /// Filter success data (empty if filter fails)
  AsyncState<T> where(bool Function(T data) predicate) {
    return when(
      loading: () => const AsyncState.loading(),
      error: (error) => AsyncState.error(error),
      success: (data) => predicate(data) 
          ? AsyncState.success(data)
          : const AsyncState.empty(),
      empty: () => const AsyncState.empty(),
    );
  }
}