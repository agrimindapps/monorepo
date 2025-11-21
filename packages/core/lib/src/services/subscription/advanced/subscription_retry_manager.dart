import 'dart:async';

import 'package:flutter/foundation.dart';

/// Service responsible for retry logic with exponential backoff
///
/// Handles transient failures in subscription sync operations:
/// - Network timeouts
/// - API rate limiting
/// - Temporary service unavailability
///
/// Configuration via [AdvancedSyncConfiguration]:
/// - maxRetries: Maximum retry attempts
/// - retryBackoffMultiplier: Exponential backoff multiplier
///
/// Example:
/// ```dart
/// final subscription = await retryManager.executeWithRetry(
///   key: 'sync-revenueCat',
///   operation: () => provider.fetch(),
///   maxRetries: 3,
/// );
/// ```
class SubscriptionRetryManager {
  final Map<String, int> _retryCounts = {};
  final Map<String, Timer> _retryTimers = {};

  static const int _defaultMaxRetries = 3;
  static const Duration _defaultInitialDelay = Duration(seconds: 1);
  static const double _defaultBackoffMultiplier = 2.0;

  /// Execute operation with retry logic and exponential backoff
  ///
  /// Retries on failure up to [maxRetries] times with increasing delays:
  /// - Retry 1: initialDelay (1s default)
  /// - Retry 2: initialDelay * backoffMultiplier (2s default)
  /// - Retry 3: initialDelay * backoffMultiplier^2 (4s default)
  ///
  /// [shouldRetry] callback allows custom retry logic based on error type.
  Future<T> executeWithRetry<T>({
    required String key,
    required Future<T> Function() operation,
    int maxRetries = _defaultMaxRetries,
    Duration initialDelay = _defaultInitialDelay,
    double backoffMultiplier = _defaultBackoffMultiplier,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    var retryCount = _retryCounts[key] ?? 0;

    while (true) {
      try {
        final result = await operation();
        _resetRetryCount(key);
        return result;
      } catch (e) {
        retryCount++;
        _retryCounts[key] = retryCount;

        // Check if should retry
        final canRetry = retryCount <= maxRetries;
        final shouldRetryError = shouldRetry?.call(e) ?? true;

        if (!canRetry || !shouldRetryError) {
          _resetRetryCount(key);
          rethrow;
        }

        // Calculate delay with exponential backoff
        final delay = _calculateDelay(
          initialDelay,
          retryCount,
          backoffMultiplier,
        );

        debugPrint(
          '[SubscriptionRetryManager] Retry $retryCount/$maxRetries for $key in ${delay.inSeconds}s',
        );

        // Wait before retry
        await Future<void>.delayed(delay);
      }
    }
  }

  /// Schedule a retry for later execution (fire-and-forget)
  ///
  /// Useful for background operations that don't need immediate result:
  /// ```dart
  /// retryManager.scheduleRetry(
  ///   key: 'background-sync',
  ///   operation: () => syncService.forceSync(),
  ///   delay: Duration(seconds: 30),
  /// );
  /// ```
  void scheduleRetry({
    required String key,
    required void Function() operation,
    Duration delay = _defaultInitialDelay,
  }) {
    // Cancel existing retry if any
    cancelRetry(key);

    debugPrint(
      '[SubscriptionRetryManager] Scheduling retry for $key in ${delay.inSeconds}s',
    );

    _retryTimers[key] = Timer(delay, () {
      try {
        operation();
      } catch (e) {
        debugPrint('[SubscriptionRetryManager] Error in scheduled retry: $e');
      } finally {
        _retryTimers.remove(key);
      }
    });
  }

  /// Cancel a scheduled retry
  void cancelRetry(String key) {
    _retryTimers[key]?.cancel();
    _retryTimers.remove(key);
  }

  /// Cancel all scheduled retries
  void cancelAllRetries() {
    for (final key in _retryTimers.keys.toList()) {
      cancelRetry(key);
    }
  }

  /// Reset retry count for a specific key
  ///
  /// Useful after successful operation or when changing strategies.
  void resetRetryCount(String key) {
    _resetRetryCount(key);
  }

  /// Reset all retry counts
  void resetAllRetryCounts() {
    _retryCounts.clear();
  }

  /// Get current retry count for a key
  int getRetryCount(String key) {
    return _retryCounts[key] ?? 0;
  }

  /// Check if maximum retries have been reached
  bool hasReachedMaxRetries(String key, {int maxRetries = _defaultMaxRetries}) {
    return getRetryCount(key) >= maxRetries;
  }

  /// Check if a retry is currently scheduled
  bool isRetryScheduled(String key) {
    return _retryTimers.containsKey(key);
  }

  /// Get count of scheduled retries
  int get scheduledRetryCount => _retryTimers.length;

  /// Calculate the next retry delay based on current retry count
  Duration getNextRetryDelay(
    String key, {
    Duration initialDelay = _defaultInitialDelay,
    double backoffMultiplier = _defaultBackoffMultiplier,
  }) {
    final retryCount = getRetryCount(key);
    return _calculateDelay(initialDelay, retryCount + 1, backoffMultiplier);
  }

  /// Execute with automatic retry only on specific error types
  ///
  /// Example:
  /// ```dart
  /// final result = await retryManager.executeWithAutoRetry(
  ///   key: 'api-call',
  ///   operation: () => api.getSubscription(),
  ///   retryableErrors: [TimeoutException, SocketException],
  ///   maxRetries: 5,
  /// );
  /// ```
  Future<T> executeWithAutoRetry<T>({
    required String key,
    required Future<T> Function() operation,
    List<Type> retryableErrors = const [],
    int maxRetries = _defaultMaxRetries,
  }) async {
    return executeWithRetry(
      key: key,
      operation: operation,
      maxRetries: maxRetries,
      shouldRetry: (error) {
        if (retryableErrors.isEmpty) return true;
        return retryableErrors.any((type) => error.runtimeType == type);
      },
    );
  }

  // ==================== Private Methods ====================

  /// Calculate delay with exponential backoff (capped at 1 minute)
  Duration _calculateDelay(
    Duration initialDelay,
    int retryCount,
    double multiplier,
  ) {
    final delayMs =
        initialDelay.inMilliseconds * (multiplier * (retryCount - 1)).toInt();
    return Duration(milliseconds: delayMs.clamp(0, 60000)); // Max 1 minute
  }

  void _resetRetryCount(String key) {
    _retryCounts.remove(key);
  }

  /// Dispose all resources
  void dispose() {
    cancelAllRetries();
    resetAllRetryCounts();
  }
}

/// Mixin for marking exceptions as retryable
///
/// Example:
/// ```dart
/// class NetworkError extends Exception with RetryableError {
///   final String message;
///   NetworkError(this.message);
/// }
/// ```
mixin RetryableError on Exception {}
