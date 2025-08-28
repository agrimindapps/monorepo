import 'package:flutter_riverpod/flutter_riverpod.dart';

/// **Global State Patterns for Riverpod**
/// 
/// Standardized patterns and utilities for consistent state management
/// across all features in the app-petiveti application.
/// 
/// ## Key Patterns:
/// - **AsyncData Management**: Consistent handling of loading, success, error states
/// - **Provider Lifecycle**: Standardized disposal and cleanup patterns  
/// - **Error Handling**: Unified error state management
/// - **Loading States**: Consistent loading indicator patterns
/// - **Cache Management**: Efficient data caching strategies

/// **Base State Class**
/// 
/// Standard state structure for all features with common loading/error patterns.
abstract class BaseState<T> {
  final bool isLoading;
  final String? errorMessage;
  final T? data;
  final DateTime? lastUpdated;

  const BaseState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastUpdated,
  });

  bool get hasError => errorMessage != null;
  bool get hasData => data != null;
  bool get isEmpty => !hasData && !isLoading && !hasError;
}

/// **AsyncState Wrapper**
/// 
/// Standardized wrapper for async operations with consistent state management.
class AsyncState<T> extends BaseState<T> {
  const AsyncState({
    super.isLoading,
    super.errorMessage,
    super.data,
    super.lastUpdated,
  });

  AsyncState<T> copyWith({
    bool? isLoading,
    String? errorMessage,
    T? data,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return AsyncState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      data: data ?? this.data,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Factory constructors for common states
  factory AsyncState.loading() => AsyncState<T>(isLoading: true);
  
  factory AsyncState.success(T data) => AsyncState<T>(
    data: data,
    lastUpdated: DateTime.now(),
  );
  
  factory AsyncState.error(String message) => AsyncState<T>(
    errorMessage: message,
  );

  factory AsyncState.initial() => AsyncState<T>();
}

/// **Base Notifier Pattern**
/// 
/// Standardized notifier with common patterns and lifecycle management.
abstract class BaseAsyncNotifier<T> extends StateNotifier<AsyncState<T>> {
  BaseAsyncNotifier() : super(const AsyncState());

  /// Execute async operation with standard error handling
  Future<void> executeAsync<R>(
    Future<R> Function() operation, {
    required T Function(R) onSuccess,
    String Function(dynamic)? errorMapper,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final result = await operation();
      state = state.copyWith(
        isLoading: false,
        data: onSuccess(result),
        lastUpdated: DateTime.now(),
      );
    } catch (error, stackTrace) {
      final errorMessage = errorMapper?.call(error) ?? error.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      
      // Log error for debugging
      _logError(error, stackTrace);
    }
  }

  /// Clear error state
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Retry last operation (override in implementations)
  Future<void> retry() async {
    // Override in subclasses
  }

  void _logError(dynamic error, StackTrace stackTrace) {
    // In production, send to crash reporting service
    print('Error in ${runtimeType}: $error');
    print('StackTrace: $stackTrace');
  }
}

/// **List State Pattern**
/// 
/// Specialized state for managing lists with pagination and filtering.
class ListState<T> extends BaseState<List<T>> {
  final List<T> items;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;
  final Map<String, dynamic> filters;

  const ListState({
    this.items = const [],
    this.hasMore = false,
    this.currentPage = 0,
    this.searchQuery,
    this.filters = const {},
    super.isLoading,
    super.errorMessage,
    super.lastUpdated,
  }) : super(data: items);

  @override
  List<T>? get data => items;

  @override
  bool get hasData => items.isNotEmpty;

  ListState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    Map<String, dynamic>? filters,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearSearch = false,
  }) {
    return ListState<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Factory constructors for common list states
  factory ListState.loading() => ListState<T>(isLoading: true);
  
  factory ListState.success(List<T> items, {bool hasMore = false}) => ListState<T>(
    items: items,
    hasMore: hasMore,
    lastUpdated: DateTime.now(),
  );
  
  factory ListState.error(String message) => ListState<T>(
    errorMessage: message,
  );

  factory ListState.initial() => ListState<T>();
}

/// **Cache Management Utilities**
/// 
/// Standardized caching patterns for efficient data management.
class CacheManager<K, V> {
  final Map<K, CacheEntry<V>> _cache = {};
  final Duration defaultTtl;

  CacheManager({this.defaultTtl = const Duration(minutes: 5)});

  void put(K key, V value, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? defaultTtl,
    );
  }

  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  bool contains(K key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  void cleanExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }
}

class CacheEntry<V> {
  final V value;
  final DateTime timestamp;
  final Duration ttl;

  const CacheEntry({
    required this.value,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

/// **Provider Utilities**
/// 
/// Helper functions for consistent provider patterns.
abstract class ProviderUtils {
  /// Standard error mapper for common exceptions
  static String mapError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Check if data is fresh (within acceptable time range)
  static bool isDataFresh(DateTime? lastUpdated, {Duration maxAge = const Duration(minutes: 5)}) {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated) < maxAge;
  }

  /// Debounce function for search queries
  static Future<void> debounce(Duration duration, Future<void> Function() action) async {
    await Future<void>.delayed(duration);
    await action();
  }
}

/// **Loading State Management**
/// 
/// Centralized loading state patterns for consistent UI behavior.
enum LoadingType {
  initial,
  refresh,
  loadMore,
  search,
  operation,
}

class LoadingState {
  final Set<LoadingType> _activeLoading = {};

  bool isLoading(LoadingType type) => _activeLoading.contains(type);
  bool get hasAnyLoading => _activeLoading.isNotEmpty;
  bool get isInitialLoading => _activeLoading.contains(LoadingType.initial);
  bool get isRefreshing => _activeLoading.contains(LoadingType.refresh);

  void setLoading(LoadingType type, bool loading) {
    if (loading) {
      _activeLoading.add(type);
    } else {
      _activeLoading.remove(type);
    }
  }

  void clearAll() {
    _activeLoading.clear();
  }
}