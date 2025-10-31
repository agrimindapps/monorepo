import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Service responsible for retry logic with exponential backoff
/// Follows SRP by handling only retry operations
@lazySingleton
class PremiumRetryManager {
  final Map<String, int> _retryCounts = {};
  final Map<String, Timer> _retryTimers = {};

  static const int _defaultMaxRetries = 3;
  static const Duration _defaultInitialDelay = Duration(seconds: 1);
  static const double _defaultBackoffMultiplier = 2.0;

  /// Execute operation with retry logic
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
          '[RetryManager] Retry $retryCount/$maxRetries for $key in ${delay.inSeconds}s',
        );

        // Wait before retry
        await Future<void>.delayed(delay);
      }
    }
  }

  /// Schedule a retry for later execution
  void scheduleRetry({
    required String key,
    required void Function() operation,
    Duration delay = _defaultInitialDelay,
  }) {
    // Cancel existing retry if any
    cancelRetry(key);

    debugPrint(
      '[RetryManager] Scheduling retry for $key in ${delay.inSeconds}s',
    );

    _retryTimers[key] = Timer(delay, () {
      try {
        operation();
      } catch (e) {
        debugPrint('[RetryManager] Error in scheduled retry: $e');
      } finally {
        _retryTimers.remove(key);
      }
    });
  }

  /// Cancel scheduled retry
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

  /// Reset retry count for a key
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

  /// Check if max retries reached
  bool hasReachedMaxRetries(String key, {int maxRetries = _defaultMaxRetries}) {
    return getRetryCount(key) >= maxRetries;
  }

  /// Check if retry is scheduled
  bool isRetryScheduled(String key) {
    return _retryTimers.containsKey(key);
  }

  /// Get scheduled retry count
  int get scheduledRetryCount => _retryTimers.length;

  /// Calculate next retry delay
  Duration getNextRetryDelay(
    String key, {
    Duration initialDelay = _defaultInitialDelay,
    double backoffMultiplier = _defaultBackoffMultiplier,
  }) {
    final retryCount = getRetryCount(key);
    return _calculateDelay(initialDelay, retryCount + 1, backoffMultiplier);
  }

  /// Execute with automatic retry on specific error types
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

  // Private helper methods

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

/// Mixin for retry-able errors
mixin RetryableError on Exception {}
