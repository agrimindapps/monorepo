import 'dart:async';
import 'package:flutter/foundation.dart';
import '../error/app_error.dart';
import '../error/error_handler.dart';
import '../error/error_logger.dart';

/// Base provider state
enum ProviderState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Base provider with consistent error handling
abstract class BaseProvider extends ChangeNotifier {

  BaseProvider({
    ErrorHandler? errorHandler,
    ErrorLogger? errorLogger,
  })  : _errorHandler = errorHandler ?? ErrorHandler(ErrorLogger()),
        _logger = errorLogger ?? ErrorLogger();
  final ErrorHandler _errorHandler;
  final ErrorLogger _logger;

  ProviderState _state = ProviderState.initial;
  AppError? _error;
  bool _disposed = false;
  ProviderState get state => _state;
  AppError? get error => _error;
  bool get isLoading => _state == ProviderState.loading;
  bool get isLoaded => _state == ProviderState.loaded;
  bool get hasError => _state == ProviderState.error;
  bool get isEmpty => _state == ProviderState.empty;
  bool get isInitial => _state == ProviderState.initial;

  /// Provider name for logging
  String get providerName => runtimeType.toString();

  /// Set state and notify listeners
  @protected
  void setState(ProviderState newState, {AppError? error}) {
    if (_disposed) return;
    
    final previousState = _state;
    _state = newState;
    _error = error;
    _logger.logProviderStateChange(
      providerName,
      newState.name,
      {
        'previousState': previousState.name,
        'hasError': error != null,
        'errorType': error?.runtimeType.toString(),
      },
    );

    notifyListeners();
  }

  /// Execute operation with error handling
  @protected
  Future<void> executeOperation(
    Future<void> Function() operation, {
    required String operationName,
    Map<String, dynamic>? parameters,
    bool showLoading = true,
    RetryPolicy? retryPolicy,
  }) async {
    if (showLoading) {
      setState(ProviderState.loading);
    }

    final result = await _errorHandler.handleProviderOperation(
      operation,
      providerName: providerName,
      methodName: operationName,
      parameters: parameters,
      policy: retryPolicy ?? RetryPolicy.userAction,
    );

    result.fold(
      (error) => setState(ProviderState.error, error: error),
      (_) => setState(ProviderState.loaded),
    );
  }

  /// Execute operation that returns data
  @protected
  Future<T?> executeDataOperation<T>(
    Future<T> Function() operation, {
    required String operationName,
    Map<String, dynamic>? parameters,
    bool showLoading = true,
    RetryPolicy? retryPolicy,
    void Function(T data)? onSuccess,
  }) async {
    if (showLoading) {
      setState(ProviderState.loading);
    }

    final result = await _errorHandler.handleProviderOperation(
      operation,
      providerName: providerName,
      methodName: operationName,
      parameters: parameters,
      policy: retryPolicy ?? RetryPolicy.userAction,
    );

    return result.fold(
      (error) {
        setState(ProviderState.error, error: error);
        return null;
      },
      (data) {
        setState(ProviderState.loaded);
        onSuccess?.call(data);
        return data;
      },
    );
  }

  /// Execute operation that returns a list
  @protected
  Future<List<T>> executeListOperation<T>(
    Future<List<T>> Function() operation, {
    required String operationName,
    Map<String, dynamic>? parameters,
    bool showLoading = true,
    RetryPolicy? retryPolicy,
    void Function(List<T> data)? onSuccess,
  }) async {
    if (showLoading) {
      setState(ProviderState.loading);
    }

    final result = await _errorHandler.handleProviderOperation(
      operation,
      providerName: providerName,
      methodName: operationName,
      parameters: parameters,
      policy: retryPolicy ?? RetryPolicy.userAction,
    );

    return result.fold(
      (error) {
        setState(ProviderState.error, error: error);
        return <T>[];
      },
      (data) {
        if (data.isEmpty) {
          setState(ProviderState.empty);
        } else {
          setState(ProviderState.loaded);
        }
        onSuccess?.call(data);
        return data;
      },
    );
  }

  /// Clear error state
  void clearError() {
    if (_error != null) {
      setState(ProviderState.initial);
    }
  }

  /// Retry last failed operation
  void retry() {
    if (hasError) {
      onRetry();
    }
  }

  /// Override this to implement retry logic
  @protected
  void onRetry() {
  }

  /// Handle stream subscriptions with error handling
  @protected
  StreamSubscription<Result<T>> handleStream<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function()? onDone,
    required String operationName,
  }) {
    final handledStream = _errorHandler.handleStream(
      stream,
      operationName: '$providerName.$operationName',
    );

    return handledStream.listen(
      (result) {
        result.fold(
          (error) => setState(ProviderState.error, error: error),
          onData,
        );
      },
      onDone: onDone,
    );
  }

  /// Log custom events
  @protected
  void logInfo(String message, {Map<String, dynamic>? metadata}) {
    _logger.logInfo(
      message,
      metadata: {
        'provider': providerName,
        ...?metadata,
      },
      context: providerName,
    );
  }

  /// Log warnings
  @protected
  void logWarning(String message, {Map<String, dynamic>? metadata}) {
    _logger.logWarning(
      message,
      metadata: {
        'provider': providerName,
        ...?metadata,
      },
      context: providerName,
    );
  }

  /// Log errors manually
  @protected
  void logError(AppError error, {StackTrace? stackTrace}) {
    _logger.logError(
      error,
      stackTrace: stackTrace,
      additionalContext: {
        'provider': providerName,
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Mixin for providers that handle paginated data
mixin PaginatedProviderMixin<T> on BaseProvider {
  List<T> _items = [];
  bool _hasNextPage = true;
  int _currentPage = 0;
  bool _isLoadingMore = false;

  List<T> get items => List.unmodifiable(_items);
  bool get hasNextPage => _hasNextPage;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get itemCount => _items.length;

  /// Load first page
  Future<void> loadFirstPage() async {
    _currentPage = 0;
    _hasNextPage = true;
    _items.clear();
    
    await _loadPage();
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (!_hasNextPage || _isLoadingMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    _currentPage++;
    await _loadPage();
    
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    clearError();
    await loadFirstPage();
  }

  /// Override this to implement pagination logic
  @protected
  Future<List<T>> fetchPage(int page);

  Future<void> _loadPage() async {
    final pageData = await executeListOperation(
      () => fetchPage(_currentPage),
      operationName: 'fetchPage',
      parameters: {'page': _currentPage},
      showLoading: _currentPage == 0,
    );

    if (pageData.isNotEmpty) {
      if (_currentPage == 0) {
        _items = pageData;
      } else {
        _items.addAll(pageData);
      }
      _hasNextPage = pageData.length >= getPageSize();
    } else {
      _hasNextPage = false;
    }
  }

  /// Override this to set page size
  @protected
  int getPageSize() => 20;
}

/// Extension for UI error handling
extension ProviderUIHelpers on BaseProvider {
  /// Get user-friendly error message
  String get errorMessage => error?.displayMessage ?? 'Erro inesperado';

  /// Check if error is recoverable
  bool get canRetry => error?.isRecoverable ?? false;

  /// Check if should show retry button
  bool get shouldShowRetry => hasError && canRetry;
}